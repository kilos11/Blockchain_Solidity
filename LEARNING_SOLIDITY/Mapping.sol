// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyMapping {
    //Mapping
    mapping (uint => string) public names;

    constructor()  {
        names[1] = "Jay";
        names[2] = "Selim";
        names[3] = "Mohamed";
    }

    mapping(uint => Book) public books;

    struct Book {
        string title;
        string author;
    }

    function addBook(uint _id,
                     string memory _title, 
                     string memory author) public{
        books[_id] = Book(_title,author);
        
    }

    mapping (address => mapping(uint => Book)) public MyBooks;

    function addMyBook(uint _id,
                     string memory _title, 
                     string memory author) public{
        MyBooks[msg.sender][_id] = Book(_title,author);
        
    }

}   