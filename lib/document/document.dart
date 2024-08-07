import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/document/element/document_element.dart';
import 'package:tagion_dart_api/document/element/document_element_interface.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/document_error_code.dart';
import 'package:tagion_dart_api/enums/document_text_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/document_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// Document’s purpose is to get data from a serialized HiBON.
/// [_hibonBuffer] is HiBON in form of byte array.
/// HiBON’s byte array can be obtained from HiBON.getDocument().
/// Document guarantees immutability of HiBON.
class Document implements IDocument {
  final DocumentFfi _documentFfi;
  final IPointerManager _pointerManager;
  final IErrorMessage _errorMessage;

  final Uint8List _hibonBuffer;

  const Document(
    this._documentFfi,
    this._pointerManager,
    this._errorMessage,
    this._hibonBuffer,
  );

  @override
  Uint8List getData() {
    return _hibonBuffer;
  }

  @override
  IDocumentElement getElementByKey(String key) {
    final dataLen = _hibonBuffer.lengthInBytes;
    final keyLen = key.length;

    /// Allocate memory for the data and key.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    final keyPtr = _pointerManager.allocate<Char>(keyLen);
    final elementPtr = _pointerManager.allocate<Element>();

    /// Fill necessary pointers with data.
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _hibonBuffer);
    _pointerManager.stringToPointer<Char>(keyPtr, key);

    int status = _documentFfi.tagion_document_element_by_key(
      dataPtr,
      dataLen,
      keyPtr,
      keyLen,
      elementPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(dataPtr);
      _pointerManager.free(keyPtr);
      _pointerManager.free(elementPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Free the memory.
    _pointerManager.free(keyPtr);

    return DocumentElement(
      _documentFfi,
      _pointerManager,
      _errorMessage,
      elementPtr,
    );
  }

  @override
  IDocumentElement getElementByIndex(int index) {
    final dataLen = _hibonBuffer.lengthInBytes;

    /// Allocate memory for the data and key.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    final elementPtr = _pointerManager.allocate<Element>();

    /// Fill necessary pointers with data.
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _hibonBuffer);

    int status = _documentFfi.tagion_document_element_by_index(
      dataPtr,
      dataLen,
      index,
      elementPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(dataPtr);
      _pointerManager.free(elementPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    return DocumentElement(
      _documentFfi,
      _pointerManager,
      _errorMessage,
      elementPtr,
    );
  }

  @override
  String getRecordName() {
    /// Get the length of the data.
    final dataLen = _hibonBuffer.lengthInBytes;

    /// Allocate memory.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    final recordNamePtr = _pointerManager.allocate<Pointer<Char>>();
    final recordNameLenPtr = _pointerManager.allocate<Uint64>();

    /// Fill necessary pointers with data.
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _hibonBuffer);

    int status = _documentFfi.tagion_document_get_record_name(
      dataPtr,
      dataLen,
      recordNamePtr,
      recordNameLenPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(dataPtr);
      _pointerManager.free(recordNamePtr);
      _pointerManager.free(recordNameLenPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the record name value.
    final resultString = recordNamePtr[0].toDartString(length: recordNameLenPtr.value);

    /// Free the memory.
    _pointerManager.free(dataPtr);
    _pointerManager.free(recordNamePtr);
    _pointerManager.free(recordNameLenPtr);

    return resultString;
  }

  @override
  String getAsString(DocumentTextFormat textFormat) {
    final dataLen = _hibonBuffer.lengthInBytes;

    /// Allocate memory.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    final textPtr = _pointerManager.allocate<Pointer<Char>>();
    final textLenPtr = _pointerManager.allocate<Uint64>();

    /// Fill necessary pointers with data.
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _hibonBuffer);

    int status = _documentFfi.tagion_document_get_text(
      dataPtr,
      dataLen,
      textFormat.index,
      textPtr,
      textLenPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(dataPtr);
      _pointerManager.free(textPtr);
      _pointerManager.free(textLenPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the text value.
    final resultString = textPtr[0].toDartString(length: textLenPtr.value);

    /// Free the memory.
    _pointerManager.free(dataPtr);
    _pointerManager.free(textPtr);
    _pointerManager.free(textLenPtr);

    return resultString;
  }

  @override
  int getVersion() {
    final dataLen = _hibonBuffer.lengthInBytes;

    /// Allocate memory for the data and version.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    final versionPtr = _pointerManager.allocate<Uint32>();

    /// Fill necessary pointers with data.
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _hibonBuffer);

    int status = _documentFfi.tagion_document_get_version(
      dataPtr,
      dataLen,
      versionPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(dataPtr);
      _pointerManager.free(versionPtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the version.
    final version = versionPtr.value;

    /// Free the memory.
    _pointerManager.free(dataPtr);
    _pointerManager.free(versionPtr);

    return version;
  }

  @override
  DocumentErrorCode validate() {
    final dataLen = _hibonBuffer.lengthInBytes;

    /// Allocate memory for the data and error code.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    final errorCodePtr = _pointerManager.allocate<Int32>();

    /// Fill necessary pointers with data.
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _hibonBuffer);

    int status = _documentFfi.tagion_document_valid(dataPtr, dataLen, errorCodePtr);

    if (status != TagionErrorCode.none.value) {
      /// Free memory.
      _pointerManager.free(dataPtr);
      _pointerManager.free(errorCodePtr);
      throw DocumentException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Ghe the error code.
    int errorCode = errorCodePtr.value;

    /// Free memory.
    _pointerManager.free(dataPtr);
    _pointerManager.free(errorCodePtr);

    return DocumentErrorCode.values[errorCode];
  }
}
