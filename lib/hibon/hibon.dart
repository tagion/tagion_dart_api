import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/document/document.dart';
import 'package:tagion_dart_api/document/document_interface.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/hibon_string_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon_interface.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

class Hibon implements IHibon {
  final HibonFfi _hibonFfi;
  final IErrorMessage _errorMessage;
  final IPointerManager _pointerManager;
  late final Pointer<HiBONT> _hibonPtr;

  Hibon(
    this._hibonFfi,
    this._errorMessage,
    this._pointerManager,
  ) {
    _hibonPtr = _pointerManager.allocate<HiBONT>();
  }

  @override
  Pointer<HiBONT> getPointer() {
    return _hibonPtr;
  }

  @override
  void init() {
    final int createResult = _hibonFfi.tagion_hibon_create(_hibonPtr);
    if (createResult != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(createResult), _errorMessage.getErrorText());
    }
  }

  @override
  void addString(String key, String value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);
    final Pointer<Char> valuePtr = _pointerManager.allocate<Char>(value.length);
    _pointerManager.stringToPointer(valuePtr, value);

    final int addStringResult =
        _hibonFfi.tagion_hibon_add_string(_hibonPtr, keyPtr, key.length, valuePtr, value.length);

    if (addStringResult != TagionErrorCode.none.value) {
      _pointerManager.free(keyPtr);
      _pointerManager.free(valuePtr);

      throw HibonException(TagionErrorCode.fromInt(addStringResult), _errorMessage.getErrorText());
    }

    _pointerManager.free(keyPtr);
    _pointerManager.free(valuePtr);
  }

  @override
  String getAsString([HibonAsStringFormat format = HibonAsStringFormat.prettyJson]) {
    final Pointer<Pointer<Char>> charArrayPtr = _pointerManager.allocate<Pointer<Char>>();
    final Pointer<Uint64> charArrayLenPtr = _pointerManager.allocate<Uint64>();

    final int getTextResult = _hibonFfi.tagion_hibon_get_text(_hibonPtr, format.index, charArrayPtr, charArrayLenPtr);

    if (getTextResult != TagionErrorCode.none.value) {
      _pointerManager.free(charArrayPtr);
      _pointerManager.free(charArrayLenPtr);
      throw HibonException(TagionErrorCode.fromInt(getTextResult), _errorMessage.getErrorText());
    }

    final resultString = charArrayPtr[0].toDartString(length: charArrayLenPtr.value);

    _pointerManager.free(charArrayPtr);
    _pointerManager.free(charArrayLenPtr);

    return resultString;
  }

  @override
  void free() {
    _hibonFfi.tagion_hibon_free(_hibonPtr);
  }

  @override
  void addBigint(String key, BigInt value) {
    /// Convert the BigInt value to a Uint8List.
    final Uint8List uint8ArrayValue = Uint8List.fromList(utf8.encode(value.toRadixString(16)));

    /// Allocate memory for the key and value.
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Uint8> valuePtr = _pointerManager.allocate<Uint8>(uint8ArrayValue.length);

    /// Write the key and value to pointers.
    _pointerManager.stringToPointer(keyPtr, key);
    _pointerManager.uint8ListToPointer(valuePtr, uint8ArrayValue);

    int status = _hibonFfi.tagion_hibon_add_bigint(_hibonPtr, keyPtr, key.length, valuePtr, uint8ArrayValue.length);

    _pointerManager.free(keyPtr);
    _pointerManager.free(valuePtr);

    /// Check if the operation was successful.
    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addBool(String key, bool value) {
    /// Allocate memory for the key.
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);

    /// Write the key to the pointer.
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_bool(_hibonPtr, keyPtr, key.length, value);

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  IDocument getDocument() {
    final Pointer<Pointer<Uint8>> bufferPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final Pointer<Uint64> bufferLenPtr = _pointerManager.allocate<Uint64>();

    final int status = _hibonFfi.tagion_hibon_get_document(_hibonPtr, bufferPtr, bufferLenPtr);

    if (status != TagionErrorCode.none.value) {
      _pointerManager.free(bufferPtr);
      _pointerManager.free(bufferLenPtr);
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    final Uint8List buffer = bufferPtr[0].asTypedList(bufferLenPtr.value);

    _pointerManager.free(bufferPtr);
    _pointerManager.free(bufferLenPtr);

    /// TODO: Implement the locator class.
    /// It is necessary create the Document via locator with injected dependencies.
    return Document(
      DocumentFfi(FFILibraryUtil.load()),
      _pointerManager,
      _errorMessage,
      buffer,
    );
  }

  @override
  void addDocument(String key, IDocument document) {
    final docData = document.getData();

    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Uint8> documentPtr = _pointerManager.allocate<Uint8>(docData.length);

    _pointerManager.stringToPointer(keyPtr, key);
    _pointerManager.uint8ListToPointer(documentPtr, docData);

    final int status = _hibonFfi.tagion_hibon_add_document(_hibonPtr, keyPtr, key.length, documentPtr, docData.length);

    _pointerManager.free(keyPtr);
    _pointerManager.free(documentPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addHibon(String key, IHibon hibon) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);

    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_hibon(_hibonPtr, keyPtr, key.length, hibon.getPointer());

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addFloat32(String key, double value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_float32(_hibonPtr, keyPtr, key.length, value);

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addFloat64(String key, double value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_float64(_hibonPtr, keyPtr, key.length, value);

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addInt32(String key, int value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_int32(_hibonPtr, keyPtr, key.length, value);

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addInt64(String key, int value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_int64(_hibonPtr, keyPtr, key.length, value);

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addUint32(String key, int value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_uint32(_hibonPtr, keyPtr, key.length, value);

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addUint64(String key, int value) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_uint64(_hibonPtr, keyPtr, key.length, value);

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addTypedArray<T>(String key, Uint8List array) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    final Pointer<Uint8> arrayPtr = _pointerManager.allocate<Uint8>(array.length);

    _pointerManager.stringToPointer(keyPtr, key);
    _pointerManager.uint8ListToPointer(arrayPtr, array);

    int status = 0;
    switch (T) {
      case Float32List:
        status = _hibonFfi.tagion_hibon_add_array_float32(_hibonPtr, keyPtr, key.length, arrayPtr, array.length);
        break;
      case Float64List:
        status = _hibonFfi.tagion_hibon_add_array_float64(_hibonPtr, keyPtr, key.length, arrayPtr, array.length);
        break;
      case Int32List:
        status = _hibonFfi.tagion_hibon_add_array_int32(_hibonPtr, keyPtr, key.length, arrayPtr, array.length);
        break;
      case Int64List:
        status = _hibonFfi.tagion_hibon_add_array_int64(_hibonPtr, keyPtr, key.length, arrayPtr, array.length);
        break;
      case Uint32List:
        status = _hibonFfi.tagion_hibon_add_array_uint32(_hibonPtr, keyPtr, key.length, arrayPtr, array.length);
        break;
      case Uint64List:
        status = _hibonFfi.tagion_hibon_add_array_uint64(_hibonPtr, keyPtr, key.length, arrayPtr, array.length);
        break;
      case Uint8List:
        status = _hibonFfi.tagion_hibon_add_binary(_hibonPtr, keyPtr, key.length, arrayPtr, array.length);
        break;
      default:
        throw Exception('Unsupported type');
    }

    _pointerManager.free(keyPtr);
    _pointerManager.free(arrayPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  @override
  void addTime(String key, int time) {
    final Pointer<Char> keyPtr = _pointerManager.allocate<Char>(key.length);
    _pointerManager.stringToPointer(keyPtr, key);

    final int status = _hibonFfi.tagion_hibon_add_time(_hibonPtr, keyPtr, key.length, time);

    _pointerManager.free(keyPtr);

    if (status != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }
}
