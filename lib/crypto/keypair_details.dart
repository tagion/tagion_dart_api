import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';

/// A helper class designed to hold a [keypair] and [devicePin] obtained 
/// as a result of keypair generation.
/// The [keypair] field is a [SecureNet] object.
/// The [devicePin] field is a [Uint8List] object.
class KeypairDetails {
  final SecureNet keypair;
  final Uint8List devicePin;

  const KeypairDetails(this.keypair, this.devicePin);
}
