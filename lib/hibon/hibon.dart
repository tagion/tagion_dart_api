import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/enums/hibon_string_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon_interface.dart';
import 'package:tagion_dart_api/module.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// Implements [Finalizable] and uses a [Finalizer] to maintain Hibon object resources.
/// Extends [Module] to use the [scope} feature.
class Hibon extends Module implements IHibon, Finalizable {
  final HibonFfi _hibonFfi;
  final IErrorMessage _errorMessage;
  final IPointerManager _pointerManager;

  final Pointer<HiBONT> _hibonPtr; // The pointer to the Hibon object.

  @override
  Pointer<HiBONT> get pointer => _hibonPtr;

  static final _finalizer = Finalizer<void Function()>((f) => f);

  /// Throws a [HibonApiException] if the operation is not successful.
  /// Allocates [_hibonPtr] for the Hibon object.
  Hibon(
    this._hibonFfi,
    this._errorMessage,
    this._pointerManager,
  )   : _hibonPtr = _pointerManager.allocate<HiBONT>(), // Allocate memory for the Hibon object.
        super(_errorMessage) {
    _finalizer.attach(this, dispose, detach: this);
  }

  /// Attaches the finalizer to the Hibon object.
  @override
  void create() {
    int status = _hibonFfi.tagion_hibon_create(_hibonPtr);
    if (status != TagionErrorCode.none.value) {
      throw HibonApiException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  /// Frees the memory for the Hibon object.
  /// Detaches the finalizer from the Hibon object.
  @override
  void dispose() {
    _hibonFfi.tagion_hibon_free(_hibonPtr);
    _finalizer.detach(this);
  }

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

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.freeAll([keyPtr, valuePtr]),
    );
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

    return scope.onExit<String, HibonApiException>(
      status,
      () => charArrayPtr[0].toDartString(length: charArrayLenPtr.value),
      () => _pointerManager.freeAll([charArrayPtr, charArrayLenPtr]),
    );
  }

  @override
  void addBigint(String key, BigInt value) {
    addArrayByKey(key, Uint8List.fromList(utf8.encode(value.toRadixString(16))));
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

    scope.onExit<void, HibonApiException>(status, () {}, () => _pointerManager.free(keyPtr));
  }

  @override
  Uint8List getAsDocumentBuffer() {
    final Pointer<Pointer<Uint8>> bufferPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final Pointer<Uint64> bufferLenPtr = _pointerManager.allocate<Uint64>();

    final int status = _hibonFfi.tagion_hibon_get_document(
      _hibonPtr,
      bufferPtr,
      bufferLenPtr,
    );

    return scope.onExit<Uint8List, HibonApiException>(
      status,
      () => bufferPtr[0].asTypedList(bufferLenPtr.value),
      () => _pointerManager.freeAll([bufferPtr, bufferLenPtr]),
    );
  }

  @override
  void addDocumentBufferByKey(String key, Uint8List buffer) {
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

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.freeAll([keyPtr, documentPtr]),
    );
  }

  @override
  void addDocumentBufferByIndex(int index, Uint8List buffer) {
    final Pointer<Uint8> documentPtr = _pointerManager.allocate<Uint8>(buffer.length);

    _pointerManager.uint8ListToPointer(documentPtr, buffer);

    final int status = _hibonFfi.tagion_hibon_add_index_document(
      _hibonPtr,
      index,
      documentPtr,
      buffer.length,
    );

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.free(documentPtr),
    );
  }

  @override
  void addHibonByKey(String key, IHibon hibon) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);

    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_hibon(
      _hibonPtr,
      keyPtr,
      key.length,
      hibon.pointer,
    );

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.free(keyPtr),
    );
  }

  @override
  void addHibonByIndex(int index, IHibon hibon) {
    final int status = _hibonFfi.tagion_hibon_add_index_hibon(
      _hibonPtr,
      index,
      hibon.pointer,
    );

    scope.onExit<void, HibonApiException>(status, () {}, null);
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

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.free(keyPtr),
    );
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

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.free(keyPtr),
    );
  }

  @override
  void addArrayByKey(String key, Uint8List array) {
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

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.freeAll([keyPtr, arrayPtr]),
    );
  }

  @override
  void addArrayByIndex(int index, Uint8List array) {
    final Pointer<Uint8> arrayPtr = _pointerManager.allocate<Uint8>(array.length);

    _pointerManager.uint8ListToPointer(arrayPtr, array);

    int status = _hibonFfi.tagion_hibon_add_index_binary(
      _hibonPtr,
      index,
      arrayPtr,
      array.length,
    );

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.free(arrayPtr),
    );
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

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.free(keyPtr),
    );
  }

  @override
  bool hasMemberByKey(String key) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Bool> resultPtr = _pointerManager.allocate<Bool>();
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_has_member(
      _hibonPtr,
      keyPtr,
      key.length,
      resultPtr,
    );

    return scope.onExit<bool, HibonApiException>(
      status,
      () => resultPtr.value,
      () => _pointerManager.freeAll([keyPtr, resultPtr]),
    );
  }

  @override
  bool hasMemberByIndex(int index) {
    final Pointer<Bool> resultPtr = _pointerManager.allocate<Bool>();

    final int status = _hibonFfi.tagion_hibon_has_member_index(
      _hibonPtr,
      index,
      resultPtr,
    );

    return scope.onExit<bool, HibonApiException>(
      status,
      () => resultPtr.value,
      () => _pointerManager.free(resultPtr),
    );
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

    scope.onExit<void, HibonApiException>(
      status,
      () {},
      () => _pointerManager.free(keyPtr),
    );
  }

  @override
  void removeByIndex(int index) {
    final int status = _hibonFfi.tagion_hibon_remove_by_index(
      _hibonPtr,
      index,
    );

    scope.onExit<void, HibonApiException>(status, () {}, null);
  }
}
