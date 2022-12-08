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
 1 - Criar NFT teste (+30min) ok
 2 - Inserir documentação (IPFS) Leilão (+45min)
 3 - Criar mintador de leilão (+2hr)
 4 - Criar mintador de NFT (+1hr) ok
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
    event Cashback(address indexed bidder, uint amount);
    event SetWhitelistByAddress(address indexed account, bool enable);
    event FeePayment(address indexed feeAddress ,uint totalFee);
    event BidPayment(address indexed seller , uint highestBid);

    /*
        ERC-721 Variables
    */
    IERC721 public nft;
    uint public nftId;

    /*
        Auction parameters
    */

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
        uint downpay;      
    }    

    mapping(address => Bidders) public receivedBids;
    mapping(address => bool) private _whitelist;

    /*
        Constructor
        _nft -> Address of the nft
        _nftID -> If the nft is part of a collection, default value 0
        _startingBid -> The start value of the auction
        _period -> Duration of the auction , timestampvalue
        seller -> Address of the seller, by default SPU
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
        endAt = _period; //timestamp
        transactionFee = _transactionFee; // 10000 -> 0.1%
        _docsRegister = _docsRegister;
        _docsProcess = docsProcess;
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
    receive() external payable onlyOwner{}

    // Fallback function is called when msg.data is not empty
    fallback() external payable onlyOwner{}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    /*
        Start the auction
    */

    function startAuction() external onlyOwner {
        require(!started, "Already Started");

        nft.transferFrom(msg.sender, address(this), nftId);
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



    // bid -> _realvalue usar esse valor
    // descontar taxa é do msg.value
    // cashback  

    // Adicionar whitelist pra bid
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

        uint fee = ( msg.value / FEE_BASE) * transactionFee;
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

    function withdraw() external {
        require(!(msg.sender == highestBidder), "Your Bid is the higher");
        require(receivedBids[msg.sender].downpay != 0, "No bids founded");

        cashback(msg.sender, receivedBids[msg.sender].downpay);

        receivedBids[msg.sender].downpay = 0;
        receivedBids[msg.sender].totalValue = 0;
        receivedBids[msg.sender].portion = 0;
        receivedBids[msg.sender].clientScore = 0;

        emit Withdraw(msg.sender, receivedBids[msg.sender].downpay);
    }

    function cashback(address _receiver, uint _amount) internal{
        (bool callSuccess, ) = payable(_receiver).call{value: _amount}("");
        require(callSuccess, "Return funds failed");

        receivedBids[msg.sender].downpay = 0;
        receivedBids[msg.sender].totalValue = 0;
        receivedBids[msg.sender].portion = 0;
        receivedBids[msg.sender].clientScore = 0;

        emit Cashback(_receiver, _amount);
    }    

    function closeAuction () external onlyOwner{
        require(block.timestamp >= endAt, "Not Ended");
        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            
            (bool callSuccessFee, ) = payable(feeAddress).call{value: totalFee}("");
            require(callSuccessFee, "Return fee funds failed");
            
            emit FeePayment(feeAddress , totalFee);
            
            (bool callSuccess, ) = payable(seller).call{value: highestBid}("");
            require(callSuccess, "Return funds failed");

            emit BidPayment(seller , highestBid);
            
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
            
            (bool callSuccessFee, ) = payable(feeAddress).call{value: totalFee}("");
            require(callSuccessFee, "Return fee funds failed");

            emit FeePayment(feeAddress , totalFee);
            
            (bool callSuccess, ) = payable(seller).call{value: highestBid}("");
            require(callSuccess, "Return funds failed");

            emit BidPayment(seller , highestBid);
        }
    } 

    function setWhitelist(address _account, bool enable) external  onlyOwner{
        _whitelist[_account] = enable;
        emit SetWhitelistByAddress(_account, enable);
    }

    
    function _isWhitelist(address _account) private view returns (bool) {
        return _whitelist[_account];
    }

    
    function isWhitelist(address _account) public view returns (bool) {
        return _isWhitelist(_account);
    }
}
