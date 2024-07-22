import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';

abstract interface class ICrypto {
  /// Returns a keypair wrapper of [Securnet] keypair and [Uint8List] device pin data.
  Keypair generateKeypair(String passphrase, String pinCode, String? salt);

  /// Securnet *out_securenet.
  Securnet decryptDevicePin(String pinCode, Uint8List devicepin);

  /// Returns a signature of the [dataToSign].
  Uint8List signMessage(Securnet keypair, Uint8List dataToSign);
}

/// Keeps a [Securnet] keypair and [Uint8List] device pin data.
class Keypair {
  final Securnet keypair;
  final Uint8List devicePin;

  Keypair(this.keypair, this.devicePin);
}
