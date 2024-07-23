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

  /// Get an int32 from a document element.
  int getInt32();

  /// Get an int64 from a document element.
  int getInt64();

  /// Get a Uint32 from a document element.
  int getUint32();

  /// Get a Uint64 from a document element.
  int getUint64();

  /// Get a f64 from a document element.
  double getDouble();
}
