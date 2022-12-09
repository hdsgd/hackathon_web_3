// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice This contract is gas and security simple optimized, further improvements are appreciated
/// @dev The main purpose of this contract is to store and secure real estate documents to support sells
/// @custom:project This contract is part of a entire project

/// @title Vault for store real estate documents
/// @author Gustavo Henrique / gustavo@useinsignia.com
/// @notice DocumentVault contract
contract DocumentVault {
    /// @notice Events for display in on the blockchain all methods calls

    /// @notice New document added
    event NewDocAdded(address indexed publisher, string docProcess);
    /// @notice New address added to allowed publishers
    event SetWhitelistByAddress(address indexed account, bool enable);

    address payable public owner;
    uint minimunFee;

    struct Documentation {
        string typeOfDocument;
        string docsURI;
        string docsURIChesksum;
        string publisherResponsible;
    }

    mapping(string => Documentation) public registeredDocs;

    mapping(address => bool) private _allowedPublishers;

    /**
     * @dev Sets the values for :
     *  {minimunFee} -> The fee charged on every new document added
     *
     */
    constructor(uint _minimunFee) {
        owner = payable(msg.sender);
        minimunFee = _minimunFee;
    }

    /// @notice Function to receive Ether when msg.data is empty
    receive() external payable onlyOwner {}

    /// @notice Function to receive Ether when msg.data is not empty
    fallback() external payable onlyOwner {}

    /**
     * @dev Modifier that checks that if account is the contract owner. Reverts
     * with a standardized message.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

    /// @notice Method for adding new documentation
    /// @param _typeOfDocument Type of the document added
    /// @param _docsURI The IPFS CID of the tree documentation  e.g. Auction_Docs
    /// @param _docsURIChesksum The hash of the tree documentation, certify the integrity of the data
    /// @param _publisherResponsible The responsible for publishing the documentation
    /// @param _docProcess The string to retrieve the data, should be related to the context of the documentation
    /// @dev The owner of the contract could insert a fee to publish data, default 0 , e.g. 100 = 1%

    function addNewDoc(
        string memory _typeOfDocument,
        string memory _docsURI,
        string memory _docsURIChesksum,
        string memory _publisherResponsible,
        string memory _docProcess
    ) public payable {
        require(msg.value > minimunFee, "Minimum fee needed to register");
        require(_isWhitelist(msg.sender), "Permission denied");

        Documentation memory docs;
        docs.typeOfDocument = _typeOfDocument;
        docs.docsURI = _docsURI;
        docs.docsURIChesksum = _docsURIChesksum;
        docs.publisherResponsible = _publisherResponsible;
        registeredDocs[_docProcess] = docs;

        emit NewDocAdded(msg.sender, _docProcess);
    }

    /// @notice Method to insert new address to the whitelist
    /// @param _account The address to insert
    /// @param enable True to guarantee privilegies, false to remove privilegies
    function setWhitelist(address _account, bool enable) external onlyOwner {
        _allowedPublishers[_account] = enable;
        emit SetWhitelistByAddress(_account, enable);
    }

    /// @notice Internal method to check if address has privilegies
    /// @param _account Consultant address
    /// @return Boolean of the privilege setted
    function _isWhitelist(address _account) private view returns (bool) {
        return _allowedPublishers[_account];
    }

    /// @notice Public method to check if address has privilegies
    /// @param _account Consultant address
    /// @return Boolean of the privilege setted
    function isWhitelist(address _account) public view returns (bool) {
        return _isWhitelist(_account);
    }

    /// @notice Public method to retrieve contract's balance
    /// @return uint of the total native token balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
