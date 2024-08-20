import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';
import 'package:tagion_dart_api/hirpc/hirpc_interface.dart';
import 'package:tagion_dart_api/module.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// HiRPC class.
/// Provides functionality for HiRPC messages creation.
class TagionHiRPC extends Module implements IHiRPC {
  final CryptoFfi _ffi;
  final IPointerManager _pointerManager;

  TagionHiRPC(
    this._ffi,
    this._pointerManager,
    IErrorMessage errorMessage,
  ) : super(_pointerManager, errorMessage);

  /// Create a hirpc request.
  /// Returns a resulting hirpc as a document buffer of [Uint8List] type.
  /// Throws a [TagionApiException] if an error occurs.
  /// The [method] parameter is a [String].
  /// The [docBuffer] optional parameter is a [Uint8List].
  @override
  Uint8List createRequest(String method, [Uint8List? docBuffer]) {
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

    return scope
        .onExit(status, () => resultPtr.value.asTypedList(resultLenPtr.value), [methodPtr, docBufferPtr, resultPtr]);
  }

  /// Create a signed hirpc request.
  /// Returns a resulting hirpc as a document buffer of [Uint8List] type.
  /// Throws a [TagionApiException] if an error occurs.
  /// The [method] parameter is a [String].
  /// The [secureNetPtr] parameter is a [Pointer] to [SecureNet].
  /// The [docBuffer] optional parameter is a [Uint8List].
  /// The [deriver] optional parameter is a [Uint8List].
  @override
  Uint8List createSignedRequest(String method, Pointer<SecureNet> secureNetPtr,
      [Uint8List? docBuffer, Uint8List? deriver]) {
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
      secureNetPtr,
      deriverPtr,
      deriverLen,
      resultPtr,
      resultLenPtr,
    );

    return scope.onExit(status, () => resultPtr.value.asTypedList(resultLenPtr.value),
        [methodPtr, docBufferPtr, deriverPtr, resultPtr, resultLenPtr]);
  }
}
