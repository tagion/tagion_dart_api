import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class MockCryptoFfi extends Mock implements CryptoFfi {}

class MockErrorMessage extends Mock implements IErrorMessage {}

class MockPointerManager extends Mock implements IPointerManager {}

void main() {
  late MockCryptoFfi mockCryptoFfi;
  late MockPointerManager mockPointerManager;
  late MockErrorMessage mockErrorMessage;
  const errorCode = TagionErrorCode.error;
  const errorMessage = "Error message";

  late Hibon hibon;

  setUp(() {
    registerFallbackValue('fallBackValue');
    registerFallbackValue(Pointer<Uint8>.fromAddress(0));
    registerFallbackValue(Pointer<Char>.fromAddress(0));
    registerFallbackValue(0);

    mockCryptoFfi = MockCryptoFfi();
    mockPointerManager = MockPointerManager();
    mockErrorMessage = MockErrorMessage();
  });

  group('HiRPC Unit.', () {
    test('createSignedRequest returns a value and throws TagionException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;
      const value = 'testValue';
      const valueLen = value.length;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      final Pointer<Char> valuePtr = malloc<Char>(valueLen);

      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);
      when(() => mockPointerManager.allocate<Char>(valueLen)).thenReturn(valuePtr);

      when(() => mockCryptoFfi.tagion_hibon_add_string(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addString(key, value), returnsNormally);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.allocate<Char>(valueLen)).called(1);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      verify(() => mockPointerManager.stringToPointer(valuePtr, value)).called(1);
      verify(() => mockCryptoFfi.tagion_hibon_add_string(any(), any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);
      verify(() => mockPointerManager.free(valuePtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockCryptoFfi.tagion_hibon_add_string(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addString(key, value),
        throwsA(isA<HibonException>()
            .having(
              (e) => e.errorCode,
              '',
              equals(errorCode),
            )
            .having(
              (e) => e.message,
              '',
              equals(errorMessage),
            )),
      );

      // Verify
      verify(() => mockPointerManager.free(keyPtr)).called(1);
      verify(() => mockPointerManager.free(valuePtr)).called(1);
    });
  });
}
