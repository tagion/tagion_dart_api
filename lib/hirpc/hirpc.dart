import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';
import 'package:tagion_dart_api/hirpc/hirpc_interface.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';

/// HiRPC class.
/// Provides functionality for HiRPC messages creation.
class TagionHiRPC implements IHiRPC {
  final CryptoFfi _ffi;
  final PointerManager _pointerManager;
  final ErrorMessage _errorMessage;

  TagionHiRPC(
    this._ffi,
    this._pointerManager,
    this._errorMessage,
  );

  /// Create a sender.
  /// Returns a [Uint8List] sender.
  /// Throws a [TagionException] if an error occurs.
  /// The [method] parameter is a string.
  /// The [docBuffer] optional parameter is a [Uint8List].
  @override
  Uint8List createSender(String method, [Uint8List? docBuffer]) {
    final int methodLen = method.length;
    final Pointer<Char> methodPtr = _pointerManager.allocate<Char>(methodLen);
    _pointerManager.stringToPointer(methodPtr, method);

    int docBufferLen = 0;
    Pointer<Uint8> docBufferPtr = nullptr;

    if (docBuffer != null) {
      docBufferLen = docBuffer.length;
      docBufferPtr = _pointerManager.allocate<Uint8>(docBufferLen);
      _pointerManager.uint8ListToPointer(docBufferPtr, docBuffer);
    }

    final Pointer<Pointer<Uint8>> resultPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final Pointer<Uint64> resultLenPtr = _pointerManager.allocate<Uint64>();

    final status = _ffi.tagion_hirpc_create_sender(
      methodPtr,
      methodLen,
      docBufferPtr,
      docBufferLen,
      resultPtr,
      resultLenPtr,
    );

    if (status != TagionErrorCode.none.value) {
      _pointerManager.free(methodPtr);
      _pointerManager.free(docBufferPtr);
      _pointerManager.free(resultPtr);
      throw TagionException(TagionErrorCode.values[status], _errorMessage.getErrorText());
    }

    final result = resultPtr.value.asTypedList(resultLenPtr.value);

    _pointerManager.free(methodPtr);
    _pointerManager.free(docBufferPtr);
    _pointerManager.free(resultPtr);

    return result;
  }

  /// Create a signed sender.
  /// Returns a [Uint8List] signed sender.
  /// Throws a [TagionException] if an error occurs.
  /// The [method] parameter is a string.
  /// The [vault] parameter is a [SecureNetVault].
  /// The [docBuffer] optional parameter is a [Uint8List].
  /// The [deriver] optional parameter is a [Uint8List].
  @override
  Uint8List createSignedSender(String method, SecureNetVault vault, [Uint8List? docBuffer, Uint8List? deriver]) {
    final int methodLen = method.length;
    final Pointer<Char> methodPtr = _pointerManager.allocate<Char>(methodLen);
    _pointerManager.stringToPointer(methodPtr, method);

    int docBufferLen = 0;
    Pointer<Uint8> docBufferPtr = nullptr;

    if (docBuffer != null) {
      docBufferLen = docBuffer.length;
      docBufferPtr = _pointerManager.allocate<Uint8>(docBufferLen);
      _pointerManager.uint8ListToPointer(docBufferPtr, docBuffer);
    }

    int deriverLen = 0;
    Pointer<Uint8> deriverPtr = nullptr;

    if (deriver != null) {
      deriverLen = deriver.length;
      deriverPtr = _pointerManager.allocate<Uint8>(deriverLen);
      _pointerManager.uint8ListToPointer(deriverPtr, deriver);
    }

    final Pointer<Pointer<Uint8>> resultPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final Pointer<Uint64> resultLenPtr = _pointerManager.allocate<Uint64>();

    final status = _ffi.tagion_hirpc_create_signed_sender(
      methodPtr,
      methodLen,
      docBufferPtr,
      docBufferLen,
      vault.secureNetPtr,
      deriverPtr,
      deriverLen,
      resultPtr,
      resultLenPtr,
    );

    if (status != TagionErrorCode.none.value) {
      _pointerManager.free(methodPtr);
      _pointerManager.free(docBufferPtr);
      _pointerManager.free(deriverPtr);
      _pointerManager.free(resultPtr);
      throw TagionException(TagionErrorCode.values[status], _errorMessage.getErrorText());
    }

    final result = resultPtr.value.asTypedList(resultLenPtr.value);

    _pointerManager.free(methodPtr);
    _pointerManager.free(docBufferPtr);
    _pointerManager.free(deriverPtr);
    _pointerManager.free(resultPtr);

    return result;
  }
}
