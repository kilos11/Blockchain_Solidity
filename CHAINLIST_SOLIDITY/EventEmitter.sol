// SPDX-License-Identifier: MIT  
// Specifies the license under which the code is released. MIT is a permissive free software license.

pragma solidity ^0.8.19;  
// Declares that the code is written for Solidity version 0.8.19 or higher.

contract EventEmitter {  
    // Declares a new contract named EventEmitter.

    event WantsToCount(address indexed msgSender);  
    // Defines an event named WantsToCount that logs the address of the sender (msgSender). 
    // The 'indexed' keyword allows for filtering events by this parameter in logs.

    constructor() {}  
    // Constructor function that initializes the contract. 
    // It does not perform any actions upon deployment.

    function emitCountLog() public {  
        // A public function that can be called by anyone to emit the WantsToCount event.
        
        emit WantsToCount(msg.sender);  
        // Emits the WantsToCount event, passing the address of the caller (msg.sender) as an argument.
    }  
}