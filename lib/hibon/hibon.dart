import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/enums/hibon_string_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon_interface.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class Hibon implements IHibon {
  final HibonFfi _hibonFfi;
  final IErrorMessage _errorMessage;
  final IPointerManager _pointerManager;
  late final Pointer<HiBONT> _hibonPtr;

  Hibon(
    this._hibonFfi,
    this._errorMessage,
    this._pointerManager,
  ) {
    _hibonPtr = _pointerManager.allocate<HiBONT>();
  }

  @override
  void init() {
    final int createResult = _hibonFfi.tagion_hibon_create(_hibonPtr);
    if (createResult != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(createResult), _errorMessage.getErrorText());
    }
  }

  @override
  void addString(String key, String value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);
    final Pointer<Char> valuePtr = _pointerManager.allocate<Char>(value.length);
    _pointerManager.stringToPointer(valuePtr, value);

    final int addStringResult =
        _hibonFfi.tagion_hibon_add_string(_hibonPtr, keyPtr, key.length, valuePtr, value.length);

    if (addStringResult != TagionErrorCode.none.value) {
      _pointerManager.free(keyPtr);
      _pointerManager.free(valuePtr);

      throw HibonException(TagionErrorCode.fromInt(addStringResult), _errorMessage.getErrorText());
    }

    _pointerManager.free(keyPtr);
    _pointerManager.free(valuePtr);
  }

  @override
  String getAsString([HibonAsStringFormat format = HibonAsStringFormat.prettyJson]) {
    final Pointer<Pointer<Char>> charArrayPtr = _pointerManager.allocate<Pointer<Char>>();
    final Pointer<Uint64> charArrayLenPtr = _pointerManager.allocate<Uint64>();

    final int getTextResult = _hibonFfi.tagion_hibon_get_text(_hibonPtr, format.index, charArrayPtr, charArrayLenPtr);

    if (getTextResult != TagionErrorCode.none.value) {
      _pointerManager.free(charArrayPtr);
      _pointerManager.free(charArrayLenPtr);
      throw HibonException(TagionErrorCode.fromInt(getTextResult), _errorMessage.getErrorText());
    }

    final resultString = charArrayPtr[0].toDartString(length: charArrayLenPtr.value);

    _pointerManager.free(charArrayPtr);
    _pointerManager.free(charArrayLenPtr);

    return resultString;
  }

  @override
  void free() {
    _hibonFfi.tagion_hibon_free(_hibonPtr);
  }

  @override
  void addBigint(String key, BigInt value) {
    /// Convert the BigInt value to a Uint8List.
    final Uint8List uint8ArrayValue = Uint8List.fromList(utf8.encode(value.toRadixString(16)));

    /// Allocate memory for the key and value.
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Uint8> valuePtr = _pointerManager.allocate<Uint8>(uint8ArrayValue.length);

    /// Write the key and value to pointers.
    _pointerManager.stringToPointer(keyPtr, key);
    _pointerManager.uint8ListToPointer(valuePtr, uint8ArrayValue);

    int status = _hibonFfi.tagion_hibon_add_bigint(_hibonPtr, keyPtr, key.length, valuePtr, uint8ArrayValue.length);

    _pointerManager.free(keyPtr);
    _pointerManager.free(valuePtr);

    /// Check if the operation was successful.
    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addBool(String key, bool value) {
    // TODO: implement addBool
  }

  @override
  void addBoolArray(String key, Uint8List array) {
    // TODO: implement addBoolArray
  }

  @override
  void addDocument(String key, IDocument document) {
    // TODO: implement addDocument
  }

  @override
  void addFloat32(String key, double value) {
    // TODO: implement addFloat32
  }

  @override
  void addFloat32Array(String key, Float32List array) {
    // TODO: implement addFloat32Array
  }

  @override
  void addFloat64(String key, double value) {
    // TODO: implement addFloat64
  }

  @override
  void addFloat64Array(String key, Float64List array) {
    // TODO: implement addFloat64Array
  }

  @override
  void addHibon(String key, IHibon hibon) {
    // TODO: implement addHibon
  }

  @override
  void addInt32(String key, int value) {
    // TODO: implement addInt32
  }

  @override
  void addInt32Array(String key, Int32List array) {
    // TODO: implement addInt32Array
  }

  @override
  void addInt64(String key, int value) {
    // TODO: implement addInt64
  }

  @override
  void addInt64Array(String key, Int64List array) {
    // TODO: implement addInt64Array
  }

  @override
  void addTime(String key, int time) {
    // TODO: implement addTime
  }

  @override
  void addUint32(String key, int value) {
    // TODO: implement addUint32
  }

  @override
  void addUint32Array(String key, Uint32List array) {
    // TODO: implement addUint32Array
  }

  @override
  void addUint64(String key, int value) {
    // TODO: implement addUint64
  }

  @override
  void addUint64Array(String key, Uint64List buf) {
    // TODO: implement addUint64Array
  }

  @override
  void addUint8Array(String key, Uint8List array) {
    // TODO: implement addUint8Array
  }

  @override
  IDocument getDocument() {
    // TODO: implement getDocument
    throw UnimplementedError();
  }
}
