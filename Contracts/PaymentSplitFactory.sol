// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./PaymentSplit.sol";

contract PaymentSplitFactory{

        event NewPaymentSplitGenerated(address creator, address newTokenAddress);

        PaymentSplit[] public _paymentSplit;

        mapping(address => uint) public _indexOfPaymentSplitByAddress;

        address payable public owner;

        constructor(){
            owner = payable(msg.sender); 
        }

        modifier onlyOwner() {
            require(msg.sender == owner, "Sender is not owner");
            _;
        }

        function createPaymentTokens(
            
            address payable _owner

        )public onlyOwner{
            PaymentSplit newSplitPayment = new PaymentSplit(                
                _owner
            );
            
            _paymentSplit.push(newSplitPayment);
            _indexOfPaymentSplitByAddress[newSplitPayment.getAddress()] = (_paymentSplit.length - 1);
            emit NewPaymentSplitGenerated(msg.sender, newSplitPayment.getAddress());
        }                

}