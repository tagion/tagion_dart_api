import 'dart:ffi' as ffi;
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tagion_dart_api/enums/hibon_string_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/hibon/hibon_exception.dart';
import 'package:tagion_dart_api/exception/hibon/hibon_exception_message.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon_interface.dart';

class Hibon implements IHibon {
  final HibonFfi _hibonFfi;
  late final ffi.Pointer<HiBONT> _hibonPtr;

  Hibon(this._hibonFfi) {
    _hibonPtr = malloc<HiBONT>();
  }

  @override
  void init() {
    final int createResult = _hibonFfi.tagion_hibon_create(_hibonPtr);
    if (createResult != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(createResult), HibonExceptionMessage.create);
    }
  }

  @override
  void addString(String key, String value) {
    final Pointer<ffi.Char> keyPtr = malloc<ffi.Char>(key.length);
    final Pointer<ffi.Char> valuePtr = malloc<ffi.Char>(value.length);

    final int addStringResult =
        _hibonFfi.tagion_hibon_add_string(_hibonPtr, keyPtr, key.length, valuePtr, value.length);

    if (addStringResult != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(addStringResult), HibonExceptionMessage.addString);
    }

    malloc.free(keyPtr);
    malloc.free(valuePtr);
  }

  @override
  String getAsString([HibonAsStringFormat format = HibonAsStringFormat.prettyJson]) {
    final Pointer<Pointer<ffi.Char>> charArrayPtr = malloc<ffi.Pointer<ffi.Char>>();
    final Pointer<ffi.Uint64> charArrayLenPtr = malloc<ffi.Uint64>();

    final int getTextResult = _hibonFfi.tagion_hibon_get_text(_hibonPtr, format.index, charArrayPtr, charArrayLenPtr);

    if (getTextResult != TagionErrorCode.none.value) {
      throw HibonException(TagionErrorCode.fromInt(getTextResult), HibonExceptionMessage.getAsString);
    }

    final List<String> resultStringArray = [];
    for (int i = 0; i < charArrayLenPtr.value; i++) {
      resultStringArray.add(charArrayPtr[i].cast<Utf8>().toDartString());
    }

    malloc.free(charArrayPtr);
    malloc.free(charArrayLenPtr);

    return resultStringArray.join();
  }

  @override
  void free() {
    _hibonFfi.tagion_hibon_free(_hibonPtr);
  }
}
