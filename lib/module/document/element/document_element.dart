import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/module/document/element/document_element_interface.dart';
import 'package:tagion_dart_api/module/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/document_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/module.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// DocumentElement is a part of Document.
/// Its purpose is to get data from HiBON fields.
/// [_elementPtr] is a pointer to an Element struct.
class DocumentElement extends Module implements IDocumentElement {
  final DocumentFfi _documentFfi;
  final IPointerManager _pointerManager;
  final Pointer<Element> _elementPtr;
  Pointer<Element> get elementPtr => _elementPtr;

  DocumentElement(
    this._documentFfi,
    this._pointerManager,
    IErrorMessage errorMessage,
    this._elementPtr,
  ) : super(errorMessage);

  @override
  BigInt getBigInt() {
    /// Allocate memory for the BigInt and its length.
    final bigIntPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final bigIntLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_bigint(_elementPtr, bigIntPtr, bigIntLenPtr);

    return scope.onExit<BigInt, DocumentApiException>(status, () {
      final bigIntBytes = bigIntPtr.value.asTypedList(bigIntLenPtr.value);

      /// Construct the BigInt from the byte data
      var bigInt = BigInt.zero;
      for (var byte in bigIntBytes.reversed) {
        bigInt <<= 8;
        bigInt |= BigInt.from(byte);
      }
      return bigInt;
    }, () => _pointerManager.freeAll([bigIntPtr, bigIntLenPtr]));
  }

  @override
  Uint8List getU8Array() {
    /// Allocate memory for the binary and its length.
    final binaryPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final binaryLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_u8_array(_elementPtr, binaryPtr, binaryLenPtr);

    return scope.onExit<Uint8List, DocumentApiException>(
      status,
      () => binaryPtr.value.asTypedList(binaryLenPtr.value),
      () => _pointerManager.freeAll([binaryPtr, binaryLenPtr]),
    );
  }

  @override
  bool getBool() {
    /// Allocate memory for the bool.
    final boolPtr = _pointerManager.allocate<Bool>();

    int status = _documentFfi.tagion_document_get_bool(_elementPtr, boolPtr);

    return scope.onExit<bool, DocumentApiException>(
      status,
      () => boolPtr.value,
      () => _pointerManager.free(boolPtr),
    );
  }

  @override
  int getInt32() {
    /// Allocate memory for the int.
    final intPtr = _pointerManager.allocate<Int32>();

    int status = _documentFfi.tagion_document_get_int32(_elementPtr, intPtr);

    return scope.onExit<int, DocumentApiException>(
      status,
      () => intPtr.value,
      () => _pointerManager.free(intPtr),
    );
  }

  @override
  int getInt64() {
    /// Allocate memory for the int.
    final intPtr = _pointerManager.allocate<Int64>();

    int status = _documentFfi.tagion_document_get_int64(_elementPtr, intPtr);

    return scope.onExit<int, DocumentApiException>(
      status,
      () => intPtr.value,
      () => _pointerManager.free(intPtr),
    );
  }

  @override
  int getUint32() {
    /// Allocate memory for the int.
    final intPtr = _pointerManager.allocate<Uint32>();

    int status = _documentFfi.tagion_document_get_uint32(_elementPtr, intPtr);

    return scope.onExit<int, DocumentApiException>(
      status,
      () => intPtr.value,
      () => _pointerManager.free(intPtr),
    );
  }

  @override
  int getUint64() {
    /// Allocate memory for the int.
    final intPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_uint64(_elementPtr, intPtr);

    return scope.onExit<int, DocumentApiException>(
      status,
      () => intPtr.value,
      () => _pointerManager.free(intPtr),
    );
  }

  @override
  double getFloat32() {
    /// Allocate memory for the double.
    final floatPtr = _pointerManager.allocate<Float>();

    int status = _documentFfi.tagion_document_get_float32(_elementPtr, floatPtr);

    return scope.onExit<double, DocumentApiException>(
      status,
      () => floatPtr.value,
      () => _pointerManager.free(floatPtr),
    );
  }

  @override
  double getFloat64() {
    /// Allocate memory for the double.
    final doublePtr = _pointerManager.allocate<Double>();

    int status = _documentFfi.tagion_document_get_float64(_elementPtr, doublePtr);

    return scope.onExit<double, DocumentApiException>(
      status,
      () => doublePtr.value,
      () => _pointerManager.free(doublePtr),
    );
  }

  @override
  String getString() {
    /// Allocate memory for the string and its length.
    final stringPtr = _pointerManager.allocate<Pointer<Char>>();
    final stringLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_string(_elementPtr, stringPtr, stringLenPtr);

    return scope.onExit<String, DocumentApiException>(
      status,
      () => stringPtr[0].toDartString(length: stringLenPtr.value),
      () => _pointerManager.freeAll([stringPtr, stringLenPtr]),
    );
  }

  @override
  Uint8List getSubDocument() {
    /// Allocate memory for the sub document and its length.
    final subDocumentPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final subDocumentLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_document(_elementPtr, subDocumentPtr, subDocumentLenPtr);

    return scope.onExit<Uint8List, DocumentApiException>(
      status,
      () => subDocumentPtr.value.asTypedList(subDocumentLenPtr.value),
      () => _pointerManager.freeAll([subDocumentPtr, subDocumentLenPtr]),
    );
  }

  @override
  int getTime() {
    /// Allocate memory for the time.
    final timePtr = _pointerManager.allocate<Int64>();

    int status = _documentFfi.tagion_document_get_time(_elementPtr, timePtr);

    return scope.onExit<int, DocumentApiException>(
      status,
      () => timePtr.value,
      () => _pointerManager.free(timePtr),
    );
  }
}
