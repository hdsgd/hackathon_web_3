// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice This contract is gas and security simple optimized, further improvements are appreciated
/// @dev The main purpose of this contract is to create new payment spliter contracts
/// @custom:project This contract is part of a entire project

/// @notice Standard import for customizable payment spliter
/// @dev The standard was developed by our team
import "https://github.com/hdsgd/hackathon_web_3/blob/main/Contracts/PaymentSplit.sol";

/// @title Factory to create payment spliter contracts
/// @author Gustavo Henrique / gustavo@useinsignia.com
/// @notice PaymentSplitFactory contract
contract PaymentSplitFactory {
    /// @notice New contract minted
    event NewPaymentSplitGenerated(address creator, address newTokenAddress);

    PaymentSplit[] public _paymentSplit;

    mapping(address => uint) public _indexOfPaymentSplitByAddress;

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    /**
     * @dev Modifier that checks that if account is the contract owner. Reverts
     * with a standardized message.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

    /// @notice Method for creating new payment spliter contract
    /// @dev This contract creates other contracts, be aware of the address of the payment spliter generated
    function createPaymentTokens(address payable _owner) public onlyOwner {
        PaymentSplit newSplitPayment = new PaymentSplit(_owner);

        _paymentSplit.push(newSplitPayment);
        _indexOfPaymentSplitByAddress[
            newSplitPayment.getAddress()
        ] = (_paymentSplit.length - 1);
        emit NewPaymentSplitGenerated(msg.sender, newSplitPayment.getAddress());
    }
}
