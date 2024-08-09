import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/secure_net_vault.dart';

abstract interface class IHiRPC {
  /// Create a sender.
  Uint8List createSender(String method, Uint8List docBuffer);

  /// Create a signed sender.
  Uint8List createSignedSender(String method, SecureNetVault vault, Uint8List docBuffer, Uint8List deriver);
}
