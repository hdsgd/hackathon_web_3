# SPU Hackathon Web3 INSIGNIA !

This project , develop by INSIGNIA , aims to reach major TOP 1 on the Hackathon Web 3 an event in partner between the Secretaria de Coordenação e Governança do Patrimônio da União (SPU), the Ministério da Economia; the Serpro, and the Escola Nacional de Administração Pública (Enap). This documentation only covers the smart contracts and use case UML of the system develop by tech department; the legal, administration and financial documents are the responsibility of their respective departments.

# Challenge 1

For this first challenge our team develop a vault to storage securely and immutably all the documentation and any kind of register needed to guarantee the safety of the data after and before the process. Our contract uses web3 file storage as know as **IPFS** (Interplanetary File System) allowing virtual unlimited and forever storage, unique identifier of the files, secure encrypted documents for public or private usages and most of all a traceability. One of the best features on using this system is decentralization, that feature allows the file to be always available. The contract was built so any kind of data , document, file or address can be stored and retrieved by anyone who needs or , if is the purpose, is allowed.
>The blockchain itself can't guarantee the validity of the data inserted , as any software can't, it only guarantees the immutability once inserted and preserve a record on all the insertions made .

## The Smart Contract 

The file is DocumentVault.sol 
The execution , besides its power and coverage , is very simple . First of all the contract owner, after deployment, insert any new publisher that will publish a new file; so this way other entities, include another smart contracts, can add new files to the vault.
>The contract owner is the only responsible to insert and remove privileges.

The next step is to add the file(s) to IPFS storage with a data struct file as in the example on the folder. Once this struct file added , the CID address will be stored on the contract with his checksum.
>The checksum is a code used to verify the integrity of the file, is this case to guarantee that the file was changed or not.

Now adding the document to the contract using the parameters 

 1. _typeOfDocument -> A string describing the file
 2. _docsURI -> The CID of the data struct file on the IPFS
 3. _docsURIChesksum -> The checksum of the data struct file
 4. _publisherResponsible -> The name or code of the actual publisher
 5. _docProcess -> The number or any identification on the file

All the files can be retrieved using _docProcess as key in the public structure.
Inside of the folders are available example of the documents needed.
For purpose tests of checksum generator :
https://www.pelock.com/products/hash-calculator

 
# Challenge 2 - Auction
The file are AuctionSPU.sol and NFTMinter.sol
This project was our main focus and the development team push a great effort to make a great execution. The objective was deliver a, not just complex but functional, english auction to sell SPU assets directly or fractioned. The auction works quite simple to a normal one, the difference comes in some ways : the history of every bid made , the composable data of the bidder for further evaluation of the SPU , the cashback functionality where the last highest bidder receives back their funds if he is no longer the highest , the whitelist feature that allows only certified bidder to take part and the most important the real value bid. We create a formula that calculates the real value of a bid using proposal parameters to select the best offer for the SPU, below the formula and a example

## Real Value Calculation 

To determine the real value of a bid , a simple calculation is made using the parameters : total value of the bid , portion of the payment and a customer score index. The score is arbitrary value determined in a previous notice.


## Real Value Calculation

Beelow is the formula used to calculate a real value of a bid
$$
RealValue = TotalValue *  (\frac{1- Month Rate}{Score})^{Portions - 1}\,
$$

> The month rate , in general , is a public information and will be available on the notice as the same in the notice in the same way as the evaluation criteria 
>
## Example
In this example the month rate used is 0.9%
|Bidder| Total Value (bid) | Portion | Client Score | Real Value |
|--|--|--|--|--|
| 1 | R$100 | 12 | 1 | R$90.53 
| 2 | R$100 | 12 | 2 | R$95.16 
| 3 | R$100 | 18 | 1 | R$94.33 


## UML Use Case
![Challenge 2 UML](https://ipfs.io/ipfs/Qma1vAAdHmYQx5qZT3Hy9YBUdRiLKwpWd1mUDY2duFXsxj)


# Challenge 2 - Fractional Sale
The file are VariableTokenMinter.sol , VariableTokenFactory.sol , PaymentSplit.sol and PaymentSplitFactory.sol
In this section we describe a complementary way to sell SPU real estate , fractional sale. 
The concept is very simples, a state is sold in pieces ,known as tokens, to stakeholders . To deliver this solution our team create customizable ERC-20 , a token standard, a ERC-20 factory that create customizable tokens , a payment splitter standard and a payment splitter factory that can be used by the other solutions.
The role ideia is create a real estate token, customized and with all the documentation attached to guarantee the integrity of the sell. In general the name and the symbol of the token as the metadata are related to the real estate.
In a future development our team will create a voting system to the real state sold, once the decision of management is divided by the token holders.
