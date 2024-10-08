import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';

abstract interface class ICrypto {
  /// Returns a [Uint8List] device pin data.
  Uint8List generateKeypair(String passphrase, String pinCode, String salt, Pointer<SecureNet> pointerSecureNet);

  /// Returns a [SecureNet] keypair data by a provided [devicepin].
  void decryptDevicePin(String pinCode, Uint8List devicepin, Pointer<SecureNet> pointerSecureNet);

  /// Returns a [Uint8List] signature of the [dataToSign].
  Uint8List sign(Uint8List dataToSign, Pointer<SecureNet> pointerSecureNet);
}
