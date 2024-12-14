// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Specify the Solidity version to be used

// Deploy this contract on Sepolia

// Importing Chainlink CCIPReceiver for cross-chain communication
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol"; 
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol"; // Importing Client library for handling messages

// Interface for an NFT minter contract
interface InftMinter {
    // Function signature for minting NFTs from a specific source
    function mintFrom(address account, uint256 sourceId) external; 
}

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

 // Main contract inheriting from CCIPReceiver for cross-chain functionality
contract CrossDestinationMinter is CCIPReceiver { 
    // Declare a public variable to hold the NFT minter contract reference
    InftMinter public nft; 
    // Event to signal successful minting calls
    event MintCallSuccessfull(); 

    // Address of the router on Sepolia network for CCIP
    address routerSepolia = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;

    // Constructor that initializes the router and NFT address
    constructor(address nftAddress) CCIPReceiver(routerSepolia) { 
        // Set the NFT minter contract address
        nft = InftMinter(nftAddress); 
    }

    // Internal function to handle incoming messages from CCIP
    function _ccipReceive( 
        // Parameter to receive a message of type Any2EVMMessage
        Client.Any2EVMMessage memory message 
    ) internal override { // Override the inherited function
        // Call the mint function on the NFT contract with the message data
        (bool success, ) = address(nft).call(message.data); 
        require(success); // Ensure the call was successful, revert if not
        // Emit event indicating successful minting call
        emit MintCallSuccessfull(); 
    }

    // Public function to test minting an NFT directly from Sepolia
    function testMint() external { 
        // Call the mintFrom function on the NFT contract with sender's 
        //address and sourceId 0
        nft.mintFrom(msg.sender, 0); 
    }

    // Public function to test sending a message for minting an NFT
    function testMessage() external { 
        // Declare a variable to hold the encoded message
        bytes memory message;
        // Encode the mintFrom function call with parameters 
        message = abi.encodeWithSignature("mintFrom(address,uint256)", msg.sender, 0); 
        // Call the NFT contract with the encoded message
        (bool success, ) = address(nft).call(message); 
        // Ensure the call was successful, revert if not
        require(success); 
        // Emit event indicating successful minting call
        emit MintCallSuccessfull(); 
    }

    // Public function to update the NFT minter contract address
    function updateNFT(address nftAddress) external { 
        // Set the new NFT minter contract address
        nft = InftMinter(nftAddress); 
    }
}
