import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/keypair_details.dart';

abstract interface class ICrypto {
  /// Returns a keypair wrapper of [SecureNet] keypair and [Uint8List] device pin data.
  KeypairDetails generateKeypair(String passphrase, String pinCode, String salt);

  /// Returns a [SecureNet] keypair data by a provided [devicepin].
  SecureNet decryptDevicePin(String pinCode, Uint8List devicepin);

  /// Returns a [Uint8List] signature of the [dataToSign].
  Uint8List sign(SecureNet keypair, Uint8List dataToSign);
}
