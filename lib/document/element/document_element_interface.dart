import 'dart:ffi';
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
  BigInt getBigint();

  /// Get a bool from a document element.
  bool getBool();

  /// Get a int32 from a document element.
  Int32 getInt32();

  /// Get a int64 from a document element.
  Int64 getInt64();

  /// Get a Uint32 from a document element.
  Uint32 getUint32();

  /// Get a Uint64 from a document element.
  Uint64 getUint64();

  /// Get a f32 from a document element.
  Float getFloat32();

  /// Get an f64 from a document element.
  Double getFloat64();
}
