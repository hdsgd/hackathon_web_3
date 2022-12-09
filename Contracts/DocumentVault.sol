// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract DocumentVault {

    event NewDocAdded(address indexed publisher , string docProcess);
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

    constructor(
        uint _minimunFee

    ){
        owner = payable(msg.sender);        
        minimunFee = _minimunFee;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable onlyOwner{}

    // Fallback function is called when msg.data is not empty
    fallback() external payable onlyOwner{}

    

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }


    function addNewDoc(
        string memory _typeOfDocument,    
        string memory _docsURI,
        string memory _docsURIChesksum,        
        string memory _publisherResponsible,
        string memory _docProcess
    ) public payable {
        require(msg.value > minimunFee , "Minimum fee needed to register");
        require(_isWhitelist(msg.sender), "Permission denied");

        Documentation memory docs;
        docs.typeOfDocument = _typeOfDocument;
        docs.docsURI = _docsURI;
        docs.docsURIChesksum = _docsURIChesksum;
        docs.publisherResponsible = _publisherResponsible;
        registeredDocs[_docProcess] = docs;

        emit NewDocAdded(msg.sender , _docProcess);
    }

    function setWhitelist(address _account, bool enable) external  onlyOwner{
        _allowedPublishers[_account] = enable;
        emit SetWhitelistByAddress(_account, enable);
    }

    function _isWhitelist(address _account) private view returns (bool) {
        return _allowedPublishers[_account];
    }

    
    function isWhitelist(address _account) public view returns (bool) {
        return _isWhitelist(_account);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }


}