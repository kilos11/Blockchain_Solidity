// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Ownable contract to manage ownership
contract Ownable {
    address owner; // Variable to store owner's address

    modifier onlyOwner() { // Modifier to restrict access to owner only
        require(msg.sender == owner, "must be owner");
        _; // Continue execution if condition is met
    }

    constructor() { // Constructor to set the owner
        owner = msg.sender; // Set the deployer as the owner
    }
}

// SecretVault contract to store a secret
contract SecretVault { // Corrected contract name from 'secretVault' to 'SecretVault'
    string secret; // Variable to hold the secret

    constructor(string memory _secret) { // Constructor to initialize the secret
        secret = _secret; // Store the provided secret
    }

    function getSecret() public view returns(string memory) { // Function to retrieve the secret
        return secret; // Return the stored secret
    }
}

// Factory contract that creates SecretVault instances and manages them
contract MyContract is Ownable { // Inherit from Ownable
    address secretVault; // Variable to store address of SecretVault instance

    constructor(string memory _secret) { // Constructor for MyContract
        SecretVault _secretVault = new SecretVault(_secret); // Create new SecretVault instance
        secretVault = address(_secretVault); // Store its address
    }

    function getSecret() public view onlyOwner returns(string memory) { // Function for owner to get secret
        return SecretVault(secretVault).getSecret(); // Call getSecret on SecretVault instance
    }
}