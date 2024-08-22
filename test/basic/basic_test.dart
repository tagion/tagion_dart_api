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
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class MockBasicFfi extends Mock implements BasicFfi {}

class MockPointerManager extends Mock implements IPointerManager {}

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
      const String text = 'base64Url';
      final Pointer<Utf8> textUtf8Ptr = text.toNativeUtf8();
      final Pointer<Pointer<Char>> textPtr = malloc<Pointer<Char>>();
      final Pointer<Uint64> textLenPtr = malloc<Uint64>();
      final Uint8List textAsByteArray = Uint8List.fromList(text.codeUnits);
      final Pointer<Uint8> textAsByteArrayPointer = malloc<Uint8>(textAsByteArray.length);

      when(() => mockPointerManager.allocate<Uint8>(any())).thenReturn(textAsByteArrayPointer);
      when(() => mockPointerManager.uint8ListToPointer<Uint8>(any(), any())).thenReturn(null);
      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(textPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(textLenPtr);

      when(() => mockBasicFfi.tagion_basic_encode_base64url(any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Char>> textPtr = invocation.positionalArguments[2];
        final Pointer<Uint64> textLenPtr = invocation.positionalArguments[3];

        textPtr.value = textUtf8Ptr.cast<Char>();
        textLenPtr.value = textUtf8Ptr.length;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.freeAll(any())).thenReturn(null);

      // Act
      String result = basic.encodeBase64Url(textAsByteArray);

      // Assert
      expect(result, text);

      // Verify
      verify(() => mockPointerManager.freeAll(any())).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";

      when(() => mockBasicFfi.tagion_basic_encode_base64url(any(), any(), any(), any())).thenReturn(errorCode.value);
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      // Act & Assert
      expect(
        () => basic.encodeBase64Url(textAsByteArray),
        throwsA(isA<BasicApiException>()
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
      verify(() => mockPointerManager.freeAll(any())).called(1);
    });

    test('tagionRevision returns a string on success & throws on error', () {
      // Arrange
      const String text = 'revision';
      final Pointer<Utf8> textUtf8Ptr = text.toNativeUtf8();
      final Pointer<Pointer<Char>> textPtr = malloc<Pointer<Char>>();
      final Pointer<Uint64> textLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(textPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(textLenPtr);

      when(() => mockBasicFfi.tagion_revision(any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Char>> textPtr = invocation.positionalArguments[0];
        final Pointer<Uint64> textLenPtr = invocation.positionalArguments[1];

        textPtr.value = textUtf8Ptr.cast<Char>();
        textLenPtr.value = textUtf8Ptr.length;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.freeAll(any())).thenReturn(null);

      // Act
      String result = basic.tagionRevision();

      // Assert
      expect(result, text);

      // Verify
      verify(() => mockPointerManager.freeAll(any())).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";

      when(() => mockBasicFfi.tagion_revision(any(), any())).thenReturn(errorCode.value);
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      // Act & Assert
      expect(
        () => basic.tagionRevision(),
        throwsA(isA<BasicApiException>()
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
      verify(() => mockPointerManager.freeAll(any())).called(1);
    });
  });
}
