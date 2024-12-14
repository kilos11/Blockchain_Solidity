// SPDX-License-Identifier: MIT
pragma solidity 0.8.19; // Specify the Solidity version to be used

// Deploy this contract on Fuji

// Importing necessary interfaces and libraries for Chainlink CCIP
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol"; // Interface for the router client
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol"; // Library for handling CCIP messages
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol"; // Interface for LINK token interactions

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

 // Main contract for cross-chain minting
contract CrossSourceMinter { 

    // Error for insufficient balance to cover fees
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); 
    // Error for attempting to withdraw with no balance
    error NothingToWithdraw(); 
    // Declare a public router client variable
    IRouterClient public router; 
    // Declare a public LINK token interface variable
    LinkTokenInterface public linkToken; 
    // Variable to select the destination chain
    uint64 public destinationChainSelector; 
    // Variable to store the owner's address
    address public owner; 
    // Variable to store the destination minter's address
    address public destinationMinter; 
    // Event to emit when a message is sent
    event MessageSent(bytes32 messageId);

    // Constructor to initialize the contract with the destination minter's address
    constructor(address destMinterAddress) {
        // Set the owner to the address that deployed the contract 
        owner = msg.sender; 

        // https://docs.chain.link/ccip/supported-networks/testnet

        // Address of the router on Fuji network
        address routerAddressFuji = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
        // Initialize the router client with Fuji address 
        router = IRouterClient(routerAddressFuji);
        // Initialize LINK token interface 
        linkToken = LinkTokenInterface(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846); 
        // Approve maximum LINK token amount for the router    
        linkToken.approve(routerAddressFuji, type(uint256).max); 

        // Set destination chain selector and minter address for Sepolia
        destinationChainSelector = 16015286601757825753;
        // Set the destination minter's address 
        destinationMinter = destMinterAddress; 
    }

    // Function to initiate minting on Sepolia from Fuji network
    function mintOnSepolia() external {
        // Create a message structure for CCIP 
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({ 
            // Encode the destination minter's address as receiver
            receiver: abi.encode(destinationMinter),
            // Encode function call with parameters for minting 
            data: abi.encodeWithSignature("mintFrom(address,uint256)", msg.sender, 1), 
            // No token amounts are being sent with this message
            tokenAmounts: new Client.EVMTokenAmount[](0),
            // Additional arguments for the message 
            extraArgs: Client._argsToBytes( 
                // Set gas limit for the transaction
                Client.EVMExtraArgsV1({gasLimit: 980_000}) 
            ),
            // Specify LINK token as fee token
            feeToken: address(linkToken) 
        });  

        // Get required fees to send the message
        uint256 fees = router.getFee(destinationChainSelector, message); 

        // Check if contract has enough LINK tokens to cover fees
        if (fees > linkToken.balanceOf(address(this)))
            // Revert if not enough balance 
            revert NotEnoughBalance(linkToken.balanceOf(address(this)), fees); 

        bytes32 messageId; 
        // Send the message through the router and store the returned message ID
        messageId = router.ccipSend(destinationChainSelector, message);
        // Emit event indicating a message has been sent 
        emit MessageSent(messageId); 
    }

    // Modifier to restrict access to only the owner of the contract
    modifier onlyOwner() { 
        require(msg.sender == owner); 
        _; 
    }

    // Function to check LINK balance of a specified account
    function linkBalance (address account) public view returns (uint256) { 
        // Return LINK balance of the account
        return linkToken.balanceOf(account); 
    }

    // Function to withdraw LINK tokens from this contract to a 
    //beneficiary address
    function withdrawLINK( 
        address beneficiary 
    ) public onlyOwner { 
        // Get current LINK balance of this contract
        uint256 amount = linkToken.balanceOf(address(this)); 
        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw(); 
        // Transfer LINK tokens to beneficiary address
        linkToken.transfer(beneficiary, amount); 
    }
}
