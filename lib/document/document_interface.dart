import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/document/document_element.dart';

abstract interface class IDocument {
  /// Get a Document element.
  DocumentElement getDocument(String key);

  /// Return the version of the document.
  int getVersion(Uint8List buffer);

  /// Get document record type.
  String getRecordName(Uint8List buffer);

  /// Get document error code.
  int validate(Uint8List buffer);

  /// Get a document element from index.
  DocumentElement getArray(Uint8List buffer, int index);

  /// Get document as string.
  String getText(Uint8List buffer, int textFormat);

  /// Get a sub doc from a document.
  Uint8List getSubDocument(DocumentElement element);

  /// Get a string from a document
  String getString(DocumentElement element);

  /// Get binary from a document.
  Uint8List getBinary(DocumentElement element);

  /// Get time from a document element.
  int getTime(DocumentElement element);

  /// Get bigint from a document. Returned as serialized leb128 ubyte buffer.
  BigInt getBigint(DocumentElement element);

  /// Get a bool from a document element.
  bool getBool(DocumentElement element);

  /// Get a int32 from a document element.
  Int32 getInt32(DocumentElement element);

  /// Get a int64 from a document element.
  Int64 getInt64(DocumentElement element);

  /// Get a Uint32 from a document element.
  Uint32 getUint32(DocumentElement element);

  /// Get a Uint64 from a document element.
  Uint64 getUint64(DocumentElement element);

  /// Get a f32 from a document element.
  Float getFloat32(DocumentElement element);

  /// Get an f64 from a document element.
  Double getFloat64(DocumentElement element);
}
