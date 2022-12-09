// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract PaymentSplit{

        event FeePaid(address _from, uint _amount);

        address payable public owner;
        mapping(address => uint) public _recipients;
        address payable [] public recipients;
        uint public constant FEE_BASE = 10000;
        
        constructor(
        
        address payable _owner

        ) {
            owner = _owner; 
        }

        modifier onlyOwner() {
            require(msg.sender == owner, "Sender is not owner");
            _;
        }
        
        function addRecipients(address payable _addrs , uint _amount)public onlyOwner{
            
            _recipients[_addrs] = _amount;
            recipients.push(_addrs);

        }        

        function getFeeByAddress(address payable _addrs) public view returns(uint fee){
            fee = _recipients[_addrs];
        }        

        function getTotalFee() public view returns(uint totalFee){
            for(uint i=0; i < recipients.length; i++){
                totalFee += _recipients[recipients[i]];
            } 
        }  

        function _getTotalFee() internal view returns(uint totalFee){
            for(uint i=0; i < recipients.length; i++){
                totalFee += _recipients[recipients[i]];
            } 
        }

        function paySplitFee() public onlyOwner{
            require(address(this).balance != 0, "Not enugh funds");
            require(_getTotalFee() == FEE_BASE, "Payment not split entirely");

            uint256 share=0;  
            uint totalFeeValue =  address(this).balance;          
          
            for(uint i=0; i < recipients.length; i++){
                share = (totalFeeValue/ FEE_BASE) * _recipients[recipients[i]];
                (bool callSuccessFee, ) = payable(recipients[i]).call{value: share}("");
                require(callSuccessFee, "Return fee funds failed");
                emit FeePaid(recipients[i], share);
            }   
            
        }

        function getAddress() public view returns(address _splitPaymentAddress){
            _splitPaymentAddress = address(this);
        }
        
        // Function to receive Ether. msg.data must be empty
        receive() external payable onlyOwner{}

        // Fallback function is called when msg.data is not empty
        fallback() external payable onlyOwner{}
}