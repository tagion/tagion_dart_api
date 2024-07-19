import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/document/element/document_element_interface.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';

class DocumentElement implements IDocumentElement{
  final Pointer<Element> elementPtr;

  const DocumentElement(this.elementPtr);
  
  @override
  BigInt getBigint() {
    // TODO: implement getBigint
    throw UnimplementedError();
  }
  
  @override
  Uint8List getBinary() {
    // TODO: implement getBinary
    throw UnimplementedError();
  }
  
  @override
  bool getBool() {
    // TODO: implement getBool
    throw UnimplementedError();
  }
  
  @override
  Float getFloat32() {
    // TODO: implement getFloat32
    throw UnimplementedError();
  }
  
  @override
  Double getFloat64() {
    // TODO: implement getFloat64
    throw UnimplementedError();
  }
  
  @override
  Int32 getInt32() {
    // TODO: implement getInt32
    throw UnimplementedError();
  }
  
  @override
  Int64 getInt64() {
    // TODO: implement getInt64
    throw UnimplementedError();
  }
  
  @override
  String getString() {
    // TODO: implement getString
    throw UnimplementedError();
  }
  
  @override
  Uint8List getSubDocument() {
    // TODO: implement getSubDocument
    throw UnimplementedError();
  }
  
  @override
  int getTime() {
    // TODO: implement getTime
    throw UnimplementedError();
  }
  
  @override
  Uint32 getUint32() {
    // TODO: implement getUint32
    throw UnimplementedError();
  }
  
  @override
  Uint64 getUint64() {
    // TODO: implement getUint64
    throw UnimplementedError();
  }
}
