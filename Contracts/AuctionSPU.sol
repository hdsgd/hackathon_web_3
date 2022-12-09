// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice This contract is gas and security simple optimized, further improvements are appreciated
/// @dev The main method bid is only acessible via _whitelist array mainly to avoid Denial of Service
/// @custom:project This contract is part of a entire project , including a AuctionFactory contract

/// @notice Interface with ERC-721 standard
/// @dev The interface is used for transfering the NFT to e from the smart contract
interface IERC721 {
    /** @notice Safely transfer tokenId token from from to to,
     *   checking first that contract recipients are aware of the ERC721
     *   protocol to prevent tokens from being forever locked.
     */
    /// @param from The address that initially holds a NFT
    /// @param to The receiver of the NFT
    /// @param tokenId ID of the token
    function safeTransferFrom(address from, address to, uint tokenId) external;

    /// @notice Transfers tokenId token from from to to
    /// @param from The address that initially holds a NFT
    /// @param to The receiver of the NFT
    /// @param tokenId ID of the token
    /** @dev Optional use, in this contract is used in the startAuction method by the owner ,
     *   the owner is already prepared for ERC-721
     */
    function transferFrom(address from, address to, uint tokenId) external;
}

/// @title Auction for real-state NFT sell
/// @author Gustavo Henrique / gustavo@useinsignia.com
/// @notice AuctionSPU contract
contract AuctionSPU {
    /// @notice Events for display in on the blockchain all methods calls

    /// @notice Auction started
    event StartAuction();
    /// @notice New bid made
    event Bid(address indexed sender, uint amount);
    /// @notice Auction ended
    event EndAuction(address winner, uint amount);
    /// @notice Auction paused
    event PauseAuction(address pauser);
    /// @notice Auction unpaused
    event UnpauseAuction(address pauser);
    /// @notice Amount returned for last highest bidder when highest bidder changed
    event Cashback(address indexed bidder, uint amount);
    /// @notice New address added to whitelist
    event SetWhitelistByAddress(address indexed account, bool enable);
    /// @notice Fee of the auction sent to feeAddress
    event FeePayment(address indexed feeAddress, uint totalFee);
    /// @notice Bid paid for the seller
    event BidPayment(address indexed seller, uint highestBid);

    IERC721 public nft;
    uint public nftId;
    address payable public seller;
    address payable public feeAddress;
    address public docsRegister;
    uint public docsProcess;
    uint public endAt;
    bool public started;
    bool public ended;
    bool public paused;
    uint public numberOfBids;
    uint private transactionFee;
    uint public constant FEE_BASE = 10000;
    uint public totalFee;
    address public highestBidder;
    uint public highestBid;

    struct Bidders {
        uint totalValue;
        uint realValue;
        uint portion;
        uint clientScore;
        uint downpay;
    }

    mapping(address => Bidders) public receivedBids;
    mapping(address => bool) private _whitelist;

    /**
     * @dev Sets the values for :
     *  {_nft} -> Address of the nft
     *  {_docsRegister} -> The smart contract that stores all the real-state documentation
     *  {_docsProcess} -> The SPU process identifier
     *  {_feeAddres} -> The address that will receives the fees o the auction
     *  {_nftId} -> NFT id, in case of collection, default value 0
     *  {_startingBid} -> The initial bid value
     *  {_period} -> Duration of the auction, timestamp pattern
     *  {_transactionFee} -> Fee charged on every bid , e.g. 100 = 1%
     *
     */

    constructor(
        address _nft,
        address _docsRegister,
        uint _docsProcess,
        address _feeAddres,
        uint _nftId,
        uint _startingBid,
        uint _period,
        uint _transactionFee
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;

        seller = payable(msg.sender);
        feeAddress = payable(_feeAddres);
        highestBid = _startingBid;
        endAt = _period;
        transactionFee = _transactionFee;
        _docsRegister = _docsRegister;
        _docsProcess = docsProcess;
    }

    /**
     * @dev Modifier that checks that if account is the contract owner. Reverts
     * with a standardized message.
     */
    modifier onlyOwner() {
        require(msg.sender == seller, "Sender is not owner");
        _;
    }

    /**
     * @dev Modifier that checks if the auction is paused. Reverts
     * with a standardized message.
     */
    modifier auctionPaused() {
        require(!paused, "Auction Paused");
        _;
    }

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message.
     */
    modifier auctionStarted() {
        require(started, "Not Started Yet");
        _;
    }

    /// @notice Function to receive Ether when msg.data is empty
    receive() external payable onlyOwner {}

    /// @notice Function to receive Ether when msg.data is not empty
    fallback() external payable onlyOwner {}

    /// @notice Function to get the balance of the contract
    /// @return Returns the native token amount inside this contract.
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    /// @notice Start the auction
    /// @dev The owner of the NFT MUST hold the NFT before call this method
    function startAuction() external onlyOwner {
        require(!started, "Already Started");

        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;

        emit StartAuction();
    }

    /// @notice End the auction
    /// @dev Once ended only no more bids are allowed , no transfers are done yet
    function endAuction() external onlyOwner auctionStarted {
        require(block.timestamp >= endAt, "Not Ended");
        require(!ended, "Already Ended");

        ended = true;

        emit EndAuction(highestBidder, highestBid);
    }

    /// @notice Pause the auction
    /// @dev Once paused, this method neither restart the autcion or change any bid
    function pauseAuction() external onlyOwner {
        require(!paused, "Already Paused");

        paused = true;

        emit PauseAuction(msg.sender);
    }

    /// @notice Unpause the auction
    /// @dev Once unpaused, this method neither restart the autcion or change any bid
    function unpauseAuction() external onlyOwner {
        require(paused, "Already Running");

        paused = false;

        emit UnpauseAuction(msg.sender);
    }

    /// @notice Method for placing bids
    /// @param _totalValue The total amount of the bid
    /** @param _realValue The actual bid , calculated externally with _totalValue , _portion
     *   and _clientScore parameters
     */
    /// @param _portion The number of payments agreed
    /// @param _clientScore The realite payment score of the bidder
    /** @dev Is mandatory to add any bidder previously in the _whitelist array
        Method steps:
        {1} - Verifications
        {2} - Calculate transaction fee
        {3} - Refund for the last highestBidder
        {4} - Store bid data
        {5} - Store highest bid
        {6} - Emit an event for newBid
    */
    function newBid(
        uint _totalValue,
        uint _realValue,
        uint _portion,
        uint _clientScore
    ) external payable auctionStarted auctionPaused {
        require(block.timestamp < endAt, "Already ended");
        require(msg.sender != seller, "Seller not allowed");
        require(_isWhitelist(msg.sender), "Permission denied");
        require(_realValue > highestBid, "Lower Bid");

        uint fee = (msg.value / FEE_BASE) * transactionFee;
        totalFee += fee;

        cashback(highestBidder, receivedBids[highestBidder].downpay);

        if (receivedBids[msg.sender].totalValue != 0) {
            receivedBids[msg.sender].downpay = msg.value - fee;
            receivedBids[msg.sender].realValue = _realValue;
            receivedBids[msg.sender].totalValue = _totalValue;
            receivedBids[msg.sender].portion = _portion;
            receivedBids[msg.sender].clientScore = _clientScore;
        } else {
            Bidders memory b;
            b.downpay = msg.value - fee;
            b.totalValue = _totalValue;
            b.realValue = _realValue;
            b.portion = _portion;
            b.clientScore = _clientScore;
            receivedBids[msg.sender] = b;
        }

        highestBidder = msg.sender;
        highestBid = _realValue;
        numberOfBids += 1;

        emit Bid(msg.sender, _realValue);
    }

    /// @notice Method for return funds
    /// @param _receiver The refund address
    /// @param _amount The refund tokens amount
    function cashback(address _receiver, uint _amount) internal {
        (bool callSuccess, ) = payable(_receiver).call{value: _amount}("");
        require(callSuccess, "Return funds failed");

        receivedBids[msg.sender].downpay = 0;
        receivedBids[msg.sender].totalValue = 0;
        receivedBids[msg.sender].portion = 0;
        receivedBids[msg.sender].clientScore = 0;

        emit Cashback(_receiver, _amount);
    }

    /// @notice Method for close the auction
    /** @dev When this method is called the auction is finally closed
        Method steps:
        {1} - Verifications
        {2} - Safe Transfer the NFT for the highestBidder
        {3} - Pay the total fee of the auction
        {4} - Pay the highestBid to the seller
        {5} - Emit an event for newBid
    */
    function closeAuction() external onlyOwner {
        require(block.timestamp >= endAt, "Not Ended");
        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);

            (bool callSuccessFee, ) = payable(feeAddress).call{value: totalFee}(
                ""
            );
            require(callSuccessFee, "Return fee funds failed");

            emit FeePayment(feeAddress, totalFee);

            (bool callSuccess, ) = payable(seller).call{value: highestBid}("");
            require(callSuccess, "Return funds failed");

            emit BidPayment(seller, highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);

            (bool callSuccessFee, ) = payable(feeAddress).call{value: totalFee}(
                ""
            );
            require(callSuccessFee, "Return fee funds failed");

            emit FeePayment(feeAddress, totalFee);

            (bool callSuccess, ) = payable(seller).call{value: highestBid}("");
            require(callSuccess, "Return funds failed");

            emit BidPayment(seller, highestBid);
        }
    }

    /// @notice Method to insert new address to the whitelist
    /// @param _account The address to insert
    /// @param enable True to guarantee privilegies, false to remove privilegies
    function setWhitelist(address _account, bool enable) external onlyOwner {
        _whitelist[_account] = enable;
        emit SetWhitelistByAddress(_account, enable);
    }

    /// @notice Internal method to check if address has privilegies
    /// @param _account Consultant address
    /// @return Boolean of the privilege setted
    function _isWhitelist(address _account) private view returns (bool) {
        return _whitelist[_account];
    }

    /// @notice Public method to check if address has privilegies
    /// @param _account Consultant address
    /// @return Boolean of the privilege setted
    function isWhitelist(address _account) public view returns (bool) {
        return _isWhitelist(_account);
    }
}
