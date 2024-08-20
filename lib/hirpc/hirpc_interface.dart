import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';

/// HiRPC interface.
/// Provides functionality for HiRPC messages creation.
abstract interface class IHiRPC {
  Uint8List createRequest(String method, Uint8List docBuffer);
  Uint8List createSignedRequest(String method, Pointer<SecureNet> vault, Uint8List docBuffer, Uint8List deriver);
}
