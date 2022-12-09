// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/// @notice This contract is gas and security simple optimized, further improvements are appreciated
/// @dev The main purpose of this contract is to create new ERC-20 tokens to support sells
/// @custom:project This contract is part of a entire project

/// @notice Standard import for customizable ERC-20 mint
/// @dev The standard was developed by our team
import "https://github.com/hdsgd/hackathon_web_3/blob/main/Contracts/VariableTokenMinter.sol";

/// @title Factory to create new ERC-20 Tokens
/// @author Gustavo Henrique / gustavo@useinsignia.com
/// @notice VariableTokenFactory contract
contract VariableTokenFactory {
    /// @notice New token minted
    event NewTokenGenerated(address creator, address newTokenAddress);

    VariableToken[] public _paymentTokens;

    mapping(address => uint) public _indexOfTokensByAddress;

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

    /// @notice Method for creating new custom tokens
    /// @param _tokenName  The token name , e.g. bitcoin
    /// @param _tokenSymbol The symbol of the token , e.g. BTC
    /// @dev This contract creates other contracts, be aware of the address of the tokens generated

    function createPaymentTokens(
        string memory _tokenName,
        string memory _tokenSymbol,
        address payable _owner
    ) public onlyOwner {
        VariableToken newToken = new VariableToken(
            _tokenName,
            _tokenSymbol,
            _owner
        );

        _paymentTokens.push(newToken);
        _indexOfTokensByAddress[newToken.getAddress()] = (_paymentTokens
            .length - 1);
        emit NewTokenGenerated(msg.sender, newToken.getAddress());
    }
}
