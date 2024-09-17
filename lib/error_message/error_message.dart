import 'dart:ffi';

import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

// FFI version implementation of the IError interface
class ErrorMessage implements IErrorMessage {
  final ErrorMessageFfi _errorsMessageFfi;
  final IPointerManager _pointerManager;

  ErrorMessage(this._errorsMessageFfi, this._pointerManager);

  @override
  void clearErrors() {
    _errorsMessageFfi.tagion_clear_error();
  }

  @override
  String getErrorText() {
    final msgPtr = _pointerManager.allocate<Pointer<Char>>();
    final msgLenPtr = _pointerManager.allocate<Uint64>();
    // Call the FFI function
    _errorsMessageFfi.tagion_error_text(msgPtr, msgLenPtr);
    final int length = msgLenPtr.value;
    final String result = msgPtr.value.toDartString(length: length);
    _pointerManager.free(msgPtr);
    _pointerManager.free(msgLenPtr);
    return result;
  }
}
