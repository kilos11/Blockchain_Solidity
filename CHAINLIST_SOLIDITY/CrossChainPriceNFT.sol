// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Sepolia

// Importing OpenZeppelin contracts for ERC721 functionality and utilities
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol"; // ERC721 with URI storage
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol"; // Counter utility for tracking token IDs
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol"; // Base64 encoding utility

// Importing Chainlink contracts for price feeds
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; 
// Interface for Chainlink price feeds

// Main contract inheriting from ERC721 and ERC721URIStorage
contract CrossChainPriceNFT is ERC721, ERC721URIStorage {
    // Using Counters library to manage token IDs 
    using Counters for Counters.Counter;
    // Using Strings library for uint256 to string conversion 
    using Strings for uint256; 
    // Counter for tracking the current token ID
    Counters.Counter public tokenIdCounter; 

    // Create price feed interface
    // Interface to interact with the price feed
    AggregatorV3Interface internal priceFeed; 
    // Variable to store the last price fetched
    uint256 public lastPrice = 0; 

    // Emoji indicators for price changes
    string priceIndicatorUp = unicode"😀"; // Emoji indicating price increase
    string priceIndicatorDown = unicode"😔"; // Emoji indicating price decrease
    string priceIndicatorFlat = unicode"😑"; // Emoji indicating no price change
    string public priceIndicator; // Variable to hold the current price indicator

    struct ChainStruct { // Struct to define a blockchain's properties
        uint64 code; // Unique code for the chain
        string name; // Name of the chain
        string color; // Color associated with the chain
    }
    
    // Mapping to associate token IDs with their respective chain properties
    mapping (uint256 => ChainStruct) chain; 
    
    // Constructor initializing the ERC721 token with name and symbol
    constructor() ERC721("CrossChain Price", "CCPrice") { 
        // Initializing properties for Sepolia chain
        chain[0] = ChainStruct ({ 
            code: 16015286601757825753,
            name: "Sepolia",
            color: "#0000ff" // Blue color for Sepolia
        });
        // Initializing properties for Fuji chain
        chain[1] = ChainStruct ({ 
            code: 14767482510784806043,
            name: "Fuji",
            color: "#ff0000" // Red color for Fuji
        });
        // Initializing properties for Base Sepolia chain
        chain[2] = ChainStruct ({ 
            code: 10344971235874465080,
            name: "Base Sepolia",
            color: "#ffffff" // White color for Base Sepolia
        });
        // Initializing properties for Polygon Amoy chain
        chain[3] = ChainStruct ({ 
            code: 10344971235874465080,
            name: "Polygon Amoy",
            color: "#4b006e" // Purple color for Polygon Amoy
        });

        // Setting the price feed address for Sepolia BTC/USD data feed        
        priceFeed = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43            
        );

        // Mint an NFT to the deployer's address upon contract creation
        mint(msg.sender); 
    }

    // Function to mint an NFT to a specified address
    function mint(address to) public { 
        mintFrom(to, 0); // Mint from Sepolia network (sourceId 0)
    }

    // Function to mint NFT from a specific source chain ID
    function mintFrom(address to, uint256 sourceId) public { 
        // Get the current token ID from the counter
        uint256 tokenId = tokenIdCounter.current(); 
        // Safely mint the NFT to the specified address with the current token ID
        _safeMint(to, tokenId); 
        updateMetaData(tokenId, sourceId);    // Update metadata after minting    
        tokenIdCounter.increment(); // Increment the token ID counter for future mints
    }

    // Function to update metadata of a minted NFT based on source ID
    function updateMetaData(uint256 tokenId, uint256 sourceId) public { 
        // Build SVG representation based on source ID
        string memory finalSVG = buildSVG(sourceId); 
        // Encode metadata into JSON format and Base64 encode it      
        string memory json = Base64.encode( 
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Cross-chain Price SVG",', 
                        '"description": "SVG NFTs in different chains",', 
                        '"image": "data:image/svg+xml;base64,', 
                        Base64.encode(bytes(finalSVG)), '",', 
                        '"attributes": [', 
                            '{"trait_type": "source",',
                            '"value": "', chain[sourceId].name ,'"}', 
                            '{"trait_type": "price",',
                            '"value": "', lastPrice.toString() ,'"}', 
                        ']}'
                    )
                )
            )
        );
        // Create final token URI by combining JSON data and encoding it in Base64 format 
        string memory finalTokenURI = string( 
            abi.encodePacked("data:application/json;base64,", json)
        );
        // Set the generated token URI in the NFT storage      
        _setTokenURI(tokenId, finalTokenURI); 
    }

    // Function to create SVG representation of the NFT based on source ID
    function buildSVG(uint256 sourceId) internal returns (string memory) { 
        // Create SVG header with rectangle filled with corresponding color from chain mapping 
        string memory headSVG = string( 
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' version='1.1' xmlns:xlink='http://www.w3.org/1999/xlink' xmlns:svgjs='http://svgjs.com/svgjs' width='500' height='500' preserveAspectRatio='none' viewBox='0 0 500 500'> <rect width='100%' height='100%' fill='",
                chain[sourceId].color,
                "' />"
            )
        );
        // Create SVG text element displaying current price indicator emoji      
        string memory bodySVG = string(
            abi.encodePacked(
                "<text x='50%' y='50%' font-size='128' dominant-baseline='middle' text-anchor='middle'>",
                comparePrice(), 
                "</text>"
            )
        );
        
        string memory tailSVG = "</svg>"; // Closing tag for SVG
        // Concatenate all parts of SVG together and return final SVG representation 
        return string(
            abi.encodePacked(headSVG, bodySVG, tailSVG)
        );
    }
    // Function to compare current price with last recorded price and update 
    //indicator emoji accordingly
    function comparePrice() public returns (string memory) { 
        // Fetch current price from Chainlink data feed 
        uint256 currentPrice = getChainlinkDataFeedLatestAnswer();  
        
        if (currentPrice > lastPrice) {
            // Set indicator to up emoji if current price is higher than last recorded price  
            priceIndicator = priceIndicatorUp;  
        } else if (currentPrice < lastPrice) {
            // Set indicator to down emoji if current price is lower than last recorded price 
            priceIndicator = priceIndicatorDown;  
        } else {
            // Set indicator to flat emoji if prices are unchanged 
            priceIndicator = priceIndicatorFlat;  
        }
        // Update last recorded price with current fetched value      
        lastPrice = currentPrice;  
        
        return priceIndicator;  // Return current price indicator emoji 
    }

    // Function to fetch latest answer from Chainlink data feed 
    function getChainlinkDataFeedLatestAnswer() public view returns (uint256) {  
        // Get latest round data from Chainlink feed
        (, int256 price, , , ) = priceFeed.latestRoundData();  
        
        return uint256(price);  // Return latest fetched price as unsigned integer 
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {  
        // Override function to return token URI from parent contracts 
       return super.tokenURI(tokenId);  
   }

   function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {  
       // Override burn function to call parent burn implementation 
       super._burn(tokenId);  
   }
}
