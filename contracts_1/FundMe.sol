// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    address[] public funders;

    uint256 public mimimumUSD = 5e18;

    mapping(address funder  => uint256 amountFunded) public addressToAmountFunded;

    address public owner;

    constructor() {
        owner = msg.sender;

    }
 
    function fund() public payable  {
        //How do we send ETH to htis contract?   
        require(msg.value.getConversionRate() >= mimimumUSD, "You need to send more than 0.5 ETH!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;


    }

    function withdraw() public {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[] (0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }
    }

    


}