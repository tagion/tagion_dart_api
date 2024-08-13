import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/secure_net_vault.dart';

/// HiRPC interface.
/// Provides functionality for HiRPC messages creation.
abstract interface class IHiRPC {
  Uint8List createRequest(String method, Uint8List docBuffer);
  Uint8List createSignedRequest(String method, SecureNetVault vault, Uint8List docBuffer, Uint8List deriver);
}
