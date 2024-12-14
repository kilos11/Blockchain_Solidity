// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; // Specify the Solidity version to use

// Import the AggregatorV3Interface from Chainlink for price feeds
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// Define a library named PriceConverter
library PriceConverter {
    
    /**
     * Function to get the current price of ETH in USD from Chainlink's price feed
     * @return The current price of ETH in USD, scaled up by 1e10 for precision
     */
    function getPrice() internal view returns(uint256) {
        // Create an instance of the price feed interface using the specified address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        
        // Call the latestRoundData function to get the latest price data
        (, int256 price, , ,) = priceFeed.latestRoundData();
        
        // Return the price as a uint256, scaling it up by 1e10 for precision (to handle decimal places)
        return uint256(price * 1e10);
    }

    /**
     * Function to convert an amount of ETH to its equivalent value in USD
     * @param ethAmount The amount of ETH to convert
     * @return The equivalent value in USD of the provided ETH amount
     */
    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        // Get the current price of ETH in USD
        uint256 ethPrice = getPrice(); 
        
        // Calculate the equivalent value in USD by multiplying ETH amount by ETH price and adjusting for decimals
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        
        // Return the calculated USD value
        return ethAmountInUSD;
    }

    /**
     * Function to retrieve the version of the Chainlink Aggregator contract being used
     * @return The version number of the Chainlink Aggregator contract
     */
    function getVersion() internal view returns(uint256) {
        // Call the version function on the AggregatorV3Interface to get its version number
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}