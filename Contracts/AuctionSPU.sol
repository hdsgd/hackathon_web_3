// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
    Creatd by : Gustavo Henrique
    Email : gustavo@useinsignia.com
    This auction is created to perform a NFT sell, correspondig to a government property. This code
    is a small part of an entire project. Any questions could be redirect to my email 
*/
// TODO
/*
 1 - Criar NFT teste (+30min)
 2 - Inserir documentação (IPFS) Leilão (+45min)
 3 - Criar mintador de leilão (+2hr)
 4 - Criar mintador de NFT (+1hr)
 5 - Criar contrato de documentação (+1Dia)
 6 - Criar mintador de documentação (+2hr)
*/

/*
    ERC-721 interface to acess usable functions as safeTransferFrom
*/

interface IERC721 {
    function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address, address, uint) external;
}

/*
    Auction contract 
*/

contract AuctionSPU {


    /*
        Events for external reading
    */
    event StartAuction();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event EndAuction(address winner, uint amount);
    event PauseAuction(address pauser);
    event UnpauseAuction(address pauser);

    /*
        ERC-721 Variables
    */
    IERC721 public nft;
    uint public nftId;

    /*
        Auction parameters
    */

    address payable public seller;
    uint public endAt;
    bool public started;
    bool public ended;
    bool public paused;
    uint public numberOfBids;
    uint private transactionFee;
    uint public constant FEE_BASE = 10000;
    uint public totalFee;

    /*
        Bids parameters
    */
    address public highestBidder;
    uint public highestBid;

    struct Bidders {
        uint totalValue;
        uint realValue;
        uint portion;
        uint clientScore;
    }

    struct FeeReceivers {
        address recipient;
        uint fee;
    }

    mapping(address => Bidders) public receivedBids;
    mapping(address => FeeReceivers) public feeReceivers;

    /*
        Constructor
        _nft -> Address of the nft
        _nftID -> If the nft is part of a collection, default value 0
        _startingBid -> The start value of the auction
        _period -> Duration of the auction , timestampvalue
        seller -> Address of the seller, by default SPU
    */
    constructor(
        //address _nft,
        //uint _nftId,
        uint _startingBid,
        uint _period,
        uint _transactionFee
    ) {
        //nft = IERC721(_nft);
        //nftId = _nftId;

        seller = payable(msg.sender);
        highestBid = _startingBid;
        endAt = _period; //timestamp
        transactionFee = _transactionFee; // 10 -> 0.1%
    }

    modifier onlyOwner() {
        require(msg.sender == seller, "Sender is not owner");
        _;
    }

    modifier auctionPaused() {
        require(!paused, "Auction Paused");
        _;
    }

    modifier auctionStarted() {
        require(started, "Not Started Yet");
        _;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    /*
        Start the auction
    */

    function startAuction() external onlyOwner {
        require(!started, "Already Started");

        //nft.transferFrom(msg.sender, address(this), nftId);
        started = true;

        emit StartAuction();
    }

    /*
        End the auction
    */
    function endAuction() external onlyOwner auctionStarted {
        require(block.timestamp >= endAt, "Not Ended");
        require(!ended, "Already Ended");

        ended = true;        

        emit EndAuction(highestBidder, highestBid);
    }

    /*
        Pause the auction
    */

    function pauseAuction() external onlyOwner {
        require(!paused, "Already Paused");

        paused = true;

        emit PauseAuction(msg.sender);
    }

    /*
        Unpause the auction
    */

    function unpauseAuction() external onlyOwner {
        require(paused, "Already Running");

        paused = false;

        emit UnpauseAuction(msg.sender);
    }

    /*
        Method to receive bids
    */

    function newBid(
        uint _totalValue,
        uint _realValue,
        uint _portion,
        uint _clientScore
    ) external payable auctionStarted auctionPaused {
        require(block.timestamp < endAt, "Already ended");
        require(msg.value > highestBid, "Lower Bid");
        require(msg.sender != seller, "Seller not allowed");
        
        uint fee = (_totalValue / FEE_BASE) * transactionFee;
        totalFee += fee;   

        cashback(highestBidder, receivedBids[highestBidder].totalValue); 

        if (receivedBids[msg.sender].totalValue != 0) {           
                    
           
            receivedBids[msg.sender].totalValue = _totalValue - fee;
            receivedBids[msg.sender].realValue = _realValue;
            receivedBids[msg.sender].portion = _portion;
            receivedBids[msg.sender].clientScore = _clientScore;

        } else {           

            Bidders memory b;
            b.totalValue += _totalValue - fee;            
            b.realValue += _realValue;
            b.portion = _portion;
            b.clientScore = _clientScore;
            receivedBids[msg.sender] = b;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        numberOfBids += 1;

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        require(!(msg.sender == highestBidder), "Your Bid is the higher");
        require(receivedBids[msg.sender].totalValue != 0, "No bids founded");

        cashback(msg.sender, receivedBids[msg.sender].totalValue);

        receivedBids[msg.sender].totalValue = 0;
        receivedBids[msg.sender].realValue = 0;
        receivedBids[msg.sender].portion = 0;
        receivedBids[msg.sender].clientScore = 0;

        emit Withdraw(msg.sender, receivedBids[msg.sender].totalValue);
    }

    function cashback(address _receiver, uint _amount) internal{
        (bool callSuccess, ) = payable(_receiver).call{value: _amount}("");
        require(callSuccess, "Return funds failed");
    }

    function addNewFeeReceiver(address _newRecipient, uint8 _fee) external onlyOwner{
        require( (transactionFee + _fee) <= 100 , "100% of the fee already alocated");
        FeeReceivers memory fR;
        fR.recipient = _newRecipient;
        fR.fee = _fee;
        transactionFee += _fee;
        feeReceivers[msg.sender] = fR;
    }

    function closeAuction () external onlyOwner{
        if (highestBidder != address(0)) {
            //nft.safeTransferFrom(address(this), highestBidder, nftId);
            /*
            (bool callSuccess, ) = payable(feeAddress).call{value: totalFee}("");
            require(callSuccess, "Return funds failed");
            */
            (bool callSuccess, ) = payable(seller).call{value: highestBid}("");
            require(callSuccess, "Return funds failed");
            
        } else {
            //nft.safeTransferFrom(address(this), seller, nftId);
            /*
            (bool callSuccess, ) = payable(feeAddress).call{value: totalFee}("");
            require(callSuccess, "Return funds failed");
            */
            (bool callSuccess, ) = payable(seller).call{value: highestBid}("");
            require(callSuccess, "Return funds failed");
        }
    } 
}
