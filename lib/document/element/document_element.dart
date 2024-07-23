import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/document/element/document_element_interface.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/document/document_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// DocumentElement is a part of Document.
/// Its purpose is to get data from HiBON fields.
/// [_elementPtr] is a pointer to an Element struct.
class DocumentElement implements IDocumentElement {
  final DocumentFfi _documentFfi;
  final IPointerManager _pointerManager;
  final IErrorMessage _errorMessage;

  final Pointer<Element> _elementPtr;
  Pointer<Element> get elementPtr => _elementPtr;

  const DocumentElement(
    this._documentFfi,
    this._pointerManager,
    this._errorMessage,
    this._elementPtr,
  );

  @override
  BigInt getBigInt() {
    /// Allocate memory for the BigInt and its length.
    final bigIntPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final bigIntLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_bigint(_elementPtr, bigIntPtr, bigIntLenPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointers.
      _pointerManager.free(bigIntPtr);
      _pointerManager.free(bigIntLenPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    // /// Get the byte data from the pointer.
    final bigIntBytes = bigIntPtr.value.asTypedList(bigIntLenPtr.value);

    /// Construct the BigInt from the byte data
    var bigInt = BigInt.zero;
    for (var byte in bigIntBytes.reversed) {
      bigInt <<= 8;
      bigInt |= BigInt.from(byte);
    }

    /// Free the allocated pointers
    _pointerManager.free(bigIntPtr);
    _pointerManager.free(bigIntLenPtr);

    return bigInt;
  }

  @override
  Uint8List getBinary() {
    /// Allocate memory for the binary and its length.
    final binaryPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final binaryLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_binary(_elementPtr, binaryPtr, binaryLenPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointers.
      _pointerManager.free(binaryPtr);
      _pointerManager.free(binaryLenPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the byte data from the pointer.
    final binary = binaryPtr.value.asTypedList(binaryLenPtr.value);

    /// Free the allocated pointers
    _pointerManager.free(binaryPtr);
    _pointerManager.free(binaryLenPtr);

    return binary;
  }

  @override
  bool getBool() {
    /// Allocate memory for the bool.
    final boolPtr = _pointerManager.allocate<Bool>();

    int status = _documentFfi.tagion_document_get_bool(_elementPtr, boolPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointer.
      _pointerManager.free(boolPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the bool value.
    final boolValue = boolPtr.value;

    /// Free the allocated pointer.
    _pointerManager.free(boolPtr);

    return boolValue;
  }

  @override
  int getInt32() {
    /// Allocate memory for the int.
    final intPtr = _pointerManager.allocate<Int32>();

    int status = _documentFfi.tagion_document_get_int32(_elementPtr, intPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointer.
      _pointerManager.free(intPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the int value.
    final intValue = intPtr.value;

    /// Free the allocated pointer.
    _pointerManager.free(intPtr);

    return intValue;
  }

  @override
  int getInt64() {
    /// Allocate memory for the int.
    final intPtr = _pointerManager.allocate<Int64>();

    int status = _documentFfi.tagion_document_get_int64(_elementPtr, intPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointer.
      _pointerManager.free(intPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the int value.
    final intValue = intPtr.value;

    /// Free the allocated pointer.
    _pointerManager.free(intPtr);

    return intValue;
  }

  @override
  int getUint32() {
    /// Allocate memory for the int.
    final intPtr = _pointerManager.allocate<Uint32>();

    int status = _documentFfi.tagion_document_get_uint32(_elementPtr, intPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointer.
      _pointerManager.free(intPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the int value.
    final intValue = intPtr.value;

    /// Free the allocated pointer.
    _pointerManager.free(intPtr);

    return intValue;
  }

  @override
  int getUint64() {
    /// Allocate memory for the int.
    final intPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_uint64(_elementPtr, intPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointer.
      _pointerManager.free(intPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the int value.
    final intValue = intPtr.value;

    /// Free the allocated pointer.
    _pointerManager.free(intPtr);

    return intValue;
  }

  @override
  double getFloat32() {
    /// Allocate memory for the double.
    final floatPtr = _pointerManager.allocate<Float>();

    int status = _documentFfi.tagion_document_get_float32(_elementPtr, floatPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointer.
      _pointerManager.free(floatPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the double value.
    final floatValue = floatPtr.value;

    /// Free the allocated pointer.
    _pointerManager.free(floatPtr);

    return floatValue;
  }

  @override
  double getFloat64() {
    /// Allocate memory for the double.
    final doublePtr = _pointerManager.allocate<Double>();

    int status = _documentFfi.tagion_document_get_float64(_elementPtr, doublePtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointer.
      _pointerManager.free(doublePtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the double value.
    final doubleValue = doublePtr.value;

    /// Free the allocated pointer.
    _pointerManager.free(doublePtr);

    return doubleValue;
  }

  @override
  String getString() {
    /// Allocate memory for the string and its length.
    final stringPtr = _pointerManager.allocate<Pointer<Char>>();
    final stringLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_string(_elementPtr, stringPtr, stringLenPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointers.
      _pointerManager.free(stringPtr);
      _pointerManager.free(stringLenPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the string value.
    final resultString = stringPtr[0].toDartString(length: stringLenPtr.value);

    /// Free the allocated pointers.
    _pointerManager.free(stringPtr);
    _pointerManager.free(stringLenPtr);

    return resultString;
  }

  @override
  Uint8List getSubDocument() {
    /// Allocate memory for the sub document and its length.
    final subDocumentPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final subDocumentLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_document(_elementPtr, subDocumentPtr, subDocumentLenPtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointers.
      _pointerManager.free(subDocumentPtr);
      _pointerManager.free(subDocumentLenPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the byte data from the pointer.
    final subDocument = subDocumentPtr.value.asTypedList(subDocumentLenPtr.value);

    /// Free the allocated pointers.
    _pointerManager.free(subDocumentPtr);
    _pointerManager.free(subDocumentLenPtr);

    return subDocument;
  }

  @override
  int getTime() {
    /// Allocate memory for the time.
    final timePtr = _pointerManager.allocate<Int64>();

    int status = _documentFfi.tagion_document_get_time(_elementPtr, timePtr);

    if (status != TagionErrorCode.none.value) {
      /// Free the allocated pointer.
      _pointerManager.free(timePtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the time value.
    final time = timePtr.value;

    /// Free the allocated pointer.
    _pointerManager.free(timePtr);

    return time;
  }
}
