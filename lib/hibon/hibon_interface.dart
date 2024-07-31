import 'dart:typed_data';

import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/enums/hibon_string_format.dart';

/// The interface for the Hibon (Hash invariant Binary Object Notation) object.
/// Hibon is a binary format for storing data.
/// It is used to store data in the Tagion network.
abstract class IHibon {
  /// It is necessary to call this method before calling any other method. It creates a Hibon object.
  void init();

  /// It is necessary to call this method after using the Hibon object. It frees the memory allocated for the Hibon object.
  void free();

  /// Adds a string to the Hibon object.
  void addString(String key, String value);

  /// Returns the Hibon object as a string.
  String getAsString([HibonAsStringFormat format]);

  /// Gets a document from the Hibon object.
  IDocument getDocument();

  /// Adds a document to the Hibon object.
  void addDocument(String key, IDocument document);

  /// Adds an inner Hibon object to the Hibon object.
  void addHibon(String key, IHibon hibon);

  /// Adds a byte array to the Hibon object.
  void addUint8Array(String key, Uint8List array);

  /// Adds a time to the Hibon object.
  void addTime(String key, int time);

  /// Adds a bigint to the Hibon object.
  void addBigint(String key, BigInt value);

  /// Adds a bool to the Hibon object.
  void addBool(String key, bool value);

  /// Adds a bool array to the Hibon object.
  void addBoolArray(String key, Uint8List array);

  /// Adds an int32 to the Hibon object.
  void addInt32(String key, int value);

  /// Adds an int32 array to the Hibon object.
  void addInt32Array(String key, Int32List array);

  /// Adds an int64 to the Hibon object.
  void addInt64(String key, int value);

  /// Adds an int64 array to the Hibon object.
  void addInt64Array(String key, Int64List array);

  /// Adds a uint32 to the Hibon object.
  void addUint32(String key, int value);

  /// Adds a uint32 array to the Hibon object.
  void addUint32Array(String key, Uint32List array);

  /// Adds a uint64 to the Hibon object.
  void addUint64(String key, int value);

  /// Adds a uint64 array to the Hibon object.
  void addUint64Array(String key, Uint64List buf);

  /// Adds a float to the Hibon object.
  void addFloat32(String key, double value);

  /// Adds a float array to the Hibon object.
  void addFloat32Array(String key, Float32List array);

  /// Adds a double to the Hibon object.
  void addFloat64(String key, double value);

  /// Adds a double array to the Hibon object.
  void addFloat64Array(String key, Float64List array);
}
