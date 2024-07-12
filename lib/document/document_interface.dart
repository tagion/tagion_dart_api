import 'dart:ffi';
import 'dart:typed_data';

abstract interface class ITagionDocument {
  /// Get a Document element.
  Element getElement(Uint8List buffer, String key);

  /// Return the version of the document.
  int getVersion(Uint8List buffer);

  /// Get document record type.
  String getRecordName(Uint8List buffer);

  /// Get document error code.
  int validate(Uint8List buffer);

  /// Get a document element from index.
  Element getArray(Uint8List buffer, int index);

  /// Get document as string.
  String getText(Uint8List buffer, int textFormat);

  /// Get a sub doc from a document.
  Uint8List getDocument(Element element);

  /// Get a string from a document
  String getString(Element element);

  /// Get binary from a document.
  Uint8List getBinary(Element element);

  /// Get time from a document element.
  int getTime(Element element);

  /// Get bigint from a document. Returned as serialized leb128 ubyte buffer.
  BigInt getBigint(Element element);

  /// Get a bool from a document element.
  bool getBool(Element element);

  /// Get a int32 from a document element.
  Int32 getInt32(Element element);

  /// Get a int64 from a document element.
  Int64 getInt64(Element element);

  /// Get a Uint32 from a document element.
  Uint32 getUint32(Element element);

  /// Get a Uint64 from a document element.
  Uint64 getUint64(Element element);

  /// Get a f32 from a document element.
  Float getFloat32(Element element);

  /// Get an f64 from a document element.
  Double getFloat64(Element element);
}

class Element {
  Uint8List buffer;
  String key;
  Element(this.buffer, this.key);
}
