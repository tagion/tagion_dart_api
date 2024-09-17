import 'dart:typed_data';

abstract interface class IBasic {
  /// Starts D runtime.
  bool startDRuntime();

  /// Terminates D runtime.
  bool stopDRuntime();

  /// Encode a buffer into a base64url string
  String encodeBase64Url(Uint8List documentBytes);

  /// Get the tagion revision info
  String tagionRevision();

  /// Calculates the dartindex for a Document.
  /// The dartindex is what is used to reference the document in the DART database.
  Uint8List createDartIndex(Uint8List documentBytes);
}
