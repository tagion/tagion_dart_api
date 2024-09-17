import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/enums/text_format.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';

/// The interface for a Hibon (Hash invariant Binary Object Notation) object.
/// Hibon is a binary format used for transfering and storing data.
abstract class IHibon {
  /// Initializes the Hibon object.
  void create();

  /// Frees the memory externally allocated for the Hibon object.
  void dispose();

  /// Returns the stored pointer of the Hibon object.
  Pointer<HiBONT> get pointer;

  /// Adds a string to the Hibon object.
  void addString(String key, String value);

  /// Returns the Hibon object as a string.
  String getAsString([TextFormat format]);

  /// Returns the current Hibon object as a document buffer.
  Uint8List getAsDocumentBuffer();

  /// Adds a document buffer to the Hibon object by key.
  void addDocumentBufferByKey(String key, Uint8List buffer);

  /// Adds a document buffer to the Hibon object by index.
  void addDocumentBufferByIndex(int index, Uint8List buffer);

  /// Adds an inner Hibon object to the Hibon object by key.
  void addHibonByKey(String key, IHibon hibon);

  /// Adds an inner Hibon object to the Hibon object by index.
  void addHibonByIndex(int index, IHibon hibon);

  /// Adds a byte array to the Hibon object by key.
  void addArrayByKey(String key, Uint8List array);

  /// Adds a byte array to the Hibon object by index.
  void addArrayByIndex(int index, Uint8List array);

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
  bool hasMemberByKey(String key);

  /// Checks if the Hibon object has a member with the given index.
  bool hasMemberByIndex(int index);

  /// Removes a member from the Hibon object by key.
  void removeByKey(String key);

  /// Removes a member from the Hibon object by index.
  void removeByIndex(int index);
}
