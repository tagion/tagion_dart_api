import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/exception/crypto_exception.dart';
import 'package:tagion_dart_api/module/basic/basic.dart';
import 'package:tagion_dart_api/module/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/module/crypto/crypto.dart';
import 'package:tagion_dart_api/module/crypto/crypto_interface.dart';
import 'package:tagion_dart_api/module/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/dynamic_library_loader.dart';
import 'package:tagion_dart_api_example/path_provider.dart';
import 'package:tagion_dart_api_example/secure_net_vault/secure_net_vault.dart';
import 'package:tagion_dart_api_example/secure_net_vault/secure_net_vault_interface.dart';
import 'package:tagion_dart_api_example/wallet/wallet.dart';
import 'package:tagion_dart_api_example/wallet/wallet_interface.dart';
import 'package:tagion_dart_api_example/wallet_details/wallet_details.dart';
import 'package:tagion_dart_api_example/wallet_details/wallet_details_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //
  late final Basic _basic;
  late final ICrypto _crypto;
  late ISecureNetVault _secureNetVault;
  //
  late ITgnWallet tagionWallet;
  final ITgnWalletDetails _walletDetails = TgnWalletDetails();
  final ITgnWalletStorage _walletStorage = TgnWalletStorageSqflite(PathProvider())..init();
  //
  String passPhrase = 'passPhrase';
  String pinCode = 'pinCode';
  String salt = 'salt';
  Uint8List dataToSign = Uint8List.fromList([
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31
  ]);
  //
  Uint8List _devicePin = Uint8List.fromList([]);
  String decrypted = '';
  String signature = '';
  //
  int _openCount = 0;
  int _closeCount = 0;

  @override
  void initState() {
    super.initState();
    //
    _basic = Basic.init();
    _basic.startDRuntime();
    //
    _secureNetVault = SecureNetVault(const PointerManager());
    _crypto = Crypto.init();
  }

  void createWallet() {
    //pipeline test commit
    setState(() {
      tagionWallet.create(passPhrase, pinCode, salt);
    });
  }

  void decryptDevicePin() {
    try {
      _crypto.decryptDevicePin(pinCode, _devicePin, _secureNetVault.secureNetPtr);
      setState(() {
        decrypted = 'Success';
      });
    } on CryptoApiException catch (e) {
      setState(() {
        decrypted = '${e.runtimeType}: ${e.errorCode.toString()} - ${e.message}';
      });
    }
  }

  void closeVault() {
    _secureNetVault.removePtr();
    _closeCount++;
    setState(() {});
  }

  void openVault() {
    _secureNetVault.allocatePtr();
    _openCount++;
    setState(() {});
  }

  void signData() {
    try {
      setState(() {
        signature = _crypto.sign(dataToSign, _secureNetVault.secureNetPtr).toString();
      });
    } on CryptoApiException catch (e) {
      setState(() {
        signature = '${e.runtimeType}: ${e.errorCode.toString()} - ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Passphrase: $passPhrase\nPincode: $pinCode\nSalt: $salt'),
                        OutlinedButton(
                          onPressed: () => createWallet(),
                          child: const Text('Create wallet'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Device pin: $_devicePin\n'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlinedButton(
                          onPressed: () => closeVault(),
                          child: const Text('Close'),
                        ),
                        Text('$_closeCount'),
                        const SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: () => openVault(),
                          child: const Text('Open'),
                        ),
                        Text('$_openCount'),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Pincode: $pinCode\nDevicePin: See above'),
                        OutlinedButton(
                          onPressed: () => decryptDevicePin(),
                          child: const Text('Decrypt device pin'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Decrypted: $decrypted'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Data: $dataToSign'),
                    OutlinedButton(
                      onPressed: () => signData(),
                      child: const Text('Sign data'),
                    ),
                    const SizedBox(height: 20),
                    Text('Signature: $signature'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
