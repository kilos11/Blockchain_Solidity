/*Using the send function

The send function sends a specified amount of Ether to an address. 
It is a low-level function that only provides a stipend of 2300 gas for 
execution. This amount of gas is only enough to emit an event. 
If the execution requires more gas, it will fail. The send function 
does not throw an exception when it fails, instead, it returns false. 
This means you should always check the result of send and handle the 
failure case manually*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SendEther_send {
    function sendEther(address payable _to) public payable {
        // Just forward the ETH received in this payable function
        // to the given address
        uint amountTosend = msg.value;

        bool sent = _to.send(amountTosend);
        require(sent == true, "Failed to send ETH");
    }
    
}


/*Using the call function

 The call function is a low-level function that transfers 
 Ether and also forwards all remaining gas. This means call can be 
 used to send Ether and execute more complex operations that require
more than 2300 gas. However, like send, call does not automatically 
revert the transaction if the transfer fails. Instead, it returns false. 
So you should always check the result and handle the failure case 
manually. Also, because call forwards all remaining gas, it can 
potentially enable re-entrancy attacks if not used carefully*/

contract SendEther_call {
    function sendEth(address payable _to) public payable {
        // Just forward the ETH received in this payable function
        // to the given address
        uint amountTosend = msg.value;

        // call returns a bool value specifying success or failure
        (bool success,bytes memory data) = _to.call{value: msg.value}("");
        require(success == true, "Failed to send ETH");
    }
}


/*Using the transfer function

The transfer function also sends a specified amount of Ether to an 
address. Unlike send or call, transfer automatically throws an 
exception and reverts the transaction if the transfer fails. 
This makes transfer safer and easier to use because you do not 
need to manually check the result or handle the failure case. 
However, like send, transfer also only provides a stipend of 2300 gas 
for execution*/

contract SendEther_transfer {
    function sendEth(address payable _to) public payable {
        // Just forward the ETH received in this payable function
        // to the given address
        uint amountTosend = msg.value;

        // Use the transfer method to send the ETH.
        _to.transfer(msg.value);
    }
}