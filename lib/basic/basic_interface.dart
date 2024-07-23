import 'dart:typed_data';

abstract interface class IBasic {
  bool startDRuntime();
  bool stopDRuntime();
  String encodeBase64Url(Uint8List documentAsByteArray);
  String tagionRevision();
}
