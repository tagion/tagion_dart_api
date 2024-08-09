# Wallet functionality.

Create an interface with a wallet related set of functions.

Wallet
Account
Derivers.

1. Create a wallet.
TODO: fullfill section.

2. Login to a wallet.
Obtain a SecureNet by a pinCode and keep it accessible during session.
TODO: fullfill section.

3. Logout from a wallet.
Deallocate all wallet related data from a memory, end session.
TODO: fullfill section.

4. Check a wallet login status.
Check if wallet is logged in.
TODO: fullfill section.

5. Delete a wallet.
Delete all wallet related data from local storage.
TODO: fullfill section.

6. Validate a pin-code.
Validate a pinCode for current wallet.
TODO: fullfill section.

7. Change a pin code.
Change wallet pinCode to a newPinCode. Can be called only in 'logged in' state.
TODO: fullfill section.

8. Retrieve public key.
Return wallet public key in a readable format.
TODO: fullfill section.

9. Export backup data.
Return derivers buffer in encrypted form from database.
TODO: fullfill section.

10.  Import backup data.
Save derivers to a wallet in order to obtain previous saved state.
TODO: fullfill section.

# Payment functionality.
  
1. Create a contract.
Creates a contract to pay specific amount of tagions to a recipient.
TODO: fullfill section.

# Wallet update functionality.
5.  Create a TRT update request.
Generates an update request to Tagion network.
TODO: fullfill section.

6. Insert TRT update response.
Sets a data from an update response which is sent back by TRT. May contain a DART update request.
TODO: fullfill section.

7. Set a dart update response.
Sets a data from an update response which is sent back by Tagion network.
TODO: fullfill section.

# Balance functionality.

1.  Get locked balance value. 
Return total amount of locked bills.
TODO: fullfill section.

2. Get available balance.
Return total amount of available bills.
TODO: fullfill section.

3. Get total balance.
Return total amount of bills.
TODO: fullfill section.

# Bills functionality.

1. Add bills.
Add new bills to a wallet.
TODO: fullfill section.

2. Remove bills by a specific key.
TODO: fullfill section.

3. Unlock bill.
If contract fails to send, this function unlocks bills used in a contract input in database.
TODO: fullfill section.