/*If you are receiving ETH in an Externally Owned Account (EOA) i.e. 
an account controlled by a private key (like MetaMask) - you do not need 
to do anything special as all such accounts can automatically accept 
all ETH transfers.

However, if you are writing a contract that you want to be able to 
receive ETH transfers directly, you must have at least one of the 
functions below:

receive() external payable

fallback() external payable

receive() is called if msg.data is an empty value, and fallback() is 
used otherwise.*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ReceiveEther {
    /*
    Which function is called, fallback() or receive()?

           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */

    // Function to receive Ether. msg.data must be empty
    receive() external payable { }

     // Fallback function is called when msg.data is not empty
     fallback() external payable { }

     function getBalance() public view returns (uint) {
        return address(this).balance;
     }
}