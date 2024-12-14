// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; // Specify the Solidity version to use

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    using PriceConverter for uint256;

    function getPrice() internal view returns(uint256) {
        //address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //ABI\
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
        
        }

    function getConvertionRate(uint256 ethAmount) internal  view returns (uint256)  {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice)/1e18;
        return ethAmountInUsd;

    }

    function getVersion() internal  view returns(uint256) {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }


}