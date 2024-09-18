import 'dart:ffi';

import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/dynamic_library_loader.dart';

// FFI version implementation of the IError interface
class ErrorMessage implements IErrorMessage {
  final ErrorMessageFfi _errorsMessageFfi;
  final IPointerManager _pointerManager;

  const ErrorMessage(this._errorsMessageFfi, this._pointerManager);

  ErrorMessage.init()
      : _errorsMessageFfi = ErrorMessageFfi(DynamicLibraryLoader.load()),
        _pointerManager = const PointerManager();

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
