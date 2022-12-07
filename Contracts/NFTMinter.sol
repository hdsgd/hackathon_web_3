// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTProperty is ERC721 {   

    address owner;
    string IPFSBaseURI; 

    constructor(
        string memory _IPFSBaseURI        

    ) ERC721 ("INSG Blockchain" , "ISGB") {
        owner = payable(msg.sender);
        IPFSBaseURI = _IPFSBaseURI; 
    }    

    modifier onlyOwner() {
        require(msg.sender == owner, "Is not owner");
        _;
    }    

    function _baseURI() internal view override returns (string memory) {
        return IPFSBaseURI;
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner{
        _safeMint(to, tokenId);
    }    

}