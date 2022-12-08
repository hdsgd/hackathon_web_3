// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


/*

O que est programa faz?

registra o tipo de documento, URI (IPFS) , checksum do URI  e responsável 
retorna os dados para o numero do processo


 521B582011D8EE7F6A80500C42CD997BAD7EE70366031898DE008E17CA59CB2BE2AE919344B63D2B23520A289E7793C5BF273B56E61BC0E133ED0A10F3A697AA
doc 123456ABCDE


*/

contract DocumentVault {

    event NewDocAdded(address indexed publisher , string docProcess);
    event SetWhitelistByAddress(address indexed account, bool enable);

    address payable public owner;
    uint minimunFee;

    struct Documentation {              // Process 123456ABCDE
        string typeOfDocument;          // Matricula Imovel
        string docsURI;                 // https://ipfs.io/ipfs/QmQScMLzQbXoeZxBE9P8Y7oAyo1fZ2bq1QimeHiJ12JanU             
        string docsURIChesksum;         // 521B582011D8EE7F6A80500C42CD997BAD7EE70366031898DE008E17CA59CB2BE2AE919344B63D2B23520A289E7793C5BF273B56E61BC0E133ED0A10F3A697AA   
        string publisherResponsible;    // Gustavo Henrique
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