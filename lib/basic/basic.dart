import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:tagion_dart_api/basic/basic_interface.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
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

  Basic(this._basicFfi, this._pointerManager, IErrorMessage _errorMessage) : super(_errorMessage);

  /// Starts the D runtime.
  @override
  bool startDRuntime() {
    int result = _basicFfi.start_rt();
    return result == DRuntimeResponse.success.index;
  }

  /// Stops the D runtime.
  @override
  bool stopDRuntime() {
    int result = _basicFfi.stop_rt();
    return result == DRuntimeResponse.success.index;
  }

  /// Encodes a byte array to a base64 URL string.
  @override
  String encodeBase64Url(Uint8List documentAsByteArray) {
    Pointer<Uint8> arrayPointer = _pointerManager.allocate<Uint8>(documentAsByteArray.length);
    _pointerManager.uint8ListToPointer(arrayPointer, documentAsByteArray);

    Pointer<Pointer<Char>> strPtr = _pointerManager.allocate<Pointer<Char>>();
    Pointer<Uint64> strLenPtr = _pointerManager.allocate<Uint64>();

    int status = _basicFfi.tagion_basic_encode_base64url(arrayPointer, documentAsByteArray.length, strPtr, strLenPtr);

    return scope.onExit<String, BasicApiException>(
      status,
      () => strPtr[0].toDartString(length: strLenPtr.value),
      () => _pointerManager.freeAll([arrayPointer, strPtr, strLenPtr]),
    );
  }

  /// Returns an information about current binary's version.
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
}
