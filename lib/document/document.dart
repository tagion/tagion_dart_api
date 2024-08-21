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

/// Document’s purpose is to read data from a serialized HiBON.
/// Document guarantees immutability of HiBON.
class Document implements IDocument, Finalizable {
  final DocumentFfi _documentFfi;
  final IPointerManager _pointerManager;
  final IErrorMessage _errorMessage;

  final Pointer<Uint8> _hibonPtr;
  final int _hibonLen;

  static final _finalizer = Finalizer<void Function()>((f) => f());

  Document(
    this._documentFfi,
    this._pointerManager,
    this._errorMessage,
    Uint8List hibonBuffer,
  )   : _hibonPtr = _pointerManager.allocate<Uint8>(hibonBuffer.lengthInBytes), // Allocate memory for the HiBON.
        _hibonLen = hibonBuffer.lengthInBytes {
    _pointerManager.uint8ListToPointer<Uint8>(_hibonPtr, hibonBuffer); // Fill the pointer with data.
    _finalizer.attach(this, dispose, detach: this); // Attach the finalizer with a dispose function.
  }

  @override
  void dispose() {
    _pointerManager.free(_hibonPtr); // Free the memory.
    _finalizer.detach(this);
  }

  @override
  IDocumentElement getElementByKey(String key) {
    final keyLen = key.length;

    /// Allocate memory for the key and the element.
    final keyPtr = _pointerManager.allocate<Char>(keyLen);
    final elementPtr = _pointerManager.allocate<Element>();

    /// Fill necessary pointers with data.
    _pointerManager.stringToPointer<Char>(keyPtr, key);

    int status = _documentFfi.tagion_document_element_by_key(
      _hibonPtr,
      _hibonLen,
      keyPtr,
      keyLen,
      elementPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(keyPtr);
      _pointerManager.free(elementPtr);
      throw DocumentApiException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
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
    final elementPtr = _pointerManager.allocate<Element>();

    int status = _documentFfi.tagion_document_element_by_index(
      _hibonPtr,
      _hibonLen,
      index,
      elementPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(elementPtr);
      throw DocumentApiException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
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
    /// Allocate memory for the record name and its length.
    final recordNamePtr = _pointerManager.allocate<Pointer<Char>>();
    final recordNameLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_record_name(
      _hibonPtr,
      _hibonLen,
      recordNamePtr,
      recordNameLenPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(recordNamePtr);
      _pointerManager.free(recordNameLenPtr);
      throw DocumentApiException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the record name value.
    final resultString = recordNamePtr[0].toDartString(length: recordNameLenPtr.value);

    /// Free the memory.
    _pointerManager.free(recordNamePtr);
    _pointerManager.free(recordNameLenPtr);

    return resultString;
  }

  @override
  String getAsString(DocumentTextFormat textFormat) {
    /// Allocate memory for the text and its length.
    final textPtr = _pointerManager.allocate<Pointer<Char>>();
    final textLenPtr = _pointerManager.allocate<Uint64>();

    int status = _documentFfi.tagion_document_get_text(
      _hibonPtr,
      _hibonLen,
      textFormat.index,
      textPtr,
      textLenPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(textPtr);
      _pointerManager.free(textLenPtr);
      throw DocumentApiException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the text value.
    final resultString = textPtr[0].toDartString(length: textLenPtr.value);

    /// Free the memory.
    _pointerManager.free(textPtr);
    _pointerManager.free(textLenPtr);

    return resultString;
  }

  @override
  int getVersion() {
    final versionPtr = _pointerManager.allocate<Uint32>();

    int status = _documentFfi.tagion_document_get_version(
      _hibonPtr,
      _hibonLen,
      versionPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free the memory.
      _pointerManager.free(versionPtr);
      throw DocumentApiException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the version.
    final version = versionPtr.value;

    /// Free the memory.
    _pointerManager.free(versionPtr);

    return version;
  }

  @override
  DocumentErrorCode validate() {
    final errorCodePtr = _pointerManager.allocate<Int32>();

    int status = _documentFfi.tagion_document_valid(
      _hibonPtr,
      _hibonLen,
      errorCodePtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free memory.

      _pointerManager.free(errorCodePtr);
      throw DocumentApiException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Ghe the error code.
    int errorCode = errorCodePtr.value;

    /// Free memory.
    _pointerManager.free(errorCodePtr);

    return DocumentErrorCode.values[errorCode];
  }
}
