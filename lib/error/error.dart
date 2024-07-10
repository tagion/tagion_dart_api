import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tagion_dart_api/error/error_interface.dart';
import 'package:tagion_dart_api/error/ffi/error_ffi.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';

/// FFI version implementation of the IError interface
class Error implements IError {
  final ErrorsFfi _errorsFfi;

  const Error(this._errorsFfi);

  @override
  void clearErrors() {
    _errorsFfi.tagion_clear_error();
  }

  @override
  String getErrorMessage() {
    // Allocate memory for the error message
    final msgPtr = malloc<Char>(sizeOf<Char>());
    // Allocate memory for the length of the error message
    final msgLenPtr = malloc<Uint64>(sizeOf<Uint64>());
    // Call the FFI function
    _errorsFfi.tagion_error_text(msgPtr, msgLenPtr);
    // Retrieve the string length
    final int length = msgLenPtr.value;
    // Convert the C string to a Dart string
    final String result = msgPtr.toDartString(length: length);

    // Free the allocated memory
    malloc.free(msgPtr);
    malloc.free(msgLenPtr);

    malloc<Uint8>().cast;

    return result;
  }
}
