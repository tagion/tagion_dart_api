import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/crypto/crypto.dart';
import 'package:tagion_dart_api/crypto/crypto_interface.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';
import 'package:tagion_dart_api_example/path_provider.dart';
import 'package:tagion_dart_api_example/secure_net_vault/secure_net_vault.dart';
import 'package:tagion_dart_api_example/secure_net_vault/secure_net_vault_interface.dart';
import 'package:tagion_dart_api_example/wallet/wallet.dart';
import 'package:tagion_dart_api_example/wallet_details/wallet_details.dart';
import 'package:tagion_dart_api_example/wallet_details/wallet_details_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_entity.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_sqflite.dart';

main() async {
  final DynamicLibrary dyLib = FFILibraryUtil.load();
  BasicFfi basicFfi = BasicFfi(dyLib);
  setUpAll(() {
    basicFfi.start_rt();
  });

  await walletIntegrationTest(dyLib);

  tearDownAll(() {
    basicFfi.stop_rt();
  });
}

Future<void> walletIntegrationTest(DynamicLibrary dyLib) async {
  // Create common objects
  IPointerManager pointerManager = const PointerManager();

  //Create Crypto
  CryptoFfi cryptoFfi = CryptoFfi(dyLib);
  ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
  IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);
  ICrypto crypto = Crypto(cryptoFfi, pointerManager, errorMessage);

  //Create SecureNetVault
  ITgnSecureNetVault secureNetVault = TgnSecureNetVault(pointerManager);

  //Create WalletDetails
  ITgnWalletDetails walletDetails = TgnWalletDetails();

  //Create and init WalletStorage
  IPathProvider pathProvider = PathProvider();
  ITgnWalletStorage<TgnWalletEntity> walletStorage = TgnWalletStorageSqflite(pathProvider);
  await walletStorage.init();

  //Create Wallet
  const String walletId = '1';
  TgnWallet tgnWallet = TgnWallet(walletId, crypto, secureNetVault, walletDetails, walletStorage);

  group('TgnWallet Integration.', () {
    test('create sets devicePin, id, and writes to storage', () async {
      await walletStorage.clearAll();
      tgnWallet.create('passPhrase', 'pinCode', 'salt');
      TgnWalletEntity walletEntity = await walletStorage.read(walletId);
      expect(walletEntity.id, walletId);
      expect(walletEntity.devicePin, isNotEmpty);
    });
  });
}
