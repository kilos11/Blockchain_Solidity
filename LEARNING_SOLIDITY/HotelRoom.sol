// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // Specify the version of Solidity to use

contract HotelRoom { // Define a new contract called HotelRoom
    // Enum to represent the status of the room
    enum Statuses {Vacant  , Occupied  } // Possible statuses: Vacant or Occupied
    Statuses public currentStatus; // Variable to hold the current status of the room

    address payable public owner; // Variable to store the owner's address (who deploys the contract)

    event Occupy(address _occupant, uint _value); // Event to log when a room is booked

    constructor() { // Constructor function that runs once when the contract is deployed
        owner = payable(msg.sender); // Set the owner to the address that deployed the contract
        currentStatus = Statuses.Vacant; // Initialize the room status as Vacant
    }

    modifier onlyWhileVacant { // Modifier to check if the room is vacant
        require(currentStatus == Statuses.Vacant, "Currently Occupied"); // Ensure room is vacant
        _; // Continue with function execution if condition is met
    }

    modifier costs(uint _amount) { // Modifier to check if enough Ether is sent
        require(msg.value >= _amount, "Not Enough Ether"); // Ensure sent Ether meets required amount
        _; // Continue with function execution if condition is met
    }

    function book() public payable onlyWhileVacant costs(2 ether) { // Function to book the room
        currentStatus = Statuses.Occupied; // Change room status to Occupied
        
        (bool sent, bytes memory data) = owner.call{value: msg.value}(""); // Send Ether to owner
        require(sent, "Failed to send Ether"); // Ensure Ether was sent successfully

        emit Occupy(msg.sender, msg.value); // Log the booking event with occupant's address and value sent
    }
}