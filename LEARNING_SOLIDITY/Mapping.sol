// SPDX-License-Identifier: MIT
// This line specifies the license for the code, which is MIT in this case.

pragma solidity ^0.8.0;
// This line indicates that the code is written for Solidity version 0.8.0 or higher.

contract MyMapping {
    // This line defines a new smart contract called MyMapping.

    // Mapping from address (like a person's account) to uint (a number)
    mapping(address => uint) public myMap;
    // This creates a mapping called myMap where each address can be linked to a number.

    mapping(uint => string) public names;
    // This creates a mapping called names where each number (uint) is linked to a string (name).

    // Mapping from address to another mapping (from uint to bool)
    mapping(address => mapping(uint => bool)) public nestedMap;
    // This creates a nested mapping called nestedMap where each address can have its own mapping of numbers to true/false values.

    function get(address _addr) public view returns (uint) {
        // This function allows anyone to get the number associated with an address.
        return myMap[_addr];
        // It returns the value from myMap for the given address. If not set, it returns 0 (the default for uint).
    }

    function get(address _addr1, uint _i) public view returns (bool) {
        // This function allows anyone to get the boolean value from the nested mapping.
        return nestedMap[_addr1][_i];
        // It returns the value from nestedMap for the given address and number. If not set, it returns false (the default for bool).
    }

    function set(
        address _addr1,
        uint _i,
        bool _boo
    ) public {
        // This function allows anyone to set a boolean value in the nested mapping.
        nestedMap[_addr1][_i] = _boo;
        // It updates the value in nestedMap for the given address and number with the provided boolean (_boo).
    }

    function remove(address _addr1, uint _i) public {
        // This function allows anyone to remove a value from the nested mapping.
        delete nestedMap[_addr1][_i];
        // It deletes the entry in nestedMap for the given address and number, resetting it to false.
    }

    function set(address _addr, uint _i) public {
        // This function allows anyone to set or update a number associated with an address.
        myMap[_addr] = _i;
        // It updates myMap for the given address with the provided number (_i).
    }

    function remove(address _addr) public {
        // This function allows anyone to remove the number associated with an address.
        delete myMap[_addr];
        // It deletes the entry in myMap for the given address, resetting it to 0.
    }

    constructor()  {
        // This is a special function that runs only once when the contract is created.
        names[1] = "Jay";   // Sets name "Jay" for ID 1.
        names[2] = "Selim"; // Sets name "Selim" for ID 2.
        names[3] = "Mohamed"; // Sets name "Mohamed" for ID 3.
    }

    mapping(uint => Book) public books;
    // This creates a mapping called books where each number (uint) is linked to a Book struct.

    struct Book {
        string title;  // The title of the book.
        string author; // The author of the book.
    }

    function addBook(uint _id,
                     string memory _title, 
                     string memory author) public{
        // This function allows anyone to add a book with an ID, title, and author.
        books[_id] = Book(_title, author);
        // It creates a new Book with the provided title and author and stores it in books using the given ID.
    }

    mapping (address => mapping(uint => Book)) public MyBooks;
    // This creates a mapping called MyBooks where each address can have its own mapping of book IDs to Book structs.

    function addMyBook(uint _id,
                     string memory _title, 
                     string memory author) public{
        // This function allows anyone to add their own book with an ID, title, and author.
        MyBooks[msg.sender][_id] = Book(_title, author);
        // It creates a new Book with the provided title and author and stores it in MyBooks using their address and given ID.
    }
}