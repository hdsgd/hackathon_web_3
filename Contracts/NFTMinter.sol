// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice This contract is gas and security simple optimized, further improvements are appreciated
/// @dev The main purpose of this contract is to create a ERC-721 customizable factory
/// @custom:project This contract is part of a entire project

/// @notice Standard import for ERC-721 methods
/// @dev The standard is used to safe mint the token
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title NFT Minter for real state salles
/// @author Gustavo Henrique / gustavo@useinsignia.com
/// @notice NFTMinter contract
contract NFTMinter is ERC721 {
    address owner;
    string IPFSBaseURI;

    /**
     * @dev Sets the values for :
     *  {_IPFSBaseURI} -> The IPFS address that stores NFT files
     *  {_nftName} -> The name of the NFT
     *  {_nftSymbol} -> The symbol attached to the nft
     *
     */
    constructor(
        string memory _IPFSBaseURI,
        string memory _nftName,
        string memory _nftSymbol
    ) ERC721(_nftName, _nftSymbol) {
        owner = payable(msg.sender);
        IPFSBaseURI = _IPFSBaseURI;
    }

    /**
     * @dev Modifier that checks that if account is the contract owner. Reverts
     * with a standardized message.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Is not owner");
        _;
    }

    /// @notice Function to get the URI on the IPFS network
    /// @return Returns string, the CID on IPFS
    function _baseURI() internal view override returns (string memory) {
        return IPFSBaseURI;
    }

    /// @notice Function safety mint the NFT
    /// @param to The address of the receiver on the NFT
    /// @param tokenId The of the minted NFT, default 0
    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}
