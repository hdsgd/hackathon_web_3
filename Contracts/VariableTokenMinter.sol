// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract VariableToken is ERC20, ERC20Burnable, ERC20Permit {

    address payable public owner;
    
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        address payable _owner

    ) ERC20(_tokenName, _tokenSymbol) ERC20Permit(_tokenName) {
        owner = _owner; 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function getAddress() public view returns(address _tokenAddress){
        _tokenAddress = address(this);
    }
}