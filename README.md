# SPU Hackathon Web3 INSIGNIA !

This project, developed by INSIGNIA, is our submission to the "Tokenização do Patrimônio da União" Hackathon Web 3.0 an event organized in partnership between the Secretaria de Coordenação e Governança do Patrimônio da União (SPU), Ministério da Economia, Serpro, and Escola Nacional de Administração Pública (Enap). This documentation only covers the smart contracts and use case UML; the legal, administration and financial documents are shown at the team presentation.
The methods used here are the same if we wanted to certify these contracts by a third party, so if in the future this is necessary we would be ready for it with minimal effort.

# Challenge 1

For this first challenge our team has developed a vault to store securely and immutably all the documentation and any kind of registry needed to guarantee the safety of the real estate tokenization. Our contract uses web3 file storage as known as *IPFS* (Interplanetary File System) allowing virtually unlimited and permanent storage, unique identifier of the files, secure encryption of the documents for public or private usage and most important of all, traceability. 
One of the best features of using this system is decentralization, this feature allows the file to always be available. The contract was built so that any kind of data, document, file or address could be stored and retrieved by any authorised entity at any time.
>The blockchain itself can't guarantee the validity of the data inserted, as any software can't, it only guarantees the immutability once inserted and preserve the record of all the insertions made.

## The Smart Contract 

The file is DocumentVault.sol 
The execution, despite its power and breadth, is surprisingly simple. First of all the contract owner, after deployment, inserts the publishers that will be allowed to publish a new file; 
so this way other entities, including other smart contracts, can add new files to the vault.
>The contract owner is the only one capable of inserting and removing privileges.

The next step is to add the file(s) to the IPFS storage with a data struct file as in the example on the folder. Once this struct file is added, the CID address will be stored on the contract with his checksum.
>The checksum is a code used to verify the integrity of the file, it serves to guarantee that the file was correctly uploaded and was not changed afterwards.

Now adding the document to the contract using the parameters 

 1. _typeOfDocument -> A string describing the file
 2. _docsURI -> The CID of the data struct file on the IPFS
 3. _docsURIChesksum -> The checksum of the data struct file
 4. _publisherResponsible -> The name or code of the actual publisher
 5. _docProcess -> The number or any identification on the file

All the files can be retrieved using _docProcess as a key in the public structure.
Inside the folders there are examples of the documents needed.
For tests purposes, follows the checksum generator :
https://www.pelock.com/products/hash-calculator

 
# Challenge 2 - Auction

The files are AuctionSPU.sol and NFTMinter.sol
This project was our main focus and the development team has made great efforts to make this according to the highest standards. The objective was to deliver a, not just complex but functional, english type auction to sell real estate assets from the union or from union's debtors. The auction works quite similar to a normal one, the difference happens in some ways: the history of every bid made, the composable data of the bidder to reduce the possibility of acquirer's default, the fact that in order to bid you must put a upfront down payment to the contract, the "cashback" functionality where the bidder that was outbid receives back their funds if he is no longer the highest , the whitelist feature that allows only certified bidders to take part and the most important feature, the real value bid. We created a formula that calculates the "real value" of a bid using proposal parameters to automatically select the best offer for real estate. Follows below the formula and a example:

## Real Value Calculation 

To determine the real value of a bid , a simple calculation is made using the parameters : total value of the bid , installment of the payments and a customer score index. The score is a value from 0 to 2 determined previously to the auction.

$$
RealValue = TotalValue *  (\frac{1- Month Rate}{Score})^{Installments - 1}\,
$$

> The month rate , in general , is a public information and will be available on the notice as the same in the notice in the same way as the evaluation criteria 
>
## Example
In this example the month rate used is 0.9%
|Bidder| Total Value (bid) | Installments | Client Score | Real Value |
|--|--|--|--|--|
| 1 | R$100 | 12 | 1 | R$90.53 
| 2 | R$100 | 12 | 2 | R$95.16 
| 3 | R$100 | 18 | 1 | R$94.33 


## UML Use Case
![Challenge 2 UML](https://ipfs.io/ipfs/Qma1vAAdHmYQx5qZT3Hy9YBUdRiLKwpWd1mUDY2duFXsxj?filename=UML%20Use%20Case%20Challenge%202.png)


# Challenge 2 - Fractional Sale
The file are VariableTokenMinter.sol , VariableTokenFactory.sol , PaymentSplit.sol and PaymentSplitFactory.sol
In this section we describe a complementary way to sell SPU real estate, the fractional sale. 
The concept is very simple, a real estate is sold in fractions, known as tokens, to interested buyers. To deliver this solution our team created a customizable ERC-20, a token standard, a ERC-20 factory that creates customizable tokens, a payment splitter standard and a payment splitter factory that can be used by all the other solutions.
The whole idea is to create a real estate token, customized and with all the documentation attached to guarantee the integrity of the sale. In general the name and the symbol of the token as the metadata are related to the real estate.
In a future development our team will create a voting system to the real estate sold, once the decision of management is divided by the token holders.

# Important Key Note
For security purposes our project could be easily changed to handle multisig contracts. For example in the contract PaymentSplit.sol on the method paySplitFee(), instead of onlyOwner, we could use a modifier to accept interactions by only a specific address.
Multisig contracts are a canonical type of contract that only start an interaction (e.g. transfer tokens) if a minimum quorum is reached.

# Minted contracts

## NFT Minter
Address : 0x7e13A0Ac958022a18534c8F4d2aD939917e19bcA

## Document Vault
Address : 0x25d1323dCbf60FCF331353bE917cd92CE99ce309

## Auction SPU
Address : 0x0e7B5EeaC601d73394fbf39EF00fF8F3FBa12495

## Variable Token Factory
Address : 0x480622fA20A9e6b13bF2C515FEcE0237B50DF332

## Variable Token Minter Example
Address : 0xB91C37f99cc0b47BbAC836500D66F753862e2119

## Payment Split
Address : 0x8c4AFEB1A24fA4914B310A196Eb7B31601804aB3

## Payment Split Factory
Address : 0x65C7Ce599aeBf902e29833d783F20461e0c9da99