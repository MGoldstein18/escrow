## Escrow
A simple smart-contract-powered escrow service

-------------------------------------------------------------

Contract published to the Polygon Mumbai Testnet using thirdweb release and be viewed [here](https://thirdweb.com/mumbai/0x74786409799519465E89E871197c094F06961663/)

-------------------------------------------------------------

### Functions
#### `createTransaction`
Initiate an escrow transaction with the address of the depositor (address which will pay money), address of the receiver (address withdrawing money), the amount (in wei) and the amount of time from now until the deadline (in seconds). Returns the `id` of the transaction and emits the `Create` event.

#### `deposit`
Make the required payment into the smart contract. Takes the `id` of the escrow transaction as an argument. Can only pay the amount that is specified in that escrow transaction and only the depositor specified can make the payment. Can only be called before the transaction deadline. Emits the `Deposit` event.

#### `release`
Takes the `id` of the escrow transaction as an argument. The parties of this transactionc can "sign off" on the transaction. Can only be called by the depositor and receiver of the specific escrow transaction. Can only be called if the deadline for the escrow transaction hasn't been reached. Emits the `Release` event.

#### `withdraw`
Can be used by the depositor, after the deadline, to withdraw their deposit if their is no sign off on the escrow transaction. Can be used by the receiver to withdraw once both parties have signed off on the escrow transaction. Can only be called if the transaction is not complete and the deposit was actually made. Emits the `Withdraw` event.

