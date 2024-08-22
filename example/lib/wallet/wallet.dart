import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/crypto_interface.dart';
import 'package:tagion_dart_api_example/secure_net_vault/secure_net_vault_interface.dart';
import 'package:tagion_dart_api_example/wallet/wallet_interface.dart';
import 'package:tagion_dart_api_example/wallet_details/wallet_details_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_interface.dart';
import 'package:uuid/uuid.dart';

class TgnWallet implements ITgnWallet {
  final ICrypto _crypto;
  final ITgnSecureNetVault _secureNetVault;
  final ITgnWalletDetails _walletDetails;
  final ITgnWalletStorage _walletStorage;

  TgnWallet(this._crypto, this._secureNetVault, this._walletDetails, this._walletStorage);

  @override
  void create(String passPhrase, String pinCode, String salt) {
    try {
      Uint8List devicePin = _crypto.generateKeypair(passPhrase, pinCode, salt, _secureNetVault.secureNetPtr);
      _walletDetails.setId('tagion_wallet_${const Uuid().v4()}');
      _walletDetails.setDevicePin(devicePin);
      _walletStorage.write(_walletDetails.toEntity());
    } catch (e) {
      rethrow;
    }
  }

  @override
  bool login(String pinCode) {
    throw UnimplementedError();
  }

  @override
  void logout() {
    throw UnimplementedError();
  }

  @override
  bool isLoggedIn() {
    throw UnimplementedError();
  }

  @override
  bool delete() {
    throw UnimplementedError();
  }

  @override
  Uint8List getPublicKey() {
    throw UnimplementedError();
  }
}
