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
import 'package:tagion_dart_api/exception/document/document_exception.dart';
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

  Document(
    this._documentFfi,
    this._pointerManager,
    this._errorMessage, {
    Uint8List? hibonBuffer,
  }) : _hibonBuffer = hibonBuffer ?? Uint8List(0);

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

    int status = _documentFfi.tagion_document(
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
    _pointerManager.free(dataPtr);
    _pointerManager.free(keyPtr);

    return DocumentElement(elementPtr);
  }

  @override
  IDocumentElement getElementByIndex(int index) {
    final dataLen = _hibonBuffer.lengthInBytes;

    /// Allocate memory for the data and key.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    final elementPtr = _pointerManager.allocate<Element>();

    /// Fill necessary pointers with data.
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _hibonBuffer);

    int status = _documentFfi.tagion_document_array(
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

    /// Free the memory.
    _pointerManager.free(dataPtr);

    return DocumentElement(elementPtr);
  }

  @override
  String getRecordName() {
    /// Allocate memory.
    final dataPtr = _pointerManager.allocate<Uint8>(_hibonBuffer.lengthInBytes);
    final recordNamePtr = _pointerManager.allocate<Pointer<Char>>();
    final recordNameLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_record_name(
      dataPtr,
      _hibonBuffer.lengthInBytes,
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
  String getText(DocumentTextFormat textFormat) {
    /// Allocate memory.
    final dataPtr = _pointerManager.allocate<Uint8>(_hibonBuffer.lengthInBytes);
    final textPtr = _pointerManager.allocate<Pointer<Char>>();
    final textLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_text(
      dataPtr,
      _hibonBuffer.lengthInBytes,
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
    /// Allocate memory for the data and version.
    final dataPtr = _pointerManager.allocate<Uint8>(_hibonBuffer.lengthInBytes);
    final versionPtr = _pointerManager.allocate<Uint32>();

    int status = _documentFfi.tagion_document_get_version(dataPtr, _hibonBuffer.lengthInBytes, versionPtr);

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
    /// Allocate memory for the data and error code.
    final dataPtr = _pointerManager.allocate<Uint8>(_hibonBuffer.lengthInBytes);
    final errorCodePtr = _pointerManager.allocate<Int32>();

    int status = _documentFfi.tagion_document_valid(dataPtr, _hibonBuffer.lengthInBytes, errorCodePtr);

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
