import 'dart:typed_data';

import 'package:tagion_dart_api/document/element/document_element_interface.dart';
import 'package:tagion_dart_api/enums/document_error_code.dart';
import 'package:tagion_dart_api/enums/document_text_format.dart';

abstract interface class IDocument {

  /// Get the data of the document.
  Uint8List getData();

  /// Get a Document element.
  IDocumentElement getElementByKey(String key);

  /// Get a document element from index.
  IDocumentElement getElementByIndex(int index);

  /// Return the version of the document.
  int getVersion();

  /// Get document record type.
  String getRecordName();

  /// Get document error code.
  DocumentErrorCode validate();

  /// Get document as string by a format.
  String getAsString(DocumentTextFormat textFormat);
}
