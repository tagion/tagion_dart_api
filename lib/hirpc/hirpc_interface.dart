import 'dart:typed_data';

abstract interface class IHiRPC {
  /// Create a sender.
  Uint8List createSender(String method, Uint8List param);

  /// Create a signed sender.
  Uint8List createSignedSender(String method, Uint8List param, Uint8List deriver);
}
