import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/document/document.dart';
import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/hibon_string_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon_interface.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

/// [_hibonPtr] is the pointer to the Hibon object.
class Hibon implements IHibon {
  final HibonFfi _hibonFfi;
  final IErrorMessage _errorMessage;
  final IPointerManager _pointerManager;

  late final Pointer<HiBONT> _hibonPtr;

  /// Throws a [HibonException] if the operation is not successful.
  /// Allocates [_hibonPtr] for the Hibon object.
  Hibon(
    this._hibonFfi,
    this._errorMessage,
    this._pointerManager,
  ) {
    _hibonPtr = _pointerManager.allocate<HiBONT>();
    int status = _hibonFfi.tagion_hibon_create(_hibonPtr);
    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  /// Checks the status of the operation and throws an exception if it is not successful.
  /// If the operation is successful, returns the result of the [onDone] function.
  /// Guarantees freeing the memory of the pointers in the [ptrs] list.
  T _checkStatusOrThrow<T>(
    int status,
    T Function() onDone, [
    List<Pointer> ptrs = const [],
  ]) {
    try {
      if (status != TagionErrorCode.none.value) {
        throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
      }
      return onDone();
    } catch (_) {
      rethrow;
    } finally {
      /// Loop through pointers list and free the memory.
      for (var ptr in ptrs) {
        _pointerManager.free(ptr);
      }
    }
  }

  @override
  void dispose() {
    _hibonFfi.tagion_hibon_free(_hibonPtr);
  }

  @override
  Pointer<HiBONT> getPointer() => _hibonPtr;

  @override
  void addString(String key, String value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Char> valuePtr = _pointerManager.allocate<Char>(value.length);

    _pointerManager.stringToPointer(keyPtr, key);
    _pointerManager.stringToPointer(valuePtr, value);

    int status = _hibonFfi.tagion_hibon_add_string(
      _hibonPtr,
      keyPtr,
      key.length,
      valuePtr,
      value.length,
    );

    _checkStatusOrThrow<void>(status, () {}, [keyPtr, valuePtr]);
  }

  @override
  String getAsString([HibonAsStringFormat format = HibonAsStringFormat.prettyJson]) {
    final Pointer<Pointer<Char>> charArrayPtr = _pointerManager.allocate<Pointer<Char>>();
    final Pointer<Uint64> charArrayLenPtr = _pointerManager.allocate<Uint64>();

    int status = _hibonFfi.tagion_hibon_get_text(
      _hibonPtr,
      format.index,
      charArrayPtr,
      charArrayLenPtr,
    );

    return _checkStatusOrThrow<String>(
      status,
      () => charArrayPtr[0].toDartString(length: charArrayLenPtr.value),
      [charArrayPtr, charArrayLenPtr],
    );
  }

  @override
  void addBigint(String key, BigInt value) {
    addArray(key, Uint8List.fromList(utf8.encode(value.toRadixString(16))));
  }

  @override
  void addBool(String key, bool value) {
    /// Allocate memory for the key.
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);

    /// Write the key to the pointer.
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_bool(
      _hibonPtr,
      keyPtr,
      key.length,
      value,
    );

    _checkStatusOrThrow<void>(status, () {}, [keyPtr]);
  }

  @override
  IDocument getDocument() {
    final Pointer<Pointer<Uint8>> bufferPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final Pointer<Uint64> bufferLenPtr = _pointerManager.allocate<Uint64>();

    final int status = _hibonFfi.tagion_hibon_get_document(
      _hibonPtr,
      bufferPtr,
      bufferLenPtr,
    );

    return _checkStatusOrThrow<IDocument>(
        status,
        () => Document(
              DocumentFfi(FFILibraryUtil.load()),
              _pointerManager,
              _errorMessage,
              bufferPtr[0].asTypedList(bufferLenPtr.value),
            ),
        [bufferPtr, bufferLenPtr]);
  }

  @override
  void addDocumentBuffer(String key, Uint8List buffer) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Uint8> documentPtr = _pointerManager.allocate<Uint8>(buffer.length);

    _pointerManager.stringToPointer(keyPtr, key);
    _pointerManager.uint8ListToPointer(documentPtr, buffer);

    final int status = _hibonFfi.tagion_hibon_add_document(
      _hibonPtr,
      keyPtr,
      key.length,
      documentPtr,
      buffer.length,
    );

    _checkStatusOrThrow<void>(status, () {}, [keyPtr, documentPtr]);
  }

  @override
  void addDocument(String key, IDocument document) {
    addDocumentBuffer(key, document.getData());
  }

  @override
  void addHibon(String key, IHibon hibon) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);

    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_hibon(
      _hibonPtr,
      keyPtr,
      key.length,
      hibon.getPointer(),
    );

    _checkStatusOrThrow<void>(status, () {}, [keyPtr]);
  }

  @override
  void addFloat<T>(String key, double value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    int status;

    switch (T) {
      case Float:
        status = _hibonFfi.tagion_hibon_add_float32(
          _hibonPtr,
          keyPtr,
          key.length,
          value,
        );
        break;
      case Double:
        status = _hibonFfi.tagion_hibon_add_float64(
          _hibonPtr,
          keyPtr,
          key.length,
          value,
        );
        break;
      default:
        throw Exception('Unsupported type');
    }

    _checkStatusOrThrow<void>(status, () {}, [keyPtr]);
  }

  @override
  void addInt<T>(String key, int value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    int status;

    switch (T) {
      case Int32:
        status = _hibonFfi.tagion_hibon_add_int32(
          _hibonPtr,
          keyPtr,
          key.length,
          value,
        );
        break;
      case Int64:
        status = _hibonFfi.tagion_hibon_add_int64(
          _hibonPtr,
          keyPtr,
          key.length,
          value,
        );
        break;
      case Uint32:
        status = _hibonFfi.tagion_hibon_add_uint32(
          _hibonPtr,
          keyPtr,
          key.length,
          value,
        );
        break;
      case Uint64:
        status = _hibonFfi.tagion_hibon_add_uint64(
          _hibonPtr,
          keyPtr,
          key.length,
          value,
        );
        break;
      default:
        throw Exception('Unsupported type');
    }

    _checkStatusOrThrow<void>(status, () {}, [keyPtr]);
  }

  @override
  void addArray(String key, Uint8List array) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Uint8> arrayPtr = _pointerManager.allocate<Uint8>(array.length);

    _pointerManager.stringToPointer(keyPtr, key);
    _pointerManager.uint8ListToPointer(arrayPtr, array);

    int status = _hibonFfi.tagion_hibon_add_binary(
      _hibonPtr,
      keyPtr,
      key.length,
      arrayPtr,
      array.length,
    );

    _checkStatusOrThrow<void>(status, () {}, [keyPtr, arrayPtr]);
  }

  @override
  void addTime(String key, int time) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_time(
      _hibonPtr,
      keyPtr,
      key.length,
      time,
    );

    _checkStatusOrThrow<void>(status, () {}, [keyPtr]);
  }

  @override
  bool hasMember(String key) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Bool> resultPtr = _pointerManager.allocate<Bool>();
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_has_member(
      _hibonPtr,
      keyPtr,
      key.length,
      resultPtr,
    );

    return _checkStatusOrThrow<bool>(status, () => resultPtr.value, [keyPtr, resultPtr]);
  }

  @override
  void removeByKey(String key) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_remove_by_key(
      _hibonPtr,
      keyPtr,
      key.length,
    );

    _checkStatusOrThrow<void>(status, () {}, [keyPtr]);
  }
}
