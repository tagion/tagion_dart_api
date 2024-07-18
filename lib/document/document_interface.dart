import 'dart:ffi';

import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/document_error_code.dart';
import 'package:tagion_dart_api/enums/document_text_format.dart';

abstract interface class IDocument {
  /// Get a Document element.
  Pointer<Element> getDocument(String key);

  /// Get a document element from index.
  Pointer<Element> getArray(int index);

  /// Return the version of the document.
  int getVersion();

  /// Get document record type.
  String getRecordName();

  /// Get document error code.
  DocumentErrorCode validate();

  /// Get document as string by a format.
  String getText(DocumentTextFormat textFormat);
}
