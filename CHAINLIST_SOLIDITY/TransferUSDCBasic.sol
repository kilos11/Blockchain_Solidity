// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; // Specify the version of Solidity to use

// Import necessary interfaces and libraries from Chainlink contracts
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol"; 
// Interface for the CCIP router client
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol"; 
// Library for CCIP client functionalities
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol"; 
// ERC20 token interface
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/utils/SafeERC20.sol"; 
// Safe operations for ERC20 tokens

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract TransferUSDCBasic {
    using SafeERC20 for IERC20; // Use SafeERC20 functions for safe token transfers

    // Custom error definitions for specific failure cases
    error NotEnoughBalanceForFees(uint256 currentBalance, uint256 calculatedFees); 
    // Error for insufficient LINK balance for fees
    error NotEnoughBalanceUsdcForTransfer(uint256 currentBalance); 
    // Error for insufficient USDC balance for transfer
    error NothingToWithdraw(); 
    // Error when trying to withdraw with no balance

    address public owner; // Address of the contract owner
    IRouterClient private immutable ccipRouter; // CCIP router client instance
    IERC20 private immutable linkToken; // LINK token instance
    IERC20 private immutable usdcToken; // USDC token instance

    // Hardcoded address for the CCIP router on the Avalanche Fuji testnet
    address ccipRouterAddress = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;

    // Hardcoded address for the LINK token on the Avalanche Fuji testnet
    address linkAddress = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;

    // Hardcoded address for the USDC token on test networks
    address usdcAddress = 0x5425890298aed601595a70AB815c96711a31Bc65;

    // Hardcoded destination chain selector for Sepolia network
    uint64 destinationChainSelector = 16015286601757825753;

    // Event to log successful USDC transfers
    event UsdcTransferred(
        bytes32 messageId, // Unique message ID of the transfer
        uint64 destinationChainSelector, // Destination chain identifier
        address receiver, // Address receiving the USDC
        uint256 amount, // Amount of USDC transferred
        uint256 ccipFee // Fee paid in LINK for the transfer
    );

    constructor() {
        owner = msg.sender; // Set the owner to the address that deploys the contract
        ccipRouter = IRouterClient(ccipRouterAddress); // Initialize CCIP router client with its address
        linkToken = IERC20(linkAddress); // Initialize LINK token with its address
        usdcToken = IERC20(usdcAddress); // Initialize USDC token with its address
    }

    function transferUsdcToSepolia(
        address _receiver, // Address to receive USDC on Sepolia
        uint256 _amount // Amount of USDC to transfer
    )
        external 
        returns (bytes32 messageId) // Returns a unique message ID upon success

    {   // Create an array to hold token amounts (1 element)
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1); 
        
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({ 
            token: address(usdcToken), // Set the token to USDC's address 
            amount: _amount // Set the amount to transfer 
        });
        
        tokenAmounts[0] = tokenAmount; // Assign the created token amount to the array

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({ 
            receiver: abi.encode(_receiver), // Encode the receiver's address 
            data: "",  // Additional data (empty in this case)
            tokenAmounts: tokenAmounts, // Set the token amounts for this message 
            extraArgs: Client._argsToBytes( 
                Client.EVMExtraArgsV1({gasLimit: 0})  // Extra arguments (gas limit set to 0)
            ),
            feeToken: address(linkToken)  // Set fee token to LINK's address 
        });

        uint256 ccipFee = ccipRouter.getFee( 
            destinationChainSelector,  // Get fee for sending to the specified chain 
            message  // Message containing transfer details 
        );

        if (ccipFee > linkToken.balanceOf(address(this))) 
            revert NotEnoughBalanceForFees(linkToken.balanceOf(address(this)), ccipFee); 
            // Revert if contract does not have enough LINK balance to cover fees
        
        linkToken.approve(address(ccipRouter), ccipFee); 
        // Approve CCIP router to spend LINK tokens on behalf of this contract

        if (_amount > usdcToken.balanceOf(msg.sender)) 
            revert NotEnoughBalanceUsdcForTransfer(usdcToken.balanceOf(msg.sender)); 
            // Revert if sender does not have enough USDC balance 

        usdcToken.safeTransferFrom(msg.sender, address(this), _amount); 
        // Safely transfer USDC from sender to this contract

        usdcToken.approve(address(ccipRouter), _amount); 
        // Approve CCIP router to spend USDC tokens on behalf of this contract

        messageId = ccipRouter.ccipSend(destinationChainSelector, message); 
        // Send CCIP message and get a unique message ID 

        emit UsdcTransferred( 
            messageId,  // Emit event with details of the transfer 
            destinationChainSelector,
            _receiver,
            _amount,
            ccipFee
        );
    }

    function allowanceUsdc() public view returns (uint256 usdcAmount) { 
        usdcAmount = usdcToken.allowance(msg.sender, address(this)); 
        // Return the allowance of USDC tokens that this contract can spend on behalf of sender 
    }

    function balancesOf(address account) public view returns (uint256 linkBalance, uint256 usdcBalance) { 
        linkBalance = linkToken.balanceOf(account);  // Get LINK balance of specified account 
        usdcBalance = IERC20(usdcToken).balanceOf(account);  // Get USDC balance of specified account 
    }

    modifier onlyOwner() { 
        require(msg.sender == owner);  // Ensure that only the owner can call certain functions 
        _;  // Placeholder for function body where modifier is applied 
    }

    function withdrawToken( 
        address _beneficiary,  // Address that will receive withdrawn tokens  
        address _token  // Token contract address to withdraw from this contract  
    ) public onlyOwner {  
        uint256 amount = IERC20(_token).balanceOf(address(this));  
        if (amount == 0) revert NothingToWithdraw();  
         // Revert if there are no tokens available to withdraw 

         IERC20(_token).transfer(_beneficiary, amount);  
         // Transfer all available tokens to beneficiary  
     }
}