// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice This contract is gas and security simple optimized, further improvements are appreciated
/// @dev The main purpose of this contract is split payments to registered addresses
/// @custom:project This contract is part of a entire project

/// @title Payment sppliter
/// @author Gustavo Henrique / gustavo@useinsignia.com
/// @notice PaymentSplit contract
contract PaymentSplit {
    /// @notice Payment sent to recipients
    event FeePaid(address _from, uint _amount);

    address payable public owner;
    mapping(address => uint) public _recipients;
    address payable[] public recipients;
    uint public constant FEE_BASE = 10000;

    constructor(address payable _owner) {
        owner = _owner;
    }

    /**
     * @dev Modifier that checks that if account is the contract owner. Reverts
     * with a standardized message.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

    /// @notice Method for adding new recipients
    /// @param _addrs The address of the recipient
    /// @param _amount The percentage amount to pay
    /// @dev The total sum of percentage is 100%, in this way be aware of the _amount
    function addRecipients(
        address payable _addrs,
        uint _amount
    ) public onlyOwner {
        _recipients[_addrs] = _amount;
        recipients.push(_addrs);
    }

    /// @notice Method to retrieve the amount to pay for a recipient
    /// @param _addrs The address of the recipient
    /// @return fee The percentage amount to pay
    function getFeeByAddress(
        address payable _addrs
    ) public view returns (uint fee) {
        fee = _recipients[_addrs];
    }

    /// @notice Public method to retrieve the total amount registered
    /// @return totalFee The total percentage amount to pay
    function getTotalFee() public view returns (uint totalFee) {
        for (uint i = 0; i < recipients.length; i++) {
            totalFee += _recipients[recipients[i]];
        }
    }

    /// @notice Internal method to retrieve the total amount registered
    /// @return totalFee The total percentage amount to pay
    function _getTotalFee() internal view returns (uint totalFee) {
        for (uint i = 0; i < recipients.length; i++) {
            totalFee += _recipients[recipients[i]];
        }
    }

    /// @notice Method for start the payment splitted
    /** @dev The total sum of percentage is 100%, in this way be aware of the _amount,
     *   a possible improvement is use getTotalFee verification
     */
    function paySplitFee() public onlyOwner {
        require(address(this).balance != 0, "Not enugh funds");
        require(_getTotalFee() == FEE_BASE, "Payment not split entirely");

        uint256 share = 0;
        uint totalFeeValue = address(this).balance;

        for (uint i = 0; i < recipients.length; i++) {
            share = (totalFeeValue / FEE_BASE) * _recipients[recipients[i]];
            (bool callSuccessFee, ) = payable(recipients[i]).call{value: share}(
                ""
            );
            require(callSuccessFee, "Return fee funds failed");
            emit FeePaid(recipients[i], share);
        }
    }

    /// @notice Public method to retrieve contract's address
    /// @return _splitPaymentAddress Address of the payment sppliter contract
    /// @dev This method supports PaymentSplitFactory contract
    function getAddress() public view returns (address _splitPaymentAddress) {
        _splitPaymentAddress = address(this);
    }

    /// @notice Function to receive Ether when msg.data is empty
    receive() external payable onlyOwner {}

    /// @notice Function to receive Ether when msg.data is not empty
    fallback() external payable onlyOwner {}
}
