/* Events allow contracts to perform logging on the 
Ethereum blockchain. Logs for a given contract can be 
parsed later to perform updates on the frontend interface, 
for example. They are commonly used to allow frontend interfaces 
to listen for specific events and update the user interface, or 
used as a cheap form of storage. */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Events {
    // Declare an event which logs an address and a string
    event testCalled(address sender, string message);

    function test() public {
        // Log an event
        emit testCalled(msg.sender, "Someone called test()!");

    }
}