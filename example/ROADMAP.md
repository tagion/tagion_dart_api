# Goal:
* Substitute old Dlang wallet implementation with a current one by using a set of functions of a wallet api interface.

## Features:

# Wallet create/restore feature.

Dependencies:
* TagionWallet interface.
* Crypto.createKeyPair() 
* AccountDetails
* DevicePIN
* SecureNet
* DARTIndex
* WalletStorage

1. Create a wallet.
Create a wallet by using given [pin-code], [passphrase] and optional [salt].

2. Login to a wallet.
Obtain a [SecureNet] by a [pinCode] and keep it accessible during session.

3. Logout from a wallet.
Deallocate all wallet related data from a memory, end session.

4. Check a wallet login status.
Check if wallet is logged in.

5. Delete a wallet.
Delete all wallet related data from local storage.

6. Validate a pin-code.
Validate a [pinCode] for current wallet.

7. Change a pin code.
Change wallet [pinCode] to a [newPinCode]. Can be called only in 'logged in' state.

8. Retrieve public key.
Return wallet [publickey] in a readable format.


# "Wallet backup" feature.

Dependencies:
* TagionWallet interface.
* AccountDetails
* Deriver (deprecated)

1. Export backup data.
Return ecrypted [Deriver] in encrypted form from database.

2.  Import backup data.
Save [Derivers] to a wallet in order to obtain previous saved state.


# "Create a payment" feature.

Dependencies:
* TagionWallet interface.
* HiRPC.createSignedSender()
* TagionContract
* Invoice (deprecated)/Pubkey
* TagionBill
* TagionCurrency
  
1. Create a contract.
Creates a [TagionContract] to pay specific amount of tagions to a recipient.

2. Calculate fee.


# "Wallet update" feature.

Dependencies:
* TagionWallet interface.
* HiRPC.createSender()
* Deriver
* DARTIndex
* TRTArchive
* TagionBill

1.  Create a TRT update request.
Generates an update request to Tagion network.

2. Insert TRT update response.
Sets a data from an update response which is sent back by TRT. May contain a DART update request.

3. Set a dart update response.
Sets a data from an update response which is sent back by Tagion network.


# "Balance" feature.

Dependencies:
* TagionWallet interface.
* AccountDetails
* TagionBill
* TagionCurrency

1.  Get locked balance value. 
Return total amount of locked [TagionBill]'s.

2. Get available balance.
Return total amount of available [TagionBill]'s.

3. Get total balance.
Return total amount of [TagionBill]'s.

4. Add.
Add new [TagionBill]'s to a wallet.

5. Remove.
Delete [TagionBill]'s by a specific key.

6. Unlock.
If contract fails to send, this function unlocks [TagionBill]'s used in a contract input in database.


# Transaction list feature.

Dependencies:
* TagionWallet interface.
* TagionBill
* TagionCurrency
* DARTIndex
* SignedContract (?)

1. Get history.
Return history of payments. Supports pagination.
