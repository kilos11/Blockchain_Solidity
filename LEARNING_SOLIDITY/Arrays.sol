// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyArrays {
    uint[] public uintArray = [1,2,3];
    string[] public stringArray = ["apple","kgaogelo","Lethabo"];
    string[]public value;
    uint256[][] public arrays2D = [[1,2,3],[4,5,6]];

    function addValue(string memory _value) public {
        value.push(_value);
    }

    function valueCount() public view returns(uint) {
        return value.length;
    }
}    