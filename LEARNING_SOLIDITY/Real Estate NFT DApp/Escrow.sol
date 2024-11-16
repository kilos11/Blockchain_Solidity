//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint258 _id
    )  external;   
}

contract Escrow {
    address nftAddress;
    address payable public seller;
    address public inspctor;
    address public lender;

    constructor (address _nftAddress,
                 address payable _seller,
                 address _inspector,
                 address lender) {
                    nftAddress = _nftAddress;
                    seller = _seller;
                    inspctor = _inspector;
                    lender = _lender;

    }


}