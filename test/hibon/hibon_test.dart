import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon/hibon_exception.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class MockHibonFfi extends Mock implements HibonFfi {}

class MockErrorMessage extends Mock implements IErrorMessage {}

class MockPointerManager extends Mock implements IPointerManager {}

void main() {
  registerFallbackValue(malloc<HiBONT>());
  registerFallbackValue(Pointer<Char>.fromAddress(0));

  group('Hibon Unit.', () {
    final MockHibonFfi mockHibonFfi = MockHibonFfi();
    final MockErrorMessage mockErrorMessage = MockErrorMessage();
    final MockPointerManager mockPointerManager = MockPointerManager();
    const String mockErrorText = 'mockErrorText';

    final Hibon hibon = Hibon(mockHibonFfi, mockErrorMessage, mockPointerManager);

    test('Create hibon', () {
      when(() => mockHibonFfi.tagion_hibon_create(any())).thenAnswer((_) => TagionErrorCode.none.value);
      expect(() => hibon.init(), returnsNormally);

      when(() => mockHibonFfi.tagion_hibon_create(any())).thenAnswer((_) => TagionErrorCode.error.value);
      when(() => mockErrorMessage.getErrorText()).thenAnswer((_) => mockErrorText);
      final Hibon hibonFailedInit = Hibon(mockHibonFfi, mockErrorMessage, mockPointerManager);
      try {
        hibonFailedInit.init();
      } on HibonException catch (e) {
        expect(e.errorCode, TagionErrorCode.error);
      }
    });

    test('Add string to hibon', () {
      when(() => mockPointerManager.allocate<Char>(any())).thenReturn(malloc<Char>());
      when(() => mockHibonFfi.tagion_hibon_add_string(any(), any(), any(), any(), any()))
          .thenAnswer((_) => TagionErrorCode.none.value);
      when(() => mockPointerManager.free<Char>(any())).thenAnswer((_) {});
      expect(() => hibon.addString('key', 'value'), returnsNormally);
      verify(() => mockPointerManager.free<Char>(any())).called(2);

      when(() => mockHibonFfi.tagion_hibon_add_string(any(), any(), any(), any(), any()))
          .thenAnswer((_) => TagionErrorCode.error.value);
      when(() => mockErrorMessage.getErrorText()).thenAnswer((_) => mockErrorText);
      try {
        hibon.addString('key', 'value');
      } on HibonException catch (e) {
        expect(e.errorCode, TagionErrorCode.error);
      }
      verify(() => mockPointerManager.free<Char>(any())).called(2);
    });

    test('Get hibon as string', () {
      String mockResponseString = 'mockResponseString';
      final Pointer<Utf8> mockResponseUtf8Pointer = mockResponseString.toNativeUtf8();

      when(() => mockPointerManager.allocate<Pointer<Char>>(any())).thenReturn(malloc<Pointer<Char>>());
      when(() => mockPointerManager.allocate<Uint64>(any())).thenReturn(malloc<Uint64>());

      when(() => mockHibonFfi.tagion_hibon_get_text(any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Char>> charArrayPtr = invocation.positionalArguments[2];
        final Pointer<Uint64> charArrayLenPtr = invocation.positionalArguments[3];

        charArrayPtr.value = mockResponseUtf8Pointer.cast<Char>();
        charArrayLenPtr.value = mockResponseString.length;

        return TagionErrorCode.none.value;
      });
      when(() => mockPointerManager.free<Char>(any())).thenAnswer((_) {});
      when(() => mockPointerManager.free<Uint64>(any())).thenAnswer((_) {});
      expect(hibon.getAsString(), mockResponseString);
      verify(() => mockPointerManager.free<Pointer<Char>>(any())).called(1);
      verify(() => mockPointerManager.free<Uint64>(any())).called(1);

      when(() => mockHibonFfi.tagion_hibon_get_text(any(), any(), any(), any()))
          .thenAnswer((_) => TagionErrorCode.error.value);
      when(() => mockErrorMessage.getErrorText()).thenAnswer((_) => mockErrorText);
      try {
        hibon.getAsString();
      } on HibonException catch (e) {
        expect(e.errorCode, TagionErrorCode.error);
      }
      verify(() => mockPointerManager.free<Pointer<Char>>(any())).called(1);
      verify(() => mockPointerManager.free<Uint64>(any())).called(1);
    });

    test('Free hibon', () {
      when(() => mockHibonFfi.tagion_hibon_free(any())).thenAnswer((_) {});
      hibon.free();
      verify(() => mockHibonFfi.tagion_hibon_free(any())).called(1);
    });
  });
}
