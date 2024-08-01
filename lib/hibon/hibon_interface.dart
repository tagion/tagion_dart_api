import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/enums/hibon_string_format.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';

/// The interface for the Hibon (Hash invariant Binary Object Notation) object.
/// Hibon is a binary format for storing data.
/// It is used to store data in the Tagion network.
abstract class IHibon {
  /// It is necessary to call this method before calling any other method. It creates a Hibon object.
  void init();

  /// It is necessary to call this method after using the Hibon object. It frees the memory allocated for the Hibon object.
  void free();

  Pointer<HiBONT> getPointer();

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
  void addArray(String key, Uint8List array);

  /// Adds a time to the Hibon object.
  void addTime(String key, int time);

  /// Adds a bigint to the Hibon object.
  void addBigint(String key, BigInt value);

  /// Adds a bool to the Hibon object.
  void addBool(String key, bool value);

  /// Adds an int to the Hibon object.
  /// Supports:
  /// - [Int32]
  /// - [Int64]
  /// - [Uint32]
  /// - [Uint64]
  void addInt<T>(String key, int value);

  /// Adds a float to the Hibon object.
  /// Supports:
  /// - [Float]
  /// - [Double]
  void addFloat<T>(String key, double value);

  /// Checks if the Hibon object has a member with the given key.
  bool hasMember(String key);

  /// Removes a member from the Hibon object by key.
  void removeByKey(String key);
}
