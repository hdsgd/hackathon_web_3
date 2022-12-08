// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./PaymentSplit.sol";

contract PaymentSplitFactory{

        event NewTokenGenerated(address creator, address newTokenAddress);

        PaymentSplit[] public _paymentTokens;

        mapping(address => uint) public _indexOfTokensByAddress;

        address payable public owner;

        constructor(){
            owner = payable(msg.sender); 
        }

        modifier onlyOwner() {
            require(msg.sender == owner, "Sender is not owner");
            _;
        }

        function createPaymentTokens(
            string memory _tokenName,
            string memory _tokenSymbol,
            address payable _owner

        )public onlyOwner{
            PaymentSplit newToken = new PaymentSplit(                
                _owner
            );
            
            _paymentTokens.push(newToken);
            _indexOfTokensByAddress[newToken.getAddress()] = (_paymentTokens.length - 1);
            emit NewTokenGenerated(msg.sender, newToken.getAddress());
        }                

}