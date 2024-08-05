import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagion_dart_api/basic/basic.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/crypto/crypto.dart';
import 'package:tagion_dart_api/crypto/crypto_interface.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault/secure_net_vault.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault/secure_net_vault_interface.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/exception/crypto_exception.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

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
  late final DynamicLibrary _dyLib;
  late final BasicFfi _basicFfi;
  late final Basic _basic;
  final IPointerManager _pointerManager = const PointerManager();
  late final ErrorMessageFfi _errorMessageFfi;
  late final IErrorMessage _errorMessage;
  //
  late final CryptoFfi _cryptoFfi;
  late ISecureNetVault _secureNetVault;
  late final ICrypto _crypto;
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

  @override
  void initState() {
    super.initState();
    //
    _dyLib = FFILibraryUtil.load();
    _basicFfi = BasicFfi(_dyLib);
    _errorMessageFfi = ErrorMessageFfi(_dyLib);
    _errorMessage = ErrorMessage(_errorMessageFfi, _pointerManager);
    _basic = Basic(_basicFfi, _pointerManager, _errorMessage);
    //
    _cryptoFfi = CryptoFfi(_dyLib);
    _secureNetVault = SecureNetVault(_pointerManager);
    _crypto = Crypto(_cryptoFfi, _pointerManager, _errorMessage, _secureNetVault);
    //
    _basic.startDRuntime();
  }

  void generateKeypair() {
    setState(() {
      _devicePin = _crypto.generateKeypair(passPhrase, pinCode, salt);
    });
  }

  void decryptDevicePin() {
    try {
      _crypto.decryptDevicePin(pinCode, _devicePin);
      setState(() {
        decrypted = 'Success';
      });
    } on CryptoException catch (e) {
      setState(() {
        decrypted = '${e.runtimeType}: ${e.errorCode.toString()} - ${e.message}';
      });
    }
  }

  void signData() {
    try {
      setState(() {
        signature = _crypto.sign(dataToSign).toString();
      });
    } on CryptoException catch (e) {
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
                        onPressed: () => generateKeypair(),
                        child: const Text('Generate keypair'),
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
    );
  }
}
