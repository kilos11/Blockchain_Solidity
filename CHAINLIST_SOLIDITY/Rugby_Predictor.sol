// Specify the version of Solidity to use for compiling
pragma solidity ^0.8.7;

// Import necessary external contracts and libraries
import {ResultsConsumer} from "./ResultsConsumer.sol";
import {NativeTokenSender} from "./ccip/NativeTokenSender.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

// Define a configuration structure that stores contract parameters
struct Config {
  address oracle;                 // Address of the Oracle for data retrieval
  address ccipRouter;             // Address for the CCIP Router
  address link;                   // Address for the LINK token
  address weth9Token;             // Address for the WETH9 token
  address exchangeToken;          // Address for the exchange token (e.g., token for trading)
  address uniswapV3Router;        // Address for Uniswap V3 Router
  uint64 subscriptionId;          // Subscription ID for Chainlink
  uint64 destinationChainSelector; // Selector for the destination chain
  uint32 gasLimit;                // Gas limit for transactions
  bytes secrets;                  // Secrets used for authentication (e.g., API keys)
  string source;                  // The source of the data for predictions
}

// Main contract that implements the sports prediction game logic
contract SportsPredictionGame is ResultsConsumer, NativeTokenSender, AutomationCompatibleInterface {

  // Constants for game limits and timings
  uint256 private constant MIN_WAGER = 0.00001 ether; // Minimum amount for a wager
  uint256 private constant MAX_WAGER = 0.01 ether;   // Maximum amount for a wager
  uint256 private constant GAME_RESOLVE_DELAY = 2 hours; // Time delay after game ends to resolve it

  // Mappings for storing game and prediction data
  mapping(uint256 => Game) private games; // Store games by their ID
  mapping(address => mapping(uint256 => Prediction[])) private predictions; // Store predictions by user and game

  mapping(uint256 => bytes32) private pendingRequests; // Mapping to track unresolved requests

  uint256[] private activeGames; // List of active games
  uint256[] private resolvedGames; // List of resolved games

  // Game struct to store game data
  struct Game {
    uint256 sportId;           // Sport ID (e.g., 1 for football, 2 for basketball)
    uint256 externalId;        // External game identifier (from external source)
    uint256 timestamp;         // Timestamp when the game is scheduled
    uint256 homeWagerAmount;   // Total wager amount on the home team
    uint256 awayWagerAmount;   // Total wager amount on the away team
    bool resolved;             // Flag indicating if the game is resolved
    Result result;             // Result of the game (Home, Away, None)
  }

  // Prediction struct to store user predictions
  struct Prediction {
    uint256 gameId;            // Game ID the prediction is for
    Result result;             // Predicted result (Home, Away, None)
    uint256 amount;            // Amount wagered by the user
    bool claimed;              // Flag indicating if the winnings are claimed
  }

  // Enum for possible results of a game
  enum Result {
    None,   // No result yet
    Home,   // Home team wins
    Away    // Away team wins
  }

  // Events to emit during game registration, resolution, predictions, and claims
  event GameRegistered(uint256 indexed gameId); 
  event GameResolved(uint256 indexed gameId, Result result);
  event Predicted(address indexed user, uint256 indexed gameId, Result result, uint256 amount);
  event Claimed(address indexed user, uint256 indexed gameId, uint256 amount);

  // Custom error definitions for various conditions
  error GameAlreadyRegistered();
  error TimestampInPast();
  error GameNotRegistered();
  error GameIsResolved();
  error GameAlreadyStarted();
  error InsufficientValue();
  error ValueTooHigh();
  error InvalidResult();
  error GameNotResolved();
  error GameNotReadyToResolve();
  error ResolveAlreadyRequested();
  error NothingToClaim();

  // Constructor to initialize the contract with the provided config
  constructor(
    Config memory config
  )
    ResultsConsumer(config.oracle, config.subscriptionId, config.source, config.secrets, config.gasLimit)
    NativeTokenSender(
      config.ccipRouter,
      config.link,
      config.weth9Token,
      config.exchangeToken,
      config.uniswapV3Router,
      config.destinationChainSelector
    )
  {}

  // Function for users to make a prediction on a specific game
  function predict(uint256 gameId, Result result) public payable {
    Game memory game = games[gameId]; // Retrieve the game data
    uint256 wagerAmount = msg.value;  // Get the wager amount sent by the user

    // Check for various conditions that would prevent the prediction
    if (game.externalId == 0) revert GameNotRegistered(); // Game must be registered
    if (game.resolved) revert GameIsResolved();            // Game must not be resolved
    if (game.timestamp < block.timestamp) revert GameAlreadyStarted(); // Game must not have started
    if (wagerAmount < MIN_WAGER) revert InsufficientValue(); // Wager too low
    if (wagerAmount > MAX_WAGER) revert ValueTooHigh();     // Wager too high

    // Update the respective team's wager amount based on the user's prediction
    if (result == Result.Home) games[gameId].homeWagerAmount += wagerAmount;
    else if (result == Result.Away) games[gameId].awayWagerAmount += wagerAmount;
    else revert InvalidResult(); // If the result is invalid, revert

    // Store the prediction for the user
    predictions[msg.sender][gameId].push(Prediction(gameId, result, wagerAmount, false));

    emit Predicted(msg.sender, gameId, result, wagerAmount); // Emit an event for the prediction
  }

  // Function to register a new game and make a prediction simultaneously
  function registerAndPredict(uint256 sportId, uint256 externalId, uint256 timestamp, Result result) external payable {
    uint256 gameId = _registerGame(sportId, externalId, timestamp); // Register the game
    predict(gameId, result); // Make the prediction
  }

  // Function for users to claim their winnings after a game is resolved
  function claim(uint256 gameId, bool transfer) external {
    Game memory game = games[gameId]; // Retrieve the game data
    address user = msg.sender;        // Get the address of the user

    if (!game.resolved) revert GameNotResolved(); // Ensure the game is resolved

    uint256 totalWinnings = 0; // Total winnings to be claimed by the user
    Prediction[] memory userPredictions = predictions[user][gameId]; // Get the user's predictions for the game

    // Loop through the user's predictions to calculate winnings
    for (uint256 i = 0; i < userPredictions.length; i++) {
      Prediction memory prediction = userPredictions[i]; // Retrieve each prediction
      if (prediction.claimed) continue; // Skip if already claimed
      if (game.result == Result.None) {
        totalWinnings += prediction.amount; // Return wager if no result
      } else if (prediction.result == game.result) {
        uint256 winnings = calculateWinnings(gameId, prediction.amount, prediction.result); // Calculate the winnings based on prediction
        totalWinnings += winnings;
      }
      predictions[user][gameId][i].claimed = true; // Mark the prediction as claimed
    }

    if (totalWinnings == 0) revert NothingToClaim(); // Ensure there are winnings to claim

    // Transfer the winnings to the user
    if (transfer) {
      _sendTransferRequest(user, totalWinnings); // Send via CCIP
    } else {
      payable(user).transfer(totalWinnings); // Send via regular transfer
    }

    emit Claimed(user, gameId, totalWinnings); // Emit an event for the claim
  }

  // Internal function to register a new game
  function _registerGame(uint256 sportId, uint256 externalId, uint256 timestamp) internal returns (uint256 gameId) {
    gameId = getGameId(sportId, externalId); // Calculate the game ID

    if (games[gameId].externalId != 0) revert GameAlreadyRegistered(); // Ensure the game is not already registered
    if (timestamp < block.timestamp) revert TimestampInPast(); // Ensure the timestamp is in the future

    // Register the new game
    games[gameId] = Game(sportId, externalId, timestamp, 0, 0, false, Result.None);
    activeGames.push(gameId); // Add the game to active games

    emit GameRegistered(gameId); // Emit an event for the registration
  }

  // Internal function to request the resolution of a game result
  function _requestResolve(uint256 gameId) internal {
    Game memory game = games[gameId]; // Retrieve the game data

    // Check for various conditions to ensure the game can be resolved
    if (pendingRequests[gameId] != 0) revert ResolveAlreadyRequested();
    if (game.externalId == 0) revert GameNotRegistered();
    if (game.resolved) revert GameIsResolved();
    if (!readyToResolve(gameId)) revert GameNotReadyToResolve();

    pendingRequests[gameId] = _requestResult(game.sportId, game.externalId);
  }

   function _processResult(uint256 sportId, uint256 externalId, bytes memory response) internal override {
    uint256 gameId = getGameId(sportId, externalId);
    Result result = Result(uint256(bytes32(response)));
    _resolveGame(gameId, result);
  }

  function _resolveGame(uint256 gameId, Result result) internal {
    games[gameId].result = result;
    games[gameId].resolved = true;

    resolvedGames.push(gameId);
    _removeFromActiveGames(gameId);

    emit GameResolved(gameId, result);
  }

  function _removeFromActiveGames(uint256 gameId) internal {
    uint256 index;
    for (uint256 i = 0; i < activeGames.length; i++) {
      if (activeGames[i] == gameId) {
        index = i;
        break;
      }
    }
    for (uint256 i = index; i < activeGames.length - 1; i++) {
      activeGames[i] = activeGames[i + 1];
    }
    activeGames.pop();
  }

  function getGameId(uint256 sportId, uint256 externalId) public pure returns (uint256) {
    return (sportId << 128) | externalId;
  }

  function getGame(uint256 gameId) external view returns (Game memory) {
    return games[gameId];
  }

  function getActiveGames() public view returns (Game[] memory) {
    Game[] memory activeGamesArray = new Game[](activeGames.length);
    for (uint256 i = 0; i < activeGames.length; i++) {
      activeGamesArray[i] = games[activeGames[i]];
    }
    return activeGamesArray;
  }

  function getActivePredictions(address user) external view returns (Prediction[] memory) {
    uint256 totalPredictions = 0;
    for (uint256 i = 0; i < activeGames.length; i++) {
      totalPredictions += predictions[user][activeGames[i]].length;
    }
    uint256 index = 0;
    Prediction[] memory userPredictions = new Prediction[](totalPredictions);
    for (uint256 i = 0; i < activeGames.length; i++) {
      Prediction[] memory gamePredictions = predictions[user][activeGames[i]];
      for (uint256 j = 0; j < gamePredictions.length; j++) {
        userPredictions[index] = gamePredictions[j];
        index++;
      }
    }
    return userPredictions;
  }

  function getPastPredictions(address user) external view returns (Prediction[] memory) {
    uint256 totalPredictions = 0;
    for (uint256 i = 0; i < resolvedGames.length; i++) {
      totalPredictions += predictions[user][resolvedGames[i]].length;
    }
    uint256 index = 0;
    Prediction[] memory userPredictions = new Prediction[](totalPredictions);
    for (uint256 i = 0; i < resolvedGames.length; i++) {
      Prediction[] memory gamePredictions = predictions[user][resolvedGames[i]];
      for (uint256 j = 0; j < gamePredictions.length; j++) {
        userPredictions[index] = gamePredictions[j];
        index++;
      }
    }
    return userPredictions;
  }

  function isPredictionCorrect(address user, uint256 gameId, uint32 predictionIdx) external view returns (bool) {
    Game memory game = games[gameId];
    if (!game.resolved) return false;
    Prediction memory prediction = predictions[user][gameId][predictionIdx];
    return prediction.result == game.result;
  }

  function calculateWinnings(uint256 gameId, uint256 wager, Result result) public view returns (uint256) {
    Game memory game = games[gameId];
    uint256 totalWager = game.homeWagerAmount + game.awayWagerAmount;
    uint256 winnings = (wager * totalWager) / (result == Result.Home ? game.homeWagerAmount : game.awayWagerAmount);
    return winnings;
  }

  function readyToResolve(uint256 gameId) public view returns (bool) {
    return games[gameId].timestamp + GAME_RESOLVE_DELAY < block.timestamp;
  }

  function checkUpkeep(bytes memory) public view override returns (bool, bytes memory) {
    Game[] memory activeGamesArray = getActiveGames();
    for (uint256 i = 0; i < activeGamesArray.length; i++) {
      uint256 gameId = getGameId(activeGamesArray[i].sportId, activeGamesArray[i].externalId);
      if (readyToResolve(gameId) && pendingRequests[gameId] == 0) {
        return (true, abi.encodePacked(gameId));
      }
    }
    return (false, "");
  }

  function performUpkeep(bytes calldata data) external override {
    uint256 gameId = abi.decode(data, (uint256));
    _requestResolve(gameId);
  }

  function deletePendingRequest(uint256 gameId) external onlyOwner {
    delete pendingRequests[gameId];
  }
}
