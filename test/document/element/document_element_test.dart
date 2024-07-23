import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/document/element/document_element.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/document/document_exception.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class MockDocumentFfi extends Mock implements DocumentFfi {}

class MockPointerManager extends Mock implements IPointerManager {}

class MockErrorMessage extends Mock implements IErrorMessage {}

void main() {
  late MockDocumentFfi mockDocumentFfi;
  late MockPointerManager mockPointerManager;
  late MockErrorMessage mockErrorMessage;
  late DocumentElement documentElement;

  setUp(() {
    registerFallbackValue(Pointer<Pointer<Uint8>>.fromAddress(0));
    registerFallbackValue(Pointer<Char>.fromAddress(0));
    registerFallbackValue(Pointer<Element>.fromAddress(0));

    mockDocumentFfi = MockDocumentFfi();
    mockPointerManager = MockPointerManager();
    mockErrorMessage = MockErrorMessage();
    documentElement = DocumentElement(
      mockDocumentFfi,
      mockPointerManager,
      mockErrorMessage,
      nullptr,
    );
  });

  group('DocumentElement Unit', () {
    test('getBigInt returns the correct BigInt value and throws DocumentException when an error occurs', () {
      // Arrange
      final BigInt testValue = BigInt.parse('123456789012345678901234567890');

      final Pointer<Pointer<Uint8>> bigIntPtr = malloc<Pointer<Uint8>>();
      final Pointer<Uint64> bigIntLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(bigIntPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(bigIntLenPtr);

      when(() => mockDocumentFfi.tagion_document_get_bigint(any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Uint8>> bigIntPtr = invocation.positionalArguments[1];
        final Pointer<Uint64> bigIntLenPtr = invocation.positionalArguments[2];

        final testValueLen = (testValue.bitLength / 8).ceil();
        final pointerToUint8 = malloc<Uint8>(testValueLen);
        for (int i = 0; i < testValueLen; i++) {
          pointerToUint8[i] = (testValue >> (i * 8)).toUnsigned(8).toInt();
        }
        bigIntPtr.value = pointerToUint8;
        bigIntLenPtr.value = testValueLen;

        return TagionErrorCode.none.value;
      });
      when(() => mockPointerManager.free(bigIntPtr)).thenReturn(null);
      when(() => mockPointerManager.free(bigIntLenPtr)).thenReturn(null);

      // Act
      final result = documentElement.getBigInt();

      // Assert
      expect(result, isA<BigInt>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Pointer<Uint8>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_bigint(any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(bigIntPtr)).called(1);
      verify(() => mockPointerManager.free(bigIntLenPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_bigint(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getBigInt(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(bigIntPtr)).called(1);
      verify(() => mockPointerManager.free(bigIntLenPtr)).called(1);
    });

    test('getBinary returns the correct Uint8List value and throws DocumentException when an error occurs', () {
      // Arrange
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);

      final Pointer<Pointer<Uint8>> testDataPtr = malloc<Pointer<Uint8>>(testData.lengthInBytes);
      final Pointer<Uint64> testDataLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(testDataPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(testDataLenPtr);

      when(() => mockDocumentFfi.tagion_document_get_binary(any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Uint8>> testDataPtr = invocation.positionalArguments[1];
        final Pointer<Uint64> testDataLenPtr = invocation.positionalArguments[2];

        final dataLength = testData.length;
        final pointerToUint8 = malloc<Uint8>(dataLength);
        for (int i = 0; i < dataLength; i++) {
          pointerToUint8[i] = testData[i];
        }
        testDataPtr.value = pointerToUint8;
        testDataLenPtr.value = dataLength;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getBinary();

      // Assert
      expect(result, isA<Uint8List>());
      expect(result, equals(testData));

      // Verify
      verify(() => mockPointerManager.allocate<Pointer<Uint8>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_binary(any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(testDataPtr)).called(1);
      verify(() => mockPointerManager.free(testDataLenPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_binary(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getBinary(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(testDataPtr)).called(1);
      verify(() => mockPointerManager.free(testDataLenPtr)).called(1);
    });

    test('getBool returns the correct bool value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = true;
      final boolPtr = malloc<Bool>();

      when(() => mockPointerManager.allocate<Bool>()).thenReturn(boolPtr);
      when(() => mockDocumentFfi.tagion_document_get_bool(any(), any())).thenAnswer((invocation) {
        final Pointer<Bool> boolPtr = invocation.positionalArguments[1];

        boolPtr.value = testValue;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getBool();

      // Assert
      expect(result, isA<bool>());
      expect(result, isTrue);

      // Verify
      verify(() => mockPointerManager.allocate<Bool>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_bool(any(), any())).called(1);
      verify(() => mockPointerManager.free(boolPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_bool(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getBool(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(boolPtr)).called(1);
    });

    test('getFloat32 returns the correct double value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = 123.456;
      final floatPtr = malloc<Float>();
      when(() => mockPointerManager.allocate<Float>()).thenReturn(floatPtr);
      when(() => mockDocumentFfi.tagion_document_get_float32(any(), any())).thenAnswer((invocation) {
        final Pointer<Float> floatPtr = invocation.positionalArguments[1];

        floatPtr.value = testValue;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getFloat32();

      // Assert
      expect(result, isA<double>());

      /// There is a discrepancy that might occur due to the precision limitations of Float (single-precision floating-point) in dart:ffi.
      /// Example: a stored value 3.14 in a Float, gets converted to the nearest representable value in single-precision, which is 3.140000104904175.
      /// In order to  fix this issue, we use a tolerance when comparing floating-point numbers.
      /// This is a common practice in tests involving floating-point arithmetic to account for precision errors.

      // Use a relative tolerance for comparison
      const relativeTolerance = 0.000001;
      const tolerance = relativeTolerance * testValue;
      expect(floatPtr.value, closeTo(testValue, tolerance));

      // Verify
      verify(() => mockPointerManager.allocate<Float>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_float32(any(), any())).called(1);
      verify(() => mockPointerManager.free(floatPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_float32(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getFloat32(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(floatPtr)).called(1);
    });

    test('getFloat64 returns the correct double value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = 123.456;
      final doublePtr = malloc<Double>();
      when(() => mockPointerManager.allocate<Double>()).thenReturn(doublePtr);
      when(() => mockDocumentFfi.tagion_document_get_float64(any(), any())).thenAnswer((invocation) {
        final Pointer<Double> doublePtr = invocation.positionalArguments[1];

        doublePtr.value = testValue;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getFloat64();

      // Assert
      expect(result, isA<double>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Double>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_float64(any(), any())).called(1);
      verify(() => mockPointerManager.free(doublePtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_float64(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getFloat64(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(doublePtr)).called(1);
    });

    test('getInt32 returns the correct int value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = 123;
      final intPtr = malloc<Int32>();
      when(() => mockPointerManager.allocate<Int32>()).thenReturn(intPtr);
      when(() => mockDocumentFfi.tagion_document_get_int32(any(), any())).thenAnswer((invocation) {
        final Pointer<Int32> intPtr = invocation.positionalArguments[1];

        intPtr.value = testValue;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getInt32();

      // Assert
      expect(result, isA<int>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Int32>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_int32(any(), any())).called(1);
      verify(() => mockPointerManager.free(intPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_int32(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getInt32(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(intPtr)).called(1);
    });

    test('getInt64 returns the correct int value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = 123;
      final intPtr = malloc<Int64>();
      when(() => mockPointerManager.allocate<Int64>()).thenReturn(intPtr);
      when(() => mockDocumentFfi.tagion_document_get_int64(any(), any())).thenAnswer((invocation) {
        final Pointer<Int64> intPtr = invocation.positionalArguments[1];

        intPtr.value = testValue;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getInt64();

      // Assert
      expect(result, isA<int>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Int64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_int64(any(), any())).called(1);
      verify(() => mockPointerManager.free(intPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_int64(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getInt64(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(intPtr)).called(1);
    });

    test('getUint32 returns the correct int value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = 123;
      final intPtr = malloc<Uint32>();
      when(() => mockPointerManager.allocate<Uint32>()).thenReturn(intPtr);
      when(() => mockDocumentFfi.tagion_document_get_uint32(any(), any())).thenAnswer((invocation) {
        final Pointer<Uint32> intPtr = invocation.positionalArguments[1];

        intPtr.value = testValue;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getUint32();

      // Assert
      expect(result, isA<int>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Uint32>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_uint32(any(), any())).called(1);
      verify(() => mockPointerManager.free(intPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_uint32(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getUint32(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(intPtr)).called(1);
    });

    test('getUint64 returns the correct int value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = 123;
      final intPtr = malloc<Uint64>();
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(intPtr);
      when(() => mockDocumentFfi.tagion_document_get_uint64(any(), any())).thenAnswer((invocation) {
        final Pointer<Uint64> intPtr = invocation.positionalArguments[1];

        intPtr.value = testValue;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getUint64();

      // Assert
      expect(result, isA<int>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_uint64(any(), any())).called(1);
      verify(() => mockPointerManager.free(intPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_uint64(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getUint64(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(intPtr)).called(1);
    });

    test('getString returns the correct string value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = "Test string";
      final Pointer<Pointer<Char>> stringPtr = malloc<Pointer<Char>>();
      final stringLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(stringPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(stringLenPtr);

      when(() => mockDocumentFfi.tagion_document_get_string(any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Char>> stringPtr = invocation.positionalArguments[1];
        final Pointer<Uint64> stringLenPtr = invocation.positionalArguments[2];

        final pointerToChar = testValue.toNativeUtf8();
        stringPtr.value = pointerToChar.cast();
        stringLenPtr.value = testValue.length;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getString();

      // Assert
      expect(result, isA<String>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Pointer<Char>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_string(any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(stringPtr)).called(1);
      verify(() => mockPointerManager.free(stringLenPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_string(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getString(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(stringPtr)).called(1);
      verify(() => mockPointerManager.free(stringLenPtr)).called(1);
    });

    test('getSubDocument returns the correct Uint8List value and throws DocumentException when an error occurs', () {
      // Arrange
      final testValue = Uint8List.fromList([1, 2, 3, 4, 5, 6]);
      final subDocumentPtr = malloc<Pointer<Uint8>>();
      final subDocumentLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(subDocumentPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(subDocumentLenPtr);
      when(() => mockDocumentFfi.tagion_document_get_document(any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Uint8>> subDocumentPtr = invocation.positionalArguments[1];
        final Pointer<Uint64> subDocumentLenPtr = invocation.positionalArguments[2];

        final dataLength = testValue.length;
        final pointerToUint8 = malloc<Uint8>(dataLength);
        for (int i = 0; i < dataLength; i++) {
          pointerToUint8[i] = testValue[i];
        }
        subDocumentPtr.value = pointerToUint8;
        subDocumentLenPtr.value = dataLength;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getSubDocument();

      // Assert
      expect(result, isA<Uint8List>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Pointer<Uint8>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_document(any(), any(), any())).called(1);
      verify(() => mockPointerManager.free(subDocumentPtr)).called(1);
      verify(() => mockPointerManager.free(subDocumentLenPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_document(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getSubDocument(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(subDocumentPtr)).called(1);
      verify(() => mockPointerManager.free(subDocumentLenPtr)).called(1);
    });

    test('getTime returns the correct int value and throws DocumentException when an error occurs', () {
      // Arrange
      const testValue = 9223372036854775807;
      final timePtr = malloc<Int64>();
      when(() => mockPointerManager.allocate<Int64>()).thenReturn(timePtr);
      when(() => mockDocumentFfi.tagion_document_get_time(any(), any())).thenAnswer((invocation) {
        final Pointer<LongLong> timePtr = invocation.positionalArguments[1];

        timePtr.value = testValue;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = documentElement.getTime();

      // Assert
      expect(result, isA<int>());
      expect(result, equals(testValue));

      // Verify
      verify(() => mockPointerManager.allocate<Int64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_time(any(), any())).called(1);
      verify(() => mockPointerManager.free(timePtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_time(any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => documentElement.getTime(),
        throwsA(isA<DocumentException>()
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
      verify(() => mockPointerManager.free(timePtr)).called(1);
    });
  });
}
