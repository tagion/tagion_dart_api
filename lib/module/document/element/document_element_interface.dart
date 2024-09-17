import 'dart:typed_data';

abstract interface class IDocumentElement {
  /// Get a sub-document from a parent document.
  Uint8List getSubDocument();

  /// Get a string from a document
  String getString();

  /// Get a binary from a document.
  Uint8List getU8Array();

  /// Get a time from a document.
  /// The time format used is std time (hectonanoseconds since 1ad).
  int getTime();

  /// Get a bigint from a document. Returned as serialized leb128 ubyte buffer.
  BigInt getBigInt();

  /// Get a bool from a document element.
  bool getBool();

  /// Get an int32 from a document element.
  int getInt32();

  /// Get an int64 from a document element.
  int getInt64();

  /// Get a Uint32 from a document element.
  int getUint32();

  /// Get a Uint64 from a document element.
  int getUint64();

  /// Get a Float32 from a document element.
  double getFloat32();

  /// Get a Float64 from a document element.
  double getFloat64();
}
