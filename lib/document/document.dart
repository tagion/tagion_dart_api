import 'dart:ffi';

import 'dart:typed_data';

import 'package:tagion_dart_api/document/document_element.dart';
import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/document/document_exception.dart';
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
  DocumentElement getDocument(String key) {
    final dataLen = _data.lengthInBytes;
    final keyLen = key.length;

    /// Allocate memory for the data and key.
    final dataPtr = _pointerManager.allocate<Uint8>(dataLen);
    _pointerManager.uint8ListToPointer<Uint8>(dataPtr, _data);
    final keyPtr = _pointerManager.allocate<Char>(keyLen);
    _pointerManager.stringToPointer<Char>(keyPtr, key);

    /// Allocate memory for the element.
    final elementPtr = _pointerManager.allocate<Element>();

    int status = _documentFfi.tagion_document(
      dataPtr,
      dataLen,
      keyPtr,
      keyLen,
      elementPtr,
    );

    if (status != TagionErrorCode.none.value) {
      throw DocumentException(TagionErrorCode.values[status], _errorMessage.getErrorText());
    }

    final element = elementPtr.ref.data.asTypedList(_data.lengthInBytes);

    /// Free the memory.
    _pointerManager.free(dataPtr);
    _pointerManager.free(keyPtr);
    _pointerManager.free(elementPtr);

    return DocumentElement(element, key);
  }

  @override
  DocumentElement getArray(Uint8List buffer, int index) {
    // TODO: implement getArray
    throw UnimplementedError();
  }

  @override
  BigInt getBigint(DocumentElement element) {
    // TODO: implement getBigint
    throw UnimplementedError();
  }

  @override
  Uint8List getBinary(DocumentElement element) {
    // TODO: implement getBinary
    throw UnimplementedError();
  }

  @override
  bool getBool(DocumentElement element) {
    // _documentFfi.tagion_document_get_bool(element, value)
    // TODO: implement getBool
    throw UnimplementedError();
  }

  @override
  Uint8List getSubDocument(DocumentElement element) {
    // TODO: implement getDocument
    throw UnimplementedError();
  }

  @override
  Float getFloat32(DocumentElement element) {
    // TODO: implement getFloat32
    throw UnimplementedError();
  }

  @override
  Double getFloat64(DocumentElement element) {
    // TODO: implement getFloat64
    throw UnimplementedError();
  }

  @override
  Int32 getInt32(DocumentElement element) {
    // TODO: implement getInt32
    throw UnimplementedError();
  }

  @override
  Int64 getInt64(DocumentElement element) {
    // TODO: implement getInt64
    throw UnimplementedError();
  }

  @override
  String getRecordName(Uint8List buffer) {
    // TODO: implement getRecordName
    throw UnimplementedError();
  }

  @override
  String getString(DocumentElement element) {
    // TODO: implement getString
    throw UnimplementedError();
  }

  @override
  String getText(Uint8List buffer, int textFormat) {
    // Format to use for tagion_document_get_text
    // DocumentTextFormat

    // TODO: implement getText
    throw UnimplementedError();
  }

  @override
  int getTime(DocumentElement element) {
    // TODO: implement getTime
    throw UnimplementedError();
  }

  @override
  Uint32 getUint32(DocumentElement element) {
    // TODO: implement getUint32
    throw UnimplementedError();
  }

  @override
  Uint64 getUint64(DocumentElement element) {
    // TODO: implement getUint64
    throw UnimplementedError();
  }

  @override
  int getVersion(Uint8List buffer) {
    // TODO: implement getVersion
    throw UnimplementedError();
  }

  @override
  int validate(Uint8List buffer) {
    // TODO: implement validate
    throw UnimplementedError();
  }
}
