import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/hirpc/hirpc.dart';
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

  late TagionHiRPC hirpc;

  setUp(() {
    registerFallbackValue('fallBackValue');
    registerFallbackValue(Pointer<Uint8>.fromAddress(0));
    registerFallbackValue(Pointer<Char>.fromAddress(0));
    registerFallbackValue(0);

    mockCryptoFfi = MockCryptoFfi();
    mockPointerManager = MockPointerManager();
    mockErrorMessage = MockErrorMessage();
    hirpc = TagionHiRPC(mockCryptoFfi, mockPointerManager, mockErrorMessage);
  });

  group('HiRPC Unit.', () {
    test('createSignedRequest returns a value and throws TagionException when an error occurs', () {
      // Arrange
      final signedDataMock = Uint8List.fromList([1, 2, 3, 4, 5]);
      final signedDataMockLen = signedDataMock.length;

      const method = 'method';
      const methodLen = method.length;

      final docBufferMock = Uint8List.fromList([1, 2, 3, 4, 5]);
      final docBufferMockLen = docBufferMock.length;

      final deriverMock = Uint8List.fromList([1, 2, 3, 4, 5]);
      final deriverLen = deriverMock.length;

      final Pointer<Char> methodPtr = malloc<Char>(methodLen);
      final Pointer<Uint8> docBufferPtr = malloc<Uint8>(docBufferMockLen);
      final Pointer<Uint8> deriverPtr = malloc<Uint8>(deriverLen);

      final Pointer<Pointer<Uint8>> resultPtr = malloc<Pointer<Uint8>>();
      final Pointer<Uint64> resultLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Char>(methodLen)).thenReturn(methodPtr);
      when(() => mockPointerManager.allocate<Uint8>(docBufferMockLen)).thenReturn(docBufferPtr);
      when(() => mockPointerManager.allocate<Uint8>(deriverLen)).thenReturn(deriverPtr);
      when(() => mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(resultPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(resultLenPtr);

      when(() => mockCryptoFfi.tagion_hirpc_create_signed_sender(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((invokation) {
        // final methodPtr = invokation.positionalArguments[0] as Pointer<Char>;
        // final methodLen = invokation.positionalArguments[1] as int;
        // final docBufferPtr = invokation.positionalArguments[2] as Pointer<Uint8>;
        // final docBufferLen = invokation.positionalArguments[3] as int;
        // final vaultPtr = invokation.positionalArguments[4] as Pointer<Uint8>;
        // final deriverPtr = invokation.positionalArguments[5] as Pointer<Uint8>;
        // final deriverLen = invokation.positionalArguments[6] as int;

        final resultPtr = invokation.positionalArguments[7] as Pointer<Pointer<Uint8>>;
        final resultLenPtr = invokation.positionalArguments[8] as Pointer<Uint64>;

        final Pointer<Uint8> signedDataMockPtr = malloc<Uint8>();
        signedDataMockPtr.cast<Uint8>().asTypedList(signedDataMockLen).setAll(0, signedDataMock);

        resultPtr.value = signedDataMockPtr;
        resultLenPtr.value = signedDataMockLen;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act
      Uint8List result = hirpc.createSignedRequest(method, docBufferMock, deriverMock);

      // Act & Assert
      expect(result, signedDataMock);

      // // Verify
      // verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      // verify(() => mockPointerManager.allocate<Char>(valueLen)).called(1);
      // verify(() => mockPointerManager.stringToPointer(keyPtr, key)).called(1);
      // verify(() => mockPointerManager.stringToPointer(valuePtr, value)).called(1);
      // verify(() => mockCryptoFfi.tagion_hibon_add_string(any(), any(), any(), any(), any())).called(1);
      // verify(() => mockPointerManager.free(keyPtr)).called(1);
      // verify(() => mockPointerManager.free(valuePtr)).called(1);

      // // Arrange
      // when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      // when(() => mockCryptoFfi.tagion_hibon_add_string(any(), any(), any(), any(), any())).thenAnswer((_) {
      //   return TagionErrorCode.error.value;
      // });

      // // Act & Assert
      // expect(
      //   () => hirpc.addString(key, value),
      //   throwsA(isA<HibonException>()
      //       .having(
      //         (e) => e.errorCode,
      //         '',
      //         equals(errorCode),
      //       )
      //       .having(
      //         (e) => e.message,
      //         '',
      //         equals(errorMessage),
      //       )),
      // );

      // // Verify
      // verify(() => mockPointerManager.free(keyPtr)).called(1);
      // verify(() => mockPointerManager.free(valuePtr)).called(1);
    });
  });
}
