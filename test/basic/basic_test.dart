import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/basic/basic.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/enums/d_runtime_response.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/basic_exception.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';

class MockBasicFfi extends Mock implements BasicFfi {}

class MockPointerManager extends Mock implements PointerManager {}

class MockErrorMessage extends Mock implements IErrorMessage {}

void main() {
  setUpAll(() {
    registerFallbackValue(Pointer<Uint8>.fromAddress(0));
    registerFallbackValue(Uint8List.fromList([0]));
  });

  group('Basic Unit.', () {
    MockPointerManager mockPointerManager = MockPointerManager();

    final MockBasicFfi mockBasicFfi = MockBasicFfi();
    final MockErrorMessage mockErrorMessage = MockErrorMessage();
    final Basic basic = Basic(mockBasicFfi, mockPointerManager, mockErrorMessage);

    test('startDRuntime returns true on success & false on failure', () {
      when(() => mockBasicFfi.start_rt()).thenReturn(DRuntimeResponse.success.index);
      expect(basic.startDRuntime(), true);
      when(() => mockBasicFfi.start_rt()).thenReturn(DRuntimeResponse.failed.index);
      expect(basic.startDRuntime(), false);
    });

    test('stopDRuntime returns true on success & false on failure', () {
      when(() => mockBasicFfi.stop_rt()).thenReturn(DRuntimeResponse.success.index);
      expect(basic.stopDRuntime(), true);
      when(() => mockBasicFfi.stop_rt()).thenReturn(DRuntimeResponse.failed.index);
      expect(basic.stopDRuntime(), false);
    });

    test('encodeBase64Url returns a string on success and throws on error', () {
      // Arrange
      const String testString = 'base64Url';
      final Pointer<Pointer<Char>> testStringPtr = testString.toNativeUtf8().cast<Pointer<Char>>();
      final Pointer<Uint64> testStringLenPtr = malloc<Uint64>(testString.length);
      testStringLenPtr.value = testString.length;
      final Uint8List testStringAsByteArray = Uint8List.fromList(testString.codeUnits);
      final Pointer<Uint8> testStringAsByteArrayPointer = malloc<Uint8>(testStringAsByteArray.length);

      when(() => mockPointerManager.allocate<Uint8>(any())).thenReturn(testStringAsByteArrayPointer);
      when(() => mockPointerManager.uint8ListToPointer<Uint8>(any(), any())).thenReturn(null);
      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(testStringPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(testStringLenPtr);

      when(() => mockBasicFfi.tagion_basic_encode_base64url(any(), any(), any(), any())).thenAnswer((invocation) {
        (invocation.positionalArguments[0] as Pointer<Uint8>).value = testStringAsByteArrayPointer.value;
        (invocation.positionalArguments[2] as Pointer<Pointer<Char>>).value = testStringPtr.value;
        (invocation.positionalArguments[3] as Pointer<Uint64>).value = testStringLenPtr.value;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free<Uint8>(any())).thenReturn(null);
      when(() => mockPointerManager.free<Pointer<Char>>(any())).thenReturn(null);
      when(() => mockPointerManager.free<Uint64>(any())).thenReturn(null);
      when(() => mockPointerManager.pointerToString<Pointer<Char>>(any(), any())).thenReturn(testString);

      // Act
      String result = basic.encodeBase64Url(testStringAsByteArray);

      // Assert
      expect(result, testString);

      // Verify
      verify(() => mockPointerManager.free(testStringAsByteArrayPointer)).called(1);
      verify(() => mockPointerManager.free(testStringPtr)).called(1);
      verify(() => mockPointerManager.free(testStringLenPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";

      when(() => mockBasicFfi.tagion_basic_encode_base64url(any(), any(), any(), any())).thenReturn(errorCode.value);
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      // Act & Assert
      expect(
        () => basic.encodeBase64Url(testStringAsByteArray),
        throwsA(isA<BasicException>()
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
      verify(() => mockPointerManager.free(testStringAsByteArrayPointer)).called(1);
      verify(() => mockPointerManager.free(testStringPtr)).called(1);
      verify(() => mockPointerManager.free(testStringLenPtr)).called(1);
    });

    test('tagionRevision returns a string on success & throws on error', () {
      // Arrange
      const String testString = 'revision';
      final Pointer<Pointer<Char>> testStringPtr = testString.toNativeUtf8().cast<Pointer<Char>>();
      final Pointer<Uint64> testStringLenPtr = malloc<Uint64>(testString.length);
      testStringLenPtr.value = testString.length;

      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(testStringPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(testStringLenPtr);

      when(() => mockBasicFfi.tagion_revision(any(), any())).thenAnswer((invocation) {
        (invocation.positionalArguments[0] as Pointer<Pointer<Char>>).value = testStringPtr.value;
        (invocation.positionalArguments[1] as Pointer<Uint64>).value = testStringLenPtr.value;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free<Pointer<Char>>(any())).thenReturn(null);
      when(() => mockPointerManager.free<Uint64>(any())).thenReturn(null);
      when(() => mockPointerManager.pointerToString<Pointer<Char>>(any(), any())).thenReturn(testString);

      // Act
      String result = basic.tagionRevision();

      // Assert
      expect(result, testString);

      // Verify
      verify(() => mockPointerManager.free(testStringPtr)).called(1);
      verify(() => mockPointerManager.free(testStringLenPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";

      when(() => mockBasicFfi.tagion_revision(any(), any())).thenReturn(errorCode.value);
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      // Act & Assert
      expect(
        () => basic.tagionRevision(),
        throwsA(isA<BasicException>()
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
      verify(() => mockPointerManager.free(testStringPtr)).called(1);
      verify(() => mockPointerManager.free(testStringLenPtr)).called(1);
    });
  });
}
