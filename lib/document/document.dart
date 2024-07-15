import 'dart:ffi';

import 'dart:typed_data';

import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';

/// Class representing a document.
class Document implements IDocument {
  final DocumentFfi _documentFfi;
  final PointerManager _pointerManager;

  const Document(this._documentFfi, this._pointerManager);

  @override
  Element getArray(Uint8List buffer, int index) {
    // TODO: implement getArray
    throw UnimplementedError();
  }

  @override
  BigInt getBigint(Element element) {
    // TODO: implement getBigint
    throw UnimplementedError();
  }

  @override
  Uint8List getBinary(Element element) {
    // TODO: implement getBinary
    throw UnimplementedError();
  }

  @override
  bool getBool(Element element) {
    // TODO: implement getBool
    throw UnimplementedError();
  }

  @override
  Uint8List getSubDocument(Element element) {
    // TODO: implement getDocument
    throw UnimplementedError();
  }

  @override
  Element getDocument(Uint8List buffer, String key) {
    final bufferPtr = _pointerManager.allocate<Uint8>(buffer.lengthInBytes);
    final keyPtr = _pointerManager.allocate<Char>(key.length);
    final elementPtr = _pointerManager.allocate<Element>(sizeOf<Uint8>());

    int status = _documentFfi.tagion_document(bufferPtr, buffer.lengthInBytes, keyPtr, key.length, elementPtr);

    if (status != 0) {
      throw Exception('Failed to get document element');
    }

    return elementPtr.ref;
  }

  @override
  Float getFloat32(Element element) {
    // TODO: implement getFloat32
    throw UnimplementedError();
  }

  @override
  Double getFloat64(Element element) {
    // TODO: implement getFloat64
    throw UnimplementedError();
  }

  @override
  Int32 getInt32(Element element) {
    // TODO: implement getInt32
    throw UnimplementedError();
  }

  @override
  Int64 getInt64(Element element) {
    // TODO: implement getInt64
    throw UnimplementedError();
  }

  @override
  String getRecordName(Uint8List buffer) {
    // TODO: implement getRecordName
    throw UnimplementedError();
  }

  @override
  String getString(Element element) {
    // TODO: implement getString
    throw UnimplementedError();
  }

  @override
  String getText(Uint8List buffer, int textFormat) {
    // TODO: implement getText
    throw UnimplementedError();
  }

  @override
  int getTime(Element element) {
    // TODO: implement getTime
    throw UnimplementedError();
  }

  @override
  Uint32 getUint32(Element element) {
    // TODO: implement getUint32
    throw UnimplementedError();
  }

  @override
  Uint64 getUint64(Element element) {
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
