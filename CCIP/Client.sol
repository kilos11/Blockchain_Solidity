// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Client {
    struct EVM2AnyMessage {
        bytes receiver; // abi.encode(receiver address) for dest EVM chains
        bytes data; // data payload
        EVMTokenAmount[] tokenAmounts; // token transfers
        address feeToken; // fee token address; address(0) means you are sending msg.value
        bytes extraArgs; // populate this with _argsToBytes(EVMExtraArgsV1)
    }
    
    struct EVMTokenAmount {
        address token; // token address on local blockchain
        uint256 amount;
    }
    
    struct EVMExtraArgsV1 {
        uint256 gasLimit;
        bool strict;
    }
}