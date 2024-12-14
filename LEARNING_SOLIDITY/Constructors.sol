/*A constructor is an optional function that is executed 
when the contract is first deployed. Unlike other functions, 
constructors cannot be manually called ever again after the 
contract has been deployed, therefore it can only ever run once. 
You can also pass arguments to constructors before the contract is 
deployed.*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract X {
    string public name;

    // You will need to provide a string argument when deploying 
    //the contract
    constructor(string memory name) {
        // This will be set immediately when the contract is deployed
        name = "_name";
    }

}