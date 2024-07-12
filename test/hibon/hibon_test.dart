import 'dart:ffi' as ffi;
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/hibon/hibon_exception.dart';
import 'package:tagion_dart_api/exception/hibon/hibon_exception_message.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';

class HibonFfiMock extends Mock implements HibonFfi {}

void main() {
  registerFallbackValue(malloc<HiBONT>());

  group('Hibon unit test.', () {
    final HibonFfiMock hibonFfi = HibonFfiMock();
    final Hibon hibon = Hibon(hibonFfi);

    test('Create hibon', () {
      when(() => hibonFfi.tagion_hibon_create(any())).thenAnswer((_) => TagionErrorCode.none.value);
      expect(() => hibon.init(), returnsNormally);

      when(() => hibonFfi.tagion_hibon_create(any())).thenAnswer((_) => TagionErrorCode.error.value);
      final Hibon hibonCreateFailure = Hibon(hibonFfi);
      try {
        hibonCreateFailure.init();
      } on HibonException catch (e) {
        expect(e.errorCode, TagionErrorCode.error);
        expect(e.message, HibonExceptionMessage.create);
      }
    });

    test('Add string to hibon', () {
      when(() => hibonFfi.tagion_hibon_add_string(any(), any(), any(), any(), any()))
          .thenAnswer((_) => TagionErrorCode.none.value);
      expect(() => hibon.addString('key', 'value'), returnsNormally);

      when(() => hibonFfi.tagion_hibon_add_string(any(), any(), any(), any(), any()))
          .thenAnswer((_) => TagionErrorCode.error.value);
      try {
        hibon.addString('key', 'value');
      } on HibonException catch (e) {
        expect(e.errorCode, TagionErrorCode.error);
        expect(e.message, HibonExceptionMessage.addString);
      }
    });

    test('Get hibon as string', () {
      String mockResponseString = 'mockResponseString';
      List<String> mockResponseStringArray = 'mockResponseString'.split('');

      when(() => hibonFfi.tagion_hibon_get_text(any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<ffi.Char>> charArrayPtr = invocation.positionalArguments[2];
        final Pointer<ffi.Uint64> charArrayLenPtr = invocation.positionalArguments[3];

        for (int i = 0; i < mockResponseStringArray.length; i++) {
          charArrayPtr[i] = mockResponseStringArray[i].toNativeUtf8().cast<ffi.Char>();
        }
        charArrayLenPtr.value = mockResponseStringArray.length;

        return TagionErrorCode.none.value;
      });

      expect(hibon.getAsString(), mockResponseString);

      when(() => hibonFfi.tagion_hibon_get_text(any(), any(), any(), any()))
          .thenAnswer((_) => TagionErrorCode.error.value);
      try {
        hibon.getAsString();
      } on HibonException catch (e) {
        expect(e.errorCode, TagionErrorCode.error);
        expect(e.message, HibonExceptionMessage.getAsString);
      }
    });

    test('Free hibon', () {
      when(() => hibonFfi.tagion_hibon_free(any())).thenAnswer((_) {});
      hibon.free();
      verify(() => hibonFfi.tagion_hibon_free(any())).called(1);
    });
  });
}
