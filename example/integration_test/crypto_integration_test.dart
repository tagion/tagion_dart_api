import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/crypto/crypto.dart';
import 'package:tagion_dart_api/crypto/crypto_interface.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault/secure_net_vault.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault/secure_net_vault_interface.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/exception/crypto_exception.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

void main() {
  final DynamicLibrary dyLib = FFILibraryUtil.load();
  BasicFfi basicFfi = BasicFfi(dyLib);
  setUpAll(() {
    basicFfi.start_rt();
  });

  cryptoIntegrationTest(dyLib);

  tearDownAll(() {
    basicFfi.stop_rt();
  });
}

void cryptoIntegrationTest(DynamicLibrary dyLib) {
  group('Crypto-CryptoFfi-SecureNetVault_DynamicLibrary Integration.', () {
    //create a Crypto object
    final CryptoFfi cryptoFfi = CryptoFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final IErrorMessage errorMessage = ErrorMessage(ErrorMessageFfi(dyLib), pointerManager);
    final ISecureNetVault vault = SecureNetVault(pointerManager);
    final ICrypto crypto = Crypto(cryptoFfi, pointerManager, errorMessage);

    const String passphrase = 'passphrase';
    const String pinCode = 'pinCode';
    const String salt = 'salt';

    Uint8List devicePin = Uint8List.fromList([]);

    test('returns devicePin and sets secureNetPtr', () {
      int innerSecureNetPtrHashBefore = vault.secureNetPtr.ref.securenet.hashCode;
      int devicePinLength = 117;
      devicePin = crypto.generateKeypair(passphrase, pinCode, salt, vault.secureNetPtr);
      int innerSecureNetPtrHashAfter = vault.secureNetPtr.ref.securenet.hashCode;
      expect(devicePin, isNotEmpty);
      expect(devicePinLength, devicePin.length);
      expect(innerSecureNetPtrHashBefore, isNot(innerSecureNetPtrHashAfter));
    });

    test('decrypt sets SecureNet in SecureNetVault', () {
      vault.removePtr();
      vault.allocatePtr();
      int innerSecureNetPtrHashBefore = vault.secureNetPtr.ref.securenet.hashCode;
      expect(() => crypto.decryptDevicePin(pinCode, devicePin, vault.secureNetPtr), returnsNormally);
      int innerSecureNetPtrHashAfter = vault.secureNetPtr.ref.securenet.hashCode;
      expect(innerSecureNetPtrHashBefore, isNot(innerSecureNetPtrHashAfter));
    });

    test('throws CryptoException on decrypt with incorrect pinCode, devicePin', () {
      const String incorrectPinCode = 'incorrectPinCode';
      Uint8List incorrectDevicePin = Uint8List.fromList([0, 1, 2, 3]);

      expect(
        () => crypto.decryptDevicePin(incorrectPinCode, devicePin, vault.secureNetPtr),
        throwsA(
          isA<CryptoException>()
              .having(
                (e) => e.errorCode,
                '',
                equals(TagionErrorCode.exception),
              )
              .having(
                (e) => e.message,
                '',
                equals(''),
              ),
        ),
      );

      expect(
        () => crypto.decryptDevicePin(pinCode, incorrectDevicePin, vault.secureNetPtr),
        throwsA(
          isA<CryptoException>()
              .having(
                (e) => e.errorCode,
                '',
                equals(TagionErrorCode.exception),
              )
              .having(
                (e) => e.message,
                '',
                equals('Missing HiBON type'),
              ),
        ),
      );
    });

    test('sign returns signature', () {
      Uint8List dataToSign = Uint8List(32);
      Uint8List signature = crypto.sign(dataToSign, vault.secureNetPtr);
      expect(signature, isNotEmpty);
    });

    test('sign throws CryptoException on incorrect dataLen', () {
      Uint8List dataToSign = Uint8List(10);

      expect(
        () => crypto.sign(dataToSign, vault.secureNetPtr),
        throwsA(
          isA<CryptoException>()
              .having(
                (e) => e.errorCode,
                '',
                equals(TagionErrorCode.error),
              )
              .having(
                (e) => e.message,
                '',
                contains('Message length is invalid should be'),
              ),
        ),
      );
    });
  });
}
