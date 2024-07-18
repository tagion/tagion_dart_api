import 'dart:ffi';

import 'dart:typed_data';

import 'package:tagion_dart_api/document/element/document_element.dart';
import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/document/element/document_element_interface.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/document_error_code.dart';
import 'package:tagion_dart_api/enums/document_text_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/document/document_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// Class representing a document.
class Document implements IDocument {
  final DocumentFfi _documentFfi;
  final IPointerManager _pointerManager;
  final IErrorMessage _errorMessage;

  /// This document state as a byte array.
  final Uint8List _data;

  Document(
    this._documentFfi,
    this._pointerManager,
    this._errorMessage, {
    Uint8List? data,
  }) : _data = data ?? Uint8List(0);

  @override
  IDocumentElement getDocument(String key) {
    final dataLen = _data.lengthInBytes;
    final keyLen = key.length;

    /// Allocate memory for the data and key.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    final keyPtr = _pointerManager.allocate<Char>(keyLen);
    final elementPtr = _pointerManager.allocate<Element>();

    /// Fill necessary pointers with data.
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _data);
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
  IDocumentElement getArray(int index) {
    throw UnimplementedError();
  }

  @override
  String getRecordName() {
    /// Allocate memory.
    final dataPtr = _pointerManager.allocate<Uint8>(_data.lengthInBytes);
    final recordNamePtr = _pointerManager.allocate<Pointer<Char>>();
    final recordNameLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_record_name(
      dataPtr,
      _data.lengthInBytes,
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
    final dataPtr = _pointerManager.allocate<Uint8>(_data.lengthInBytes);
    final textPtr = _pointerManager.allocate<Pointer<Char>>();
    final textLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_text(
      dataPtr,
      _data.lengthInBytes,
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
    final dataPtr = _pointerManager.allocate<Uint8>(_data.lengthInBytes);
    final versionPtr = _pointerManager.allocate<Uint32>();

    int status = _documentFfi.tagion_document_get_version(dataPtr, _data.lengthInBytes, versionPtr);

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
    final dataPtr = _pointerManager.allocate<Uint8>(_data.lengthInBytes);
    final errorCodePtr = _pointerManager.allocate<Int32>();

    int status = _documentFfi.tagion_document_valid(dataPtr, _data.lengthInBytes, errorCodePtr);

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
