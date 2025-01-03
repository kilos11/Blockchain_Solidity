/*Inheritance is the procedure by which one contract can inherit the 
attributes and methods of another contract. Solidity supports multiple 
inheritance. Contracts can inherit other contract by using the is keyword.

A parent contract which has a function that can be overridden by a child 
contract must be declared as a virtual function.

A child contract that is going to override a parent function must use 
the override keyword.

The order of inheritance matters if parent contracts share methods or 
attributes by the same name.*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/* Graph of inheritance
  A
 /  \
B    C
|\  /|
| \/ |
| /\ | 
D    E

*/

contract A {
    // Declare a virtual function foo() which can be overridden by children
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
}  

contract B is A {
    // Override A.foo();
    // But also allow this function to be overridden by further children
    // So we specify both keywords - virtual and override
    function foo() public pure virtual override returns(string memory) {
        return "B";
    }
}

contract C is A {
    // Similar to contract B above
    function foo() public pure virtual override returns(string memory) {
        return "C";
    }
}

// When inheriting from multiple contracts, if a function is defined 
//multiple times, the right-most parent contract's function is used.
contract D is B,C {
    // D.foo() returns "C"
    // since C is the right-most parent with function foo();
    // override (B,C) means we want to override a method that exists in two parents
    function foo() public pure  override (B,C) returns(string memory) {
        // super is a special keyword that is used to call functions
        // in the parent contract
        return super.foo();

    }
}

contract E is C,B {
    // E.foo() returns "B"
    // since B is the right-most parent with function foo();
    function foo() public pure override(C,B) returns(string memory) {
        return super.foo();
    }
}