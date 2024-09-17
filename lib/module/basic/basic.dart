import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:tagion_dart_api/module/basic/basic_interface.dart';
import 'package:tagion_dart_api/module/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/enums/d_runtime_response.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/basic_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/module.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// Implements the [IBasic] interface.
/// Extends the [Module] class.
/// The [Basic] class provides functionality to interact with basic features.
class Basic extends Module implements IBasic {
  final BasicFfi _basicFfi;
  final IPointerManager _pointerManager;

  Basic(
    this._basicFfi,
    this._pointerManager,
    IErrorMessage _errorMessage,
  ) : super(_errorMessage);

  @override
  bool startDRuntime() {
    int result = _basicFfi.start_rt();
    return result == DRuntimeResponse.success.index;
  }

  @override
  bool stopDRuntime() {
    int result = _basicFfi.stop_rt();
    return result == DRuntimeResponse.success.index;
  }

  @override
  String encodeBase64Url(Uint8List documentBytes) {
    Pointer<Uint8> arrayPtr = _pointerManager.allocate<Uint8>(documentBytes.length);
    _pointerManager.uint8ListToPointer(arrayPtr, documentBytes);

    Pointer<Pointer<Char>> strPtr = _pointerManager.allocate<Pointer<Char>>();
    Pointer<Uint64> strLenPtr = _pointerManager.allocate<Uint64>();

    int status = _basicFfi.tagion_basic_encode_base64url(arrayPtr, documentBytes.length, strPtr, strLenPtr);

    return scope.onExit<String, BasicApiException>(
      status,
      () => strPtr[0].toDartString(length: strLenPtr.value),
      () => _pointerManager.freeAll([arrayPtr, strPtr, strLenPtr]),
    );
  }

  @override
  String tagionRevision() {
    Pointer<Pointer<Char>> strPtr = _pointerManager.allocate<Pointer<Char>>();
    Pointer<Uint64> strLenPtr = _pointerManager.allocate<Uint64>();

    int status = _basicFfi.tagion_revision(strPtr, strLenPtr);

    return scope.onExit<String, BasicApiException>(
      status,
      () => strPtr[0].toDartString(length: strLenPtr.value),
      () => _pointerManager.freeAll([strPtr, strLenPtr]),
    );
  }

  @override
  Uint8List createDartIndex(Uint8List documentBytes) {
    Pointer<Uint8> arrayPtr = _pointerManager.allocate<Uint8>(documentBytes.length);
    _pointerManager.uint8ListToPointer(arrayPtr, documentBytes);

    Pointer<Pointer<Uint8>> indexPtr = _pointerManager.allocate<Pointer<Uint8>>();
    Pointer<Uint64> indexLenPtr = _pointerManager.allocate<Uint64>();

    int status = _basicFfi.tagion_create_dartindex(arrayPtr, documentBytes.length, indexPtr, indexLenPtr);

    return scope.onExit<Uint8List, BasicApiException>(
      status,
      () => indexPtr.value.asTypedList(indexLenPtr.value),
      () => _pointerManager.freeAll([arrayPtr, indexPtr, indexLenPtr]),
    );
  }
}
