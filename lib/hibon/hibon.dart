import 'dart:ffi';

import 'package:tagion_dart_api/enums/hibon_string_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon/hibon_exception.dart';
import 'package:tagion_dart_api/extension/char_pointer.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon_interface.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class Hibon implements IHibon {
  final HibonFfi _hibonFfi;
  final IErrorMessage _errorMessage;
  final IPointerManager _pointerManager;
  late final Pointer<HiBONT> _hibonPtr;

  Hibon(this._hibonFfi, this._errorMessage, this._pointerManager) {
    _hibonPtr = _pointerManager.allocate<HiBONT>();
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
    final Pointer<Char> valuePtr = _pointerManager.allocate<Char>(value.length);

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
}
