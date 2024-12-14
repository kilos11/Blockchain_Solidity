/*The concept of structs exists in many high level 
programming languages. They are used to define your 
own data types which group together related data.*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract todoList {
    // Declare a struct which groups together two data types
    struct todoItem {
        string text;
        bool completed;
    }

    // Create an array of TodoItem structs
    todoItem[] public todos;

    function createTodo(string memory text) public {
         // There are multiple ways to initialize structs

         // Method 1 - Call it like a function
         todos.push(todoItem(text, false));

         // Method 2 - Explicitly set its keys
         todos.push(todoItem({ text: "_text", completed: false }));

         // Method 3 - Initialize an empty struct, then set individual properties
         todoItem memory todo;
         todo.text = "_text";
         todo.completed = false;
         todos.push(todo);

    }

    // Update a struct value
    function update(uint _index,string memory _text) public {
        todos[_index].text = "_text";
    }

    // Update completed
    function toggleCompleted(uint _index) public {
        todos[_index].completed = !todos[_index].completed;
    }
}