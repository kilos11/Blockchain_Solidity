// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    //State Variables
    uint public MyUint = 1;
    uint256 public MyUint256 = 1;

    //Local Variables
    function getValue() public pure returns(uint) {
        uint value = 1;
        return value;
    }

    //Strings
    string public MyString = "Hello Worl";
    bytes32 public MyBytes32 = "Hello earth";

    //Storing Addresses
    address public MyAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    //Constructing Structs
    struct MyStruct {
      uint256 Myuint_256;
      string MyString1;
      //string MyString2;
      //address MyAddress; //We can store multiple addresses in a single contractaddress MyAddress; 
    }  
    MyStruct public myStruct = MyStruct(1, "Hello World");

}