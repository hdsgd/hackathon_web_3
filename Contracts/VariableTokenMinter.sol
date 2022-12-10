// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice This contract is gas and security simple optimized, further improvements are appreciated
/// @dev The main purpose of this contract is generate a customized ERC-20 token to split real estate ownership
/// @custom:project This contract is part of a entire project

/// @notice Standard import for ERC-20 methods
/// @dev The standard is used to mint new tokens
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/** @dev The standard that allows token holders to destroy both their own tokens
 *   and those that they have an allowance for
 */
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
/// @dev The standard allow approvals to be made via signatures
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

/// @title Variable token to allow split real estate ownership
/// @author Gustavo Henrique / gustavo@useinsignia.com
/// @notice VariableToken contract
contract VariableTokenMinter is ERC20, ERC20Burnable, ERC20Permit {
    address payable public owner;

    /**
     * @dev Sets the values for :
     *  {_tokenName} -> The token name , e.g. bitcoin
     *  {_tokenSymbol} -> The symbol of the token , e.g. BTC
     *
     */
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        address payable _owner
    ) ERC20(_tokenName, _tokenSymbol) ERC20Permit(_tokenName) {
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

    /// @notice Public method to mint new tokens
    /// @param to The address that will receive new tokens
    /// @param amount The total amount that will be minted
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @notice Public method to retrieve contract's address
    /// @return _tokenAddress Address of the token
    /// @dev This method supports VariableTokenFactory contract
    function getAddress() public view returns (address _tokenAddress) {
        _tokenAddress = address(this);
    }
}
