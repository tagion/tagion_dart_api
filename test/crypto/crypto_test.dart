import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/crypto/crypto.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault/secure_net_vault_interface.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:test/test.dart';

// Mock classes
class MockCryptoFfi extends Mock implements CryptoFfi {}

class MockPointerManager extends Mock implements PointerManager {}

class MockErrorMessage extends Mock implements ErrorMessage {}

class MockSecureNetVault extends Mock implements ISecureNetVault {}

void main() {
  group('Crypto', () {
    late MockCryptoFfi mockCryptoFfi;
    late MockPointerManager mockPointerManager;
    late MockErrorMessage mockErrorMessage;
    late MockSecureNetVault mockSecureNetVault;
    late Crypto crypto;

    setUp(() {
      registerFallbackValue('fallBackValue');
      registerFallbackValue(Pointer<Uint8>.fromAddress(0));
      registerFallbackValue(Pointer<Pointer<Uint8>>.fromAddress(0));
      registerFallbackValue(Pointer<Uint64>.fromAddress(0));
      registerFallbackValue(Pointer<Char>.fromAddress(0));
      registerFallbackValue(Pointer<SecureNet>.fromAddress(0));
      registerFallbackValue(0);
      mockCryptoFfi = MockCryptoFfi();
      mockPointerManager = MockPointerManager();
      mockErrorMessage = MockErrorMessage();
      mockSecureNetVault = MockSecureNetVault();
      crypto = Crypto(
        mockCryptoFfi,
        mockPointerManager,
        mockErrorMessage,
        mockSecureNetVault,
      );
    });

    test('generateKeypair returns the correct Uint8List and throws TagionException when an error occurs', () {
      // Arrange
      const passphrase = 'passphrase';
      const pinCode = 'pinCode';
      const salt = 'salt';

      const devicePinBytes = [1, 2, 3, 4, 5];

      final Pointer<Char> passphrasePtr = malloc<Char>(passphrase.length);
      final Pointer<Char> pinCodePtr = malloc<Char>(pinCode.length);
      final Pointer<Char> saltPtr = malloc<Char>(salt.length);
      final Pointer<SecureNet> securenetPtr = malloc<SecureNet>();
      final Pointer<Pointer<Uint8>> devicePinPtr = malloc<Pointer<Uint8>>();
      final Pointer<Uint64> devicePinLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Char>(passphrase.length)).thenReturn(passphrasePtr);
      when(() => mockPointerManager.allocate<Char>(pinCode.length)).thenReturn(pinCodePtr);
      when(() => mockPointerManager.allocate<Char>(salt.length)).thenReturn(saltPtr);
      when(() => mockSecureNetVault.secureNetPtr).thenReturn(securenetPtr);
      when(() => mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(devicePinPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(devicePinLenPtr);

      when(() => mockCryptoFfi.tagion_generate_keypair(any(), any(), any(), any(), any(), any(), any(), any(), any()))
          .thenAnswer((invocation) {
        final Pointer<Pointer<Uint8>> devicePinPtr = invocation.positionalArguments[7];
        devicePinPtr.value = malloc<Uint8>(devicePinBytes.length);
        for (var i = 0; i < devicePinBytes.length; i++) {
          devicePinPtr.value[i] = devicePinBytes[i];
        }

        final Pointer<Uint64> devicePinLenPtr = invocation.positionalArguments[8];
        devicePinLenPtr.value = devicePinBytes.length;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = crypto.generateKeypair(passphrase, pinCode, salt);

      // Assert
      expect(result, isA<Uint8List>());
      expect(result, equals(Uint8List.fromList(devicePinBytes)));

      // Verify
      verify(() => mockPointerManager.allocate<Char>(passphrase.length)).called(1);
      verify(() => mockPointerManager.allocate<Char>(pinCode.length)).called(1);
      verify(() => mockPointerManager.allocate<Char>(salt.length)).called(1);
      verify(() => mockPointerManager.allocate<Pointer<Uint8>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockPointerManager.stringToPointer(passphrasePtr, passphrase)).called(1);
      verify(() => mockPointerManager.stringToPointer(pinCodePtr, pinCode)).called(1);
      verify(() => mockPointerManager.stringToPointer(saltPtr, salt)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(passphrasePtr, passphrase.length)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(pinCodePtr, pinCode.length)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(saltPtr, salt.length)).called(1);
      verify(() => mockPointerManager.free(devicePinPtr)).called(1);
      verify(() => mockPointerManager.free(devicePinLenPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockCryptoFfi.tagion_generate_keypair(any(), any(), any(), any(), any(), any(), any(), any(), any()))
          .thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => crypto.generateKeypair(passphrase, pinCode, salt),
        throwsA(isA<TagionException>()
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
      verify(() => mockPointerManager.zeroOutAndFree(passphrasePtr, passphrase.length)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(pinCodePtr, pinCode.length)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(saltPtr, salt.length)).called(1);
      verify(() => mockPointerManager.free(devicePinPtr)).called(1);
      verify(() => mockPointerManager.free(devicePinLenPtr)).called(1);
    });

    test('decryptDevicePin succeeds and throws TagionException when an error occurs', () {
      // Arrange
      const pinCode = 'pinCode';
      final devicePinBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final Pointer<Char> pinCodePtr = malloc<Char>(pinCode.length);
      final Pointer<Uint8> devicePinPtr = malloc<Uint8>(devicePinBytes.length);
      final Pointer<SecureNet> securenetPtr = malloc<SecureNet>();

      when(() => mockPointerManager.allocate<Char>(pinCode.length)).thenReturn(pinCodePtr);
      when(() => mockPointerManager.allocate<Uint8>(devicePinBytes.length)).thenReturn(devicePinPtr);
      when(() => mockSecureNetVault.secureNetPtr).thenReturn(securenetPtr);

      when(() => mockCryptoFfi.tagion_decrypt_devicepin(any(), any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Uint8> devicePinPtr = invocation.positionalArguments[2];

        for (var i = 0; i < devicePinBytes.length; i++) {
          devicePinPtr[i] = devicePinBytes[i];
        }

        return TagionErrorCode.none.value;
      });

      // Act
      crypto.decryptDevicePin(pinCode, devicePinBytes);

      // Verify
      verify(() => mockPointerManager.allocate<Char>(pinCode.length)).called(1);
      verify(() => mockPointerManager.allocate<Uint8>(devicePinBytes.length)).called(1);
      verify(() => mockSecureNetVault.secureNetPtr).called(1);
      verify(() => mockPointerManager.stringToPointer(pinCodePtr, pinCode)).called(1);
      verify(() => mockPointerManager.uint8ListToPointer(devicePinPtr, devicePinBytes)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(pinCodePtr, pinCode.length)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(devicePinPtr, devicePinBytes.length)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockCryptoFfi.tagion_decrypt_devicepin(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => crypto.decryptDevicePin(pinCode, devicePinBytes),
        throwsA(isA<TagionException>()
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
      verify(() => mockPointerManager.zeroOutAndFree(pinCodePtr, pinCode.length)).called(1);
      verify(() => mockPointerManager.zeroOutAndFree(devicePinPtr, devicePinBytes.length)).called(1);
    });

    test('sign returns the correct Uint8List and throws TagionException when an error occurs', () {
      // Arrange
      final dataToSign = Uint8List.fromList([1, 2, 3, 4, 5]);
      final signedData = Uint8List.fromList([6, 7, 8, 9, 0]);

      final Pointer<Uint8> dataToSignPtr = malloc<Uint8>(dataToSign.length);
      final Pointer<SecureNet> secureNetPtr = malloc<SecureNet>();
      final Pointer<Pointer<Uint8>> signedDataPtr = malloc<Pointer<Uint8>>();
      final Pointer<Uint64> signedDataLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Uint8>(dataToSign.length)).thenReturn(dataToSignPtr);
      when(() => mockSecureNetVault.secureNetPtr).thenReturn(secureNetPtr);
      when(() => mockPointerManager.allocate<Pointer<Uint8>>()).thenReturn(signedDataPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(signedDataLenPtr);

      when(() => mockCryptoFfi.tagion_sign_message(any(), any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Uint8>> signedDataPtr = invocation.positionalArguments[3];
        final Pointer<Uint64> signedDataLenPtr = invocation.positionalArguments[4];

        signedDataPtr.value = malloc<Uint8>(signedData.length);
        for (var i = 0; i < signedData.length; i++) {
          signedDataPtr.value[i] = signedData[i];
        }

        signedDataLenPtr.value = signedData.length;

        return TagionErrorCode.none.value;
      });

      // Act
      final result = crypto.sign(dataToSign);

      // Assert
      expect(result, isA<Uint8List>());
      expect(result, equals(signedData));

      // Verify
      verify(() => mockPointerManager.allocate<Uint8>(dataToSign.length)).called(1);
      verify(() => mockPointerManager.allocate<Pointer<Uint8>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockPointerManager.uint8ListToPointer<Uint8>(dataToSignPtr, dataToSign)).called(1);
      verify(() => mockPointerManager.free(dataToSignPtr)).called(1);
      verify(() => mockPointerManager.free(signedDataPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockCryptoFfi.tagion_sign_message(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => crypto.sign(dataToSign),
        throwsA(isA<TagionException>()
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
      verify(() => mockPointerManager.free(dataToSignPtr)).called(1);
      verify(() => mockPointerManager.free(signedDataPtr)).called(1);
    });
  });
}
