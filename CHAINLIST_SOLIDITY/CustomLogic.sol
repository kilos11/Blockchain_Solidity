// SPDX-License-Identifier: MIT  
// Specifies the license under which the code is released. MIT is a permissive free software license.

pragma solidity ^0.8.19;  
// Declares that the code is written for Solidity version 0.8.19 or higher.

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";  
// Imports the AutomationCompatibleInterface from Chainlink's automation library, which allows for automated contract upkeep.

contract CustomLogic is AutomationCompatibleInterface {  
    // Declares a new contract named CustomLogic that implements the AutomationCompatibleInterface.

    uint256 public counter;  
    // A public state variable that keeps track of a count, initialized to zero by default.

    uint256 public immutable interval;  
    // An immutable state variable that stores the interval (in seconds) for the upkeep function to be triggered.

    uint256 public lastTimeStamp;  
    // A state variable that records the last time the upkeep function was executed.

    constructor(uint256 updateInterval) {  
        // Constructor function that initializes the contract with a specified update interval.
        interval = updateInterval;  
        // Sets the interval variable to the value passed during contract deployment.

        lastTimeStamp = block.timestamp;  
        // Initializes lastTimeStamp to the current block's timestamp at contract creation.

        counter = 0;  
        // Initializes the counter variable to zero.
    }

    function checkUpkeep(  
        bytes calldata /* checkData */  
    )  
        external  
        view  
        override  
        returns (bool upkeepNeeded, bytes memory)  
    {  
        // A public function that checks if upkeep is needed, returning a boolean and optional data.
        
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;  
        // Determines if enough time has passed since the last upkeep by comparing timestamps.
    }

    function performUpkeep(bytes calldata) external override {  
        // A public function that performs the upkeep if necessary, overriding the interface method.
        
        if ((block.timestamp - lastTimeStamp) > interval) {  
            // Checks if enough time has passed since the last upkeep.
            
            lastTimeStamp = block.timestamp;  
            // Updates lastTimeStamp to the current block's timestamp.
            
            counter = counter + 1;  
            // Increments the counter by one to reflect that upkeep has been performed.
        }  
    }  
}