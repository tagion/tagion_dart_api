import 'dart:ffi';

import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/crypto/crypto.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/keypair_details.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:test/test.dart';

// Mock classes
class MockCryptoFfi extends Mock implements CryptoFfi {}

class MockPointerManager extends Mock implements PointerManager {}

class MockErrorMessage extends Mock implements ErrorMessage {}

void main() {
  group('Crypto', () {
    late MockCryptoFfi mockCryptoFfi;
    late MockPointerManager mockPointerManager;
    late MockErrorMessage mockErrorMessage;
    late Crypto crypto;

    setUp(() {
      registerFallbackValue('fallBackValue');
      registerFallbackValue(Pointer<Uint8>.fromAddress(0));
      registerFallbackValue(Pointer<Uint64>.fromAddress(0));
      registerFallbackValue(Pointer<Char>.fromAddress(0));
      registerFallbackValue(Pointer<SecureNet>.fromAddress(0));
      registerFallbackValue(0);
      mockCryptoFfi = MockCryptoFfi();
      mockPointerManager = MockPointerManager();
      mockErrorMessage = MockErrorMessage();
      crypto = Crypto(mockCryptoFfi, mockPointerManager, mockErrorMessage);
    });

    test('generateKeypair returns KeypairDetails on success', () {
      // Arrange
      const passphrase = 'passphrase';
      const pinCode = 'pinCode';
      const salt = 'salt';

      final passphrasePtr = Pointer<Char>.fromAddress(1);
      final pinCodePtr = Pointer<Char>.fromAddress(2);
      final saltPtr = Pointer<Char>.fromAddress(3);
      final securenetPtr = Pointer<SecureNet>.fromAddress(4);
      final devicePinPtr = Pointer<Pointer<Uint8>>.fromAddress(5);
      final devicePinLenPtr = Pointer<Uint64>.fromAddress(6);

      when(() => mockPointerManager.allocate<Char>(any())).thenReturn(passphrasePtr);
      when(() => mockPointerManager.allocate<Char>(any())).thenReturn(pinCodePtr);
      when(() => mockPointerManager.allocate<Char>(any())).thenReturn(saltPtr);
      when(() => mockPointerManager.allocate<SecureNet>()).thenReturn(securenetPtr);
      when(() => mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(devicePinPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(devicePinLenPtr);
      when(() => mockCryptoFfi.tagion_generate_keypair(any(), any(), any(), any(), any(), any(), any(), any(), any()))
          .thenReturn(TagionErrorCode.none.value);

      // final secureNet = SecureNet();
      // final devicePin = Uint8List.fromList([1, 2, 3, 4]);
      // when(securenetPtr.ref).thenReturn(secureNet);
      // when(devicePinPtr.value.asTypedList(any)).thenReturn(devicePin);

      // Act
      final result = crypto.generateKeypair(passphrase, pinCode, salt);

      // Assert
      expect(result, isA<KeypairDetails>());
      // expect(result.keypair, secureNet);
      // expect(result.devicePin, devicePin);

      verify(() => mockPointerManager.zeroOutAndFree(passphrasePtr, passphrase.length)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(pinCodePtr, pinCode.length)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(saltPtr, salt.length)).called(1);
      verify(() => mockPointerManager.free(securenetPtr)).called(1);
      verify(() => mockPointerManager.free(devicePinPtr)).called(1);
      verify(() => mockPointerManager.free(devicePinLenPtr)).called(1);
    });

    // test('generateKeypair throws TagionException on error', () {
    //   // Arrange
    //   final passphrase = 'passphrase';
    //   final pinCode = 'pinCode';
    //   final salt = 'salt';

    //   final passphrasePtr = Pointer<Char>.fromAddress(1);
    //   final pinCodePtr = Pointer<Char>.fromAddress(2);
    //   final saltPtr = Pointer<Char>.fromAddress(3);
    //   final securenetPtr = Pointer<SecureNet>.fromAddress(4);
    //   final devicePinPtr = Pointer<Pointer<Uint8>>.fromAddress(5);
    //   final devicePinLenPtr = Pointer<Uint64>.fromAddress(6);

    //   when(mockPointerManager.allocate<Char>(any)).thenReturn(passphrasePtr);
    //   when(mockPointerManager.allocate<Char>(any)).thenReturn(pinCodePtr);
    //   when(mockPointerManager.allocate<Char>(any)).thenReturn(saltPtr);
    //   when(mockPointerManager.allocate<SecureNet>()).thenReturn(securenetPtr);
    //   when(mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(devicePinPtr);
    //   when(mockPointerManager.allocate<Uint64>()).thenReturn(devicePinLenPtr);
    //   when(mockCryptoFfi.tagion_generate_keypair(any, any, any, any, any, any, any, any, any))
    //       .thenReturn(TagionErrorCode.invalidPin.value);

    //   when(mockErrorMessage.getErrorText()).thenReturn('Invalid PIN');

    //   // Act & Assert
    //   expect(
    //     () => crypto.generateKeypair(passphrase, pinCode, salt),
    //     throwsA(isA<TagionException>().having((e) => e.message, 'message', 'Invalid PIN')),
    //   );

    //   verify(mockPointerManager.zeroOutAndFree(passphrasePtr, passphrase.length)).called(1);
    //   verify(mockPointerManager.zeroOutAndFree(pinCodePtr, pinCode.length)).called(1);
    //   verify(mockPointerManager.zeroOutAndFree(saltPtr, salt.length)).called(1);
    //   verify(mockPointerManager.free(securenetPtr)).called(1);
    //   verify(mockPointerManager.free(devicePinPtr)).called(1);
    //   verify(mockPointerManager.free(devicePinLenPtr)).called(1);
    // });

    // Additional tests for decryptDevicePin and sign can follow a similar pattern
  });
}
