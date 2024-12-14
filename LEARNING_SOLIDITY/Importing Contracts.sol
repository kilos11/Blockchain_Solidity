
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Foo {
    string public name = "Foo";
}

//We can import Foo and use it in Import.sol as such
// import Foo.sol from current directory
import "./Foo.sol/";

contract Import {
    // Initialize Foo.sol
    Foo public foo = new Foo();

    // Test Foo.sol by getting it's name.
    function getFooName () public view returns (string memory) {
        return foo.name();
    }
}
