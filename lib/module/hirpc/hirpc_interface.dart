import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/module/crypto/ffi/crypto_ffi.dart';

/// HiRPC interface.
/// Provides functionality for HiRPC messages creation.
abstract interface class IHiRPC {
  /// Creates a hirpc from a document buffer.
  Uint8List createRequest(String method, Uint8List docBuffer);
  /// Creates a signed hirpc from a document buffer.
  Uint8List createSignedRequest(String method, Pointer<SecureNet> vault, Uint8List docBuffer, Uint8List deriver);
}
