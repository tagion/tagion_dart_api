import 'package:flutter_test/flutter_test.dart';
import 'package:hd_wallet_kit/hd_wallet_kit.dart';
import 'package:tagion_dart_api_example/wallet_misc.dart';

void main() {
  const mnemonic = [
    'differ',
    'portion',
    'age',
    'fame',
    'good',
    'wood',
    'tooth',
    'twice',
    'donkey',
    'country',
    'cruise',
    'glimpse'
  ];

  final Map<String, TGNBill> dartDBState = {};

  group("Ensure that the same mnemonic always generates the same seed, addresses, and keys", () {
    test("derivation results always the same on each run", () {
      /// Create HDWallet using Uint8List seed.
      final hdWallet = WalletUtil.createWallet(mnemonic);

      /// ROOT key.
      /// Call of deriveKeyByPath for "m" just returns the root key.
      final rootKey = hdWallet.deriveKeyByPath(path: 'm');
      final xprv = rootKey.serializePrivate(HDExtendedKeyVersion.xprv);
      final xpub = rootKey.serializePublic(HDExtendedKeyVersion.xpub);
      final addressRoot = rootKey.encodeAddress(); // base58checkCodec is used.

      print('root privKey: $xprv');
      print('root pubKey: $xpub');
      print('root address: $addressRoot');

      expect(xprv,
          'xprv9s21ZrQH143K3hkkoRQpCKKzdvxuwfS1ihU3qdJW6ao59CgZgbJVEwGYkCr7gZpTuBZCyeqTTd6MXjKnRddoWChByy4Pv5N3TgtsE2MKqQB');
      expect(xpub,
          'xpub661MyMwAqRbcGBqDuSwpZTGjBxoQM89s5vPee1i7evL4211iE8cjnjb2bVvVivgAgDLRRwy4Qi1BggcdMSuBihCexny7GKT43c6pVRvrDMD');
      expect(addressRoot, '18ZJ2kbTX8fy9AjSh7ugQYs1SvW7BWM1vU');

      print('-------------------------');

      /// DERIVED keys.
      /// 0.
      final derived0Key = hdWallet.deriveKeyByPath(path: "m/44'/0'/0'/0/0"); // address_index = 0
      final derived0Xprv = derived0Key.serializePrivate(HDExtendedKeyVersion.xprv);
      final derived0Xpub = derived0Key.serializePublic(HDExtendedKeyVersion.xpub);
      final address0 = derived0Key.encodeAddress(); // base58checkCodec is used.

      print('0 derived privKey: $derived0Xprv');
      print('0 derived pubKey: $derived0Xpub');
      print('0 address: $address0');

      expect(derived0Xprv,
          'xprvA33nqjBL47Ydy2ZcYRqu3qLabvEpKdCAWqDP4KJmaB2w5Fc6uKsBh9fj4pQHvGL3nWrYdC1JfbwQ5QZ77F5j3jRqUND13hLjK6s1643HjV5');
      expect(derived0Xpub,
          'xpub6G39FEiDtV6wBWe5eTNuQyHK9x5Jj5v1t48yrhiP8WZux3wFSsBSEwzCv4t7ttw8eJcD4fvMi9xYH3g8tFtJ4YG9P3xjQGwHdfUQJsJXu3F');
      expect(address0, '1JS3jWYjUr6C65ZL4wc1iE73M8w9TCFzAM');

      print('-------------------------');

      /// 1.
      final derived1Key = hdWallet.deriveKeyByPath(path: "m/44'/0'/0'/0/1"); // address_index = 1
      final derived1Xprv = derived1Key.serializePrivate(HDExtendedKeyVersion.xprv);
      final derived1Xpub = derived1Key.serializePublic(HDExtendedKeyVersion.xpub);
      final address1 = derived1Key.encodeAddress(); // base58checkCodec is used.

      print('1 derived privKey: $derived1Xprv');
      print('1 derived pubKey: $derived1Xpub');
      print('1 address: $address1');

      expect(derived1Xprv,
          'xprvA33nqjBL47YdynD4EFF9SzD5BDCEYNvP7tZtyv8QkHwd5Q1KoLBwjucQ86jLgKtKGcWayYdqJDWDEhP7xr3fDdPPxFNhGGQsDgQPm3Czv4g');
      expect(derived1Xpub,
          'xpub6G39FEiDtV6wCGHXLGn9p89ojF2iwqeEV7VVnJY2JdUbxCLULsWCHhvsyLX9bseHpM9e4vywtRDCRTtzU16YRXtRzcsjyXJBof1B8Jkwf4n');
      expect(address1, '1jGHFqdrH5DQ6wGJYpGAYEMa7AY6wSbvM');

      print('-------------------------');

      /// Create a new account.
      final derived2Key = hdWallet.deriveKeyByPath(path: "m/44'/0'/1'/0/0"); // account = 1
      final derived2Xprv = derived2Key.serializePrivate(HDExtendedKeyVersion.xprv);
      final derived2Xpub = derived2Key.serializePublic(HDExtendedKeyVersion.xpub);
      final address2 = derived2Key.encodeAddress(); // base58checkCodec is used.

      print('2 derived privKey: $derived2Xprv');
      print('2 derived pubKey: $derived2Xpub');
      print('2 address: $address2');

      expect(derived2Xprv,
          'xprvA2vDqXGEaJnrcdhrxjDCUkHjuYroeCfqjem2i1zszZA5WqYHsGb3Ts1M3WMBEfb1j3WNGAZXPRMm4yUY9vV6CL1RBxuebDS1dEj7jPNofep');
      expect(derived2Xpub,
          'xpub6FuaF2o8QgM9q7nL4kkCqtEUTahJ3fPh6sgdWQQVYth4PdsSQouJ1fKptp2cKgQ2Hw6n7TSjxSZCoTCQzCNzWzTUoJSAfbbLHeCp5WkLJiq');
      expect(address2, '1H6dvieqE9KtZPaWXwviWtcE7dEHZrVLup');
    });

    test("multiple accounts and adresses creation guarantee initial and restored balance match", () {
      /// Create HDWallet using Uint8List seed.
      final hdWallet = WalletUtil.createWallet(mnemonic);

      const coinType = Coin.TGN; // TGN coin type

      /// Create a wallet state.
      /// Create 10 accounts.
      /// Create 10 addresses for each account.
      double balance = 0.0;
      for (int j = 0; j < 10; j++) {
        for (int i = 0; i < 10; i++) {
          final derivedKey =
              hdWallet.deriveKeyByPath(path: "m/44'/${coinType.value}'/$j'/0/$i"); // account j ,address_index i
          print(derivedKey.toString());
          final xpub = derivedKey.serializePublic(HDExtendedKeyVersion.xpub);
          final bill = TGNBill(80.0, xpub);
          dartDBState[xpub] = bill;
          balance += bill.value;
        }
      }
      print('-------------------------');
      print('DART entries: ${dartDBState.length}');
      print('Initial bills balance: $balance');

      /// Restore the state.
      double restoredBalance = 0.0;
      for (int j = 0; j < 10; j++) {
        for (int i = 0; i < 10; i++) {
          final derivedKey =
              hdWallet.deriveKeyByPath(path: "m/44'/${coinType.value}'/$j'/0/$i"); // account j ,address_index i
          final xpub = derivedKey.serializePublic(HDExtendedKeyVersion.xpub);
          restoredBalance += (dartDBState[xpub] as TGNBill).value;
        }
      }

      print('Restored bills balance: $restoredBalance');

      expect(balance, restoredBalance);
    });
  });
}
