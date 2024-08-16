import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/hibon/hibon_interface.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class MockHibonFfi extends Mock implements HibonFfi {}

class MockErrorMessage extends Mock implements IErrorMessage {}

class MockPointerManager extends Mock implements IPointerManager {}

class MockHibon extends Mock implements IHibon {}

void main() {
  late MockHibonFfi mockHibonFfi;
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

    mockHibonFfi = MockHibonFfi();
    mockPointerManager = MockPointerManager();
    mockErrorMessage = MockErrorMessage();

    final Pointer<HiBONT> hibonPtr = malloc<HiBONT>();
    when(() => mockPointerManager.allocate<HiBONT>()).thenReturn(hibonPtr);
    hibon = Hibon(mockHibonFfi, mockErrorMessage, mockPointerManager);
  });

  group('Hibon Unit.', () {
    test('create creates Hibon and throws HibonException when an error occurs', () {
      // Arrange
      when(() => mockHibonFfi.tagion_hibon_create(any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      // Act & Assert
      expect(() => hibon.create(), returnsNormally);

      // Verify
      verify(() => mockPointerManager.allocate<HiBONT>()).called(1);
      verify(() => mockHibonFfi.tagion_hibon_create(any())).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);
      when(() => mockHibonFfi.tagion_hibon_create(any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.create(),
        throwsA(isA<HibonApiException>()
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
    });

    /// dispose test.

    test('dispose calls tagion_hibon_free', () {
      // Arrange
      when(() => mockHibonFfi.tagion_hibon_free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.dispose(), returnsNormally);

      // Verify
      verify(() => mockHibonFfi.tagion_hibon_free(any())).called(1);
    });

    test('addString adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;
      const value = 'testValue';
      const valueLen = value.length;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      final Pointer<Char> valuePtr = malloc<Char>(valueLen);

      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);
      when(() => mockPointerManager.allocate<Char>(valueLen)).thenReturn(valuePtr);

      when(() => mockHibonFfi.tagion_hibon_add_string(any(), any(), any(), any(), any())).thenAnswer((_) {
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
      verify(() => mockHibonFfi.tagion_hibon_add_string(any(), any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);
      verify(() => mockPointerManager.free(valuePtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_string(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addString(key, value),
        throwsA(isA<HibonApiException>()
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

    test('getAsString returns the correct value and throws HibonException when an error occurs', () {
      // Arrange
      const testValue = 'test hibon value as string';
      const testValueLen = testValue.length;

      final Pointer<Pointer<Char>> charArrayPtr = malloc<Pointer<Char>>();
      final Pointer<Uint64> charArrayLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(charArrayPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(charArrayLenPtr);

      when(() => mockHibonFfi.tagion_hibon_get_text(any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Char>> charArrayPtr = invocation.positionalArguments[2];
        final Pointer<Uint64> charArrayLenPtr = invocation.positionalArguments[3];

        final Pointer<Char> valuePtr = malloc<Char>(testValueLen);
        valuePtr.cast<Uint8>().asTypedList(testValueLen).setAll(0, testValue.codeUnits);

        charArrayPtr.value = valuePtr;
        charArrayLenPtr.value = testValueLen;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(hibon.getAsString(), equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Pointer<Char>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);

      verify(() => mockHibonFfi.tagion_hibon_get_text(any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(charArrayPtr)).called(1);
      verify(() => mockPointerManager.free(charArrayLenPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_get_text(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.getAsString(),
        throwsA(isA<HibonApiException>()
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
      verify(() => mockPointerManager.free(charArrayPtr)).called(1);
      verify(() => mockPointerManager.free(charArrayLenPtr)).called(1);
    });

    test('addInt adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;
      const value = 123;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);

      when(() => mockHibonFfi.tagion_hibon_add_int32(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });
      when(() => mockHibonFfi.tagion_hibon_add_int64(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });
      when(() => mockHibonFfi.tagion_hibon_add_uint32(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });
      when(() => mockHibonFfi.tagion_hibon_add_uint64(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addInt<Int32>(key, value), returnsNormally);
      verify(() => mockHibonFfi.tagion_hibon_add_int32(any(), any(), any(), any())).called(1);
      expect(() => hibon.addInt<Int64>(key, value), returnsNormally);
      verify(() => mockHibonFfi.tagion_hibon_add_int64(any(), any(), any(), any())).called(1);
      expect(() => hibon.addInt<Uint32>(key, value), returnsNormally);
      verify(() => mockHibonFfi.tagion_hibon_add_uint32(any(), any(), any(), any())).called(1);
      expect(() => hibon.addInt<Uint64>(key, value), returnsNormally);
      verify(() => mockHibonFfi.tagion_hibon_add_uint64(any(), any(), any(), any())).called(1);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(4);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(4);
      verify(() => mockPointerManager.free(keyPtr)).called(4);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_int32(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });
      when(() => mockHibonFfi.tagion_hibon_add_int64(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });
      when(() => mockHibonFfi.tagion_hibon_add_uint32(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });
      when(() => mockHibonFfi.tagion_hibon_add_uint64(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addInt<Int32>(key, value),
        throwsA(isA<HibonApiException>()
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

      expect(
        () => hibon.addInt<Int64>(key, value),
        throwsA(isA<HibonApiException>()
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

      expect(
        () => hibon.addInt<Uint32>(key, value),
        throwsA(isA<HibonApiException>()
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

      expect(
        () => hibon.addInt<Uint64>(key, value),
        throwsA(isA<HibonApiException>()
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
      verify(() => mockPointerManager.free(keyPtr)).called(4);
    });

    test('addBool adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;
      const value = true;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);

      when(() => mockHibonFfi.tagion_hibon_add_bool(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addBool(key, value), returnsNormally);
      verify(() => mockHibonFfi.tagion_hibon_add_bool(any(), any(), any(), any())).called(1);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_bool(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addBool(key, value),
        throwsA(isA<HibonApiException>()
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
    });

    test('getAsDocumentBuffer returns the correct value and throws HibonException when an error occurs', () {
      // Arrange
      final value = Uint8List.fromList([1, 2, 3, 4, 5]);
      final valueLen = value.length;

      final Pointer<Pointer<Uint8>> keyPtr = malloc<Pointer<Uint8>>();
      final Pointer<Uint64> valuePtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(keyPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(valuePtr);

      when(() => mockHibonFfi.tagion_hibon_get_document(any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Uint8>> valuePtrPtr = invocation.positionalArguments[1];
        final Pointer<Uint64> valueLenPtr = invocation.positionalArguments[2];

        final Pointer<Uint8> valuePtr = malloc<Uint8>();
        valuePtr.cast<Uint8>().asTypedList(valueLen).setAll(0, value);

        valuePtrPtr.value = valuePtr;
        valueLenPtr.value = valueLen;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(hibon.getAsDocumentBuffer(), equals(value));

      // Verify
      verify(() => mockPointerManager.allocate<Pointer<Uint8>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockHibonFfi.tagion_hibon_get_document(any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);
      verify(() => mockPointerManager.free(valuePtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_get_document(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.getAsDocumentBuffer(),
        throwsA(isA<HibonApiException>()
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

    test('addDocumentBufferByKey adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;
      final value = Uint8List.fromList([1, 2, 3, 4, 5]);
      final valueLen = value.length;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      final Pointer<Uint8> valuePtr = malloc<Uint8>(valueLen);

      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);
      when(() => mockPointerManager.allocate<Uint8>(valueLen)).thenReturn(valuePtr);

      when(() => mockHibonFfi.tagion_hibon_add_document(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addDocumentBufferByKey(key, value), returnsNormally);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.allocate<Uint8>(valueLen)).called(1);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      verify(() => mockPointerManager.uint8ListToPointer(valuePtr, value)).called(1);
      verify(() => mockHibonFfi.tagion_hibon_add_document(any(), any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);
      verify(() => mockPointerManager.free(valuePtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_document(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addDocumentBufferByKey(key, value),
        throwsA(isA<HibonApiException>()
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

    test('addDocumentBufferByIndex adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const index = 1;
      final value = Uint8List.fromList([1, 2, 3, 4, 5]);
      final valueLen = value.length;

      final Pointer<Uint8> valuePtr = malloc<Uint8>(valueLen);

      when(() => mockPointerManager.allocate<Uint8>(valueLen)).thenReturn(valuePtr);

      when(() => mockHibonFfi.tagion_hibon_add_index_document(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addDocumentBufferByIndex(index, value), returnsNormally);

      // Verify
      verify(() => mockPointerManager.allocate<Uint8>(valueLen)).called(1);
      verify(() => mockPointerManager.uint8ListToPointer(valuePtr, value)).called(1);
      verify(() => mockHibonFfi.tagion_hibon_add_index_document(any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(valuePtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_index_document(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addDocumentBufferByIndex(index, value),
        throwsA(isA<HibonApiException>()
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
      verify(() => mockPointerManager.free(valuePtr)).called(1);
    });

    test('addHibonByKey adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      final Pointer<HiBONT> nHibonPtr = malloc<HiBONT>();

      final nHibon = MockHibon();

      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);
      when(() => nHibon.pointer).thenReturn(nHibonPtr);

      when(() => mockHibonFfi.tagion_hibon_add_hibon(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addHibonByKey(key, nHibon), returnsNormally);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      verify(() => mockHibonFfi.tagion_hibon_add_hibon(any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_hibon(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addHibonByKey(key, nHibon),
        throwsA(isA<HibonApiException>()
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
    });

    test('addHibonByIndex adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const index = 1;

      final Pointer<HiBONT> nHibonPtr = malloc<HiBONT>();

      final nHibon = MockHibon();

      when(() => nHibon.pointer).thenReturn(nHibonPtr);

      when(() => mockHibonFfi.tagion_hibon_add_index_hibon(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      // Act & Assert
      expect(() => hibon.addHibonByIndex(index, nHibon), returnsNormally);

      // Verify
      verify(() => mockHibonFfi.tagion_hibon_add_index_hibon(any(), any(), any())).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_index_hibon(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addHibonByIndex(index, nHibon),
        throwsA(isA<HibonApiException>()
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
    });

    test('addFloat adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;
      const value = 123.456;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);

      when(() => mockHibonFfi.tagion_hibon_add_float32(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });
      when(() => mockHibonFfi.tagion_hibon_add_float64(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addFloat<Float>(key, value), returnsNormally);
      verify(() => mockHibonFfi.tagion_hibon_add_float32(any(), any(), any(), any())).called(1);
      expect(() => hibon.addFloat<Double>(key, value), returnsNormally);
      verify(() => mockHibonFfi.tagion_hibon_add_float64(any(), any(), any(), any())).called(1);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(2);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(2);
      verify(() => mockPointerManager.free(keyPtr)).called(2);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_float32(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });
      when(() => mockHibonFfi.tagion_hibon_add_float64(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addFloat<Float>(key, value),
        throwsA(isA<HibonApiException>()
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

      expect(
        () => hibon.addFloat<Double>(key, value),
        throwsA(isA<HibonApiException>()
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
      verify(() => mockPointerManager.free(keyPtr)).called(2);
    });

    test('addArrayByKey adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;

      final array = Uint8List.fromList([1, 2, 3, 4, 5]);
      final arrayLen = array.length;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      final Pointer<Uint8> arrayPtr = malloc<Uint8>(arrayLen);

      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);
      when(() => mockPointerManager.allocate<Uint8>(arrayLen)).thenReturn(arrayPtr);

      when(() => mockHibonFfi.tagion_hibon_add_binary(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addArrayByKey(key, array), returnsNormally);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.allocate<Uint8>(arrayLen)).called(1);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      verify(() => mockPointerManager.uint8ListToPointer(arrayPtr, array)).called(1);
      verify(() => mockHibonFfi.tagion_hibon_add_binary(any(), any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);
      verify(() => mockPointerManager.free(arrayPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_binary(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addArrayByKey(key, array),
        throwsA(isA<HibonApiException>()
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
      verify(() => mockPointerManager.free(arrayPtr)).called(1);
    });

    test('addArrayByIndex adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const index = 1;

      final array = Uint8List.fromList([1, 2, 3, 4, 5]);
      final arrayLen = array.length;

      final Pointer<Uint8> arrayPtr = malloc<Uint8>(arrayLen);

      when(() => mockPointerManager.allocate<Uint8>(arrayLen)).thenReturn(arrayPtr);

      when(() => mockHibonFfi.tagion_hibon_add_index_binary(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addArrayByIndex(index, array), returnsNormally);

      // Verify
      verify(() => mockPointerManager.allocate<Uint8>(arrayLen)).called(1);
      verify(() => mockPointerManager.uint8ListToPointer(arrayPtr, array)).called(1);
      verify(() => mockHibonFfi.tagion_hibon_add_index_binary(any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(arrayPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_index_binary(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addArrayByIndex(index, array),
        throwsA(isA<HibonApiException>()
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
      verify(() => mockPointerManager.free(arrayPtr)).called(1);
    });

    test('addTime adds a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;
      final value = DateTime.now().millisecondsSinceEpoch;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);

      when(() => mockHibonFfi.tagion_hibon_add_time(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.addTime(key, value), returnsNormally);
      verify(() => mockHibonFfi.tagion_hibon_add_time(any(), any(), any(), any())).called(1);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_add_time(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.addTime(key, value),
        throwsA(isA<HibonApiException>()
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
    });

    test('hasMemberByKey returns the correct value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;

      const hasMember = true;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      final Pointer<Bool> resultPtr = malloc<Bool>();

      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);
      when(() => mockPointerManager.allocate<Bool>()).thenReturn(resultPtr);

      when(() => mockHibonFfi.tagion_hibon_has_member(any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Bool> resultPtr = invocation.positionalArguments[3];

        resultPtr.value = hasMember;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(hibon.hasMemberByKey(key), isTrue);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      verify(() => mockHibonFfi.tagion_hibon_has_member(any(), any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_has_member(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.hasMemberByKey(key),
        throwsA(isA<HibonApiException>()
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
    });

    test('hasMemberByIndex returns the correct value and throws HibonException when an error occurs', () {
      // Arrange
      const index = 1;

      const hasMember = true;

      final Pointer<Bool> resultPtr = malloc<Bool>();

      when(() => mockPointerManager.allocate<Bool>()).thenReturn(resultPtr);

      when(() => mockHibonFfi.tagion_hibon_has_member_index(any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Bool> resultPtr = invocation.positionalArguments[2];

        resultPtr.value = hasMember;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(hibon.hasMemberByIndex(index), isTrue);

      // Verify
      verify(() => mockPointerManager.allocate<Bool>()).called(1);
      verify(() => mockHibonFfi.tagion_hibon_has_member_index(any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(resultPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_has_member_index(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.hasMemberByIndex(index),
        throwsA(isA<HibonApiException>()
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
      verify(() => mockPointerManager.free(resultPtr)).called(1);
    });

    test('removeByKey removes a value and throws HibonException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);

      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);

      when(() => mockHibonFfi.tagion_hibon_remove_by_key(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => hibon.removeByKey(key), returnsNormally);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      verify(() => mockHibonFfi.tagion_hibon_remove_by_key(any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_remove_by_key(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.removeByKey(key),
        throwsA(isA<HibonApiException>()
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
    });

    test('removeByIndex removes a value and throws HibonException when an error occurs', () {
      // Arrange
      const index = 1;

      when(() => mockHibonFfi.tagion_hibon_remove_by_index(any(), any())).thenAnswer((_) {
        return TagionErrorCode.none.value;
      });

      // Act & Assert
      expect(() => hibon.removeByIndex(index), returnsNormally);

      // Verify
      verify(() => mockHibonFfi.tagion_hibon_remove_by_index(any(), any())).called(1);

      // Arrange
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockHibonFfi.tagion_hibon_remove_by_index(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => hibon.removeByIndex(index),
        throwsA(isA<HibonApiException>()
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
    });
  });
}
