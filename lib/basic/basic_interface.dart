import 'dart:typed_data';

/// Add comments to the interface.
abstract interface class IBasic {
  bool startDRuntime();
  bool stopDRuntime();
  String encodeBase64Url(Uint8List documentAsByteArray);
  String tagionRevision();
  // Missing create dart index function.
}
