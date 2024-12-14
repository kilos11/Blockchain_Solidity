//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract SimpleAuction {
    // Parameters of the auction. Times are either
    // absolute unix timestamps (seconds since 1970-01-01)
    // or time periods in seconds.
    address payable public beneficiery;
    uint public auctionEndTime;

    // Current state of the auction.
    mapping (address => uint) pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool end;

    // Events that will be emitted on changes.
    event HighestBidIncreased (address bidder,uint amount);
    event AuctionEnded (address winner,uint amount);

    // Errors that describe failures.
    // The triple-slash comments are so-called natspec
    // comments. They will be shown when the user
    // is asked to confirm a transaction or
    // when an error is displayed.

    /// The auction has already ended.
    error AuctionAlreadyEnded();

    /// There is already a higher or equal bid.
    error BidNotHighEnough (uint highestBid);

    /// The auction has not ended yet.
    error AuctionNotYetEnded();

    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();


    /// Create a simple auction with `biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `beneficiaryAddress`.
    constructor(
        uint biddingTime,
        address payable beneficiaryAddress
        ) {
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() external payable {
        // No arguments are necessary, all
        // information is already part of
        // the transaction. The keyword payable
        // is required for the function to
        // be able to receive Ether.

        // Revert the call if the bidding
        // period is over.
        if (block.timestamp > auctionEndTime)
            revert AuctionAlreadyEnded();

        // If the bid is not higher, send the
        // Ether back (the revert statement
        // will revert all changes in this
        // function execution including
        // it having received the Ether).
        if (msg.value <= highestBid)
        revert BidNotHighEnough(highestBid);

        if (highestBid != 0) {
            // Sending back the Ether by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their Ether themselves.
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);

    }





    










}