import 'dart:typed_data';

abstract interface class IDocumentElement {
  /// Get a sub doc from a document.
  Uint8List getSubDocument();

  /// Get a string from a document
  String getString();

  /// Get a binary from a document.
  Uint8List getBinary();

  /// Get a time from a document.
  int getTime();

  /// Get a bigint from a document. Returned as serialized leb128 ubyte buffer.
  BigInt getBigInt();

  /// Get a bool from a document element.
  bool getBool();

  /// Get a int32, int64, Uint32 or Uint64 from a document element.
  int getInt();

  /// Get a f32 from a document element.
  double getDouble();
}
