import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/crypto_interface.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';

class Crypto implements ICrypto {
  final CryptoFfi _cryptoFfi;
  final PointerManager _pointerManager;
  final ErrorMessage _errorMessage;

  const Crypto(this._cryptoFfi, this._pointerManager, this._errorMessage);

  @override
  Keypair generateKeypair(String passphrase, String pinCode, String? salt) {
    // TODO: implement generateKeypair
    throw UnimplementedError();
  }

  @override
  Securnet decryptDevicePin(String pinCode, Uint8List devicepin) {
    // TODO: implement decryptDevicePin
    throw UnimplementedError();
  }

  @override
  Uint8List signMessage(Securnet keypair, Uint8List dataToSign) {
    // TODO: implement signMessage
    throw UnimplementedError();
  }
}
