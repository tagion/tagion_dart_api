import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/basic/basic_interface.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/enums/d_runtime_response.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/basic_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class Basic implements IBasic {
  final BasicFfi _basicFfi;
  final IPointerManager _pointerManager;
  final IErrorMessage _errorMessage;

  Basic(this._basicFfi, this._pointerManager, this._errorMessage);

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
  String encodeBase64Url(Uint8List documentAsByteArray) {
    Pointer<Uint8> arrayPointer = _pointerManager.allocate<Uint8>(documentAsByteArray.length);
    _pointerManager.uint8ListToPointer(arrayPointer, documentAsByteArray);

    Pointer<Pointer<Char>> strPtr = _pointerManager.allocate<Pointer<Char>>();
    Pointer<Uint64> strLenPtr = _pointerManager.allocate<Uint64>();

    int result = _basicFfi.tagion_basic_encode_base64url(arrayPointer, documentAsByteArray.length, strPtr, strLenPtr);

    if (result != TagionErrorCode.none.value) {
      _pointerManager.free(arrayPointer);
      _pointerManager.free(strPtr);
      _pointerManager.free(strLenPtr);

      throw BasicApiException(TagionErrorCode.fromInt(result), _errorMessage.getErrorText());
    }

    String resultString = strPtr[0].toDartString(length: strLenPtr.value);

    _pointerManager.free(arrayPointer);
    _pointerManager.free(strPtr);
    _pointerManager.free(strLenPtr);

    return resultString;
  }

  @override
  String tagionRevision() {
    Pointer<Pointer<Char>> strPtr = _pointerManager.allocate<Pointer<Char>>();
    Pointer<Uint64> strLenPtr = _pointerManager.allocate<Uint64>();

    int result = _basicFfi.tagion_revision(strPtr, strLenPtr);

    if (result != TagionErrorCode.none.value) {
      _pointerManager.free(strPtr);
      _pointerManager.free(strLenPtr);

      throw BasicApiException(TagionErrorCode.fromInt(result), _errorMessage.getErrorText());
    }

    String resultString = strPtr[0].toDartString(length: strLenPtr.value);

    _pointerManager.free(strPtr);
    _pointerManager.free(strLenPtr);

    return resultString;
  }
}
