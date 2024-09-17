import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/module/crypto/ffi/crypto_ffi.dart';

abstract interface class ICrypto {
  /// Generate a keypair used from a password / menmonic.
  /// The function does NOT validate the menmonic and should therefore be validated by another function.
  /// Returns a [Uint8List] device pin data.
  Uint8List generateKeypair(String passphrase, String pinCode, String salt, Pointer<SecureNet> pointerSecureNet);

  /// Decrypt a provided [devicepin] and create a [SecureNet] keypair data.
  void decryptDevicePin(String pinCode, Uint8List devicepin, Pointer<SecureNet> pointerSecureNet);

  /// Returns a [Uint8List] signature of the [dataToSign].
  Uint8List sign(Uint8List dataToSign, Pointer<SecureNet> pointerSecureNet);
}
