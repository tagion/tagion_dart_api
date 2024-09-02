import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/crypto/crypto_interface.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/crypto_exception.dart';
import 'package:tagion_dart_api_example/secure_net_vault/secure_net_vault_interface.dart';
import 'package:tagion_dart_api_example/wallet/wallet.dart';
import 'package:tagion_dart_api_example/wallet/wallet_interface.dart';
import 'package:tagion_dart_api_example/wallet_details/wallet_details_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_entity.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_exception.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_interface.dart';

class MockCrypto extends Mock implements ICrypto {}

class MockSecureNetVault extends Mock implements ITgnSecureNetVault {}

class MockWalletDetails extends Mock implements ITgnWalletDetails {}

class MockWalletStorage extends Mock implements ITgnWalletStorage {}

void main() {
  registerFallbackValue(Pointer<SecureNet>.fromAddress(0));
  registerFallbackValue(Uint8List.fromList([0]));
  registerFallbackValue(TgnWalletEntity('id', Uint8List.fromList([0])));

  final ICrypto mockCrypto = MockCrypto();
  final ITgnSecureNetVault mockSecureNetVault = MockSecureNetVault();
  final ITgnWalletDetails mockWalletDetails = MockWalletDetails();
  final ITgnWalletStorage mockWalletStorage = MockWalletStorage();

  final ITgnWallet tagionWallet = TgnWallet('id', mockCrypto, mockSecureNetVault, mockWalletDetails, mockWalletStorage);

  const String passphrase = 'passphrase';
  const String pinCode = 'pinCode';
  const String salt = 'salt';
  Pointer<SecureNet> mockSecureNetPtr = Pointer<SecureNet>.fromAddress(0);

  group('TagionWallet Unit.', () {
    test('create successfully creates wallet', () {
      when(() => mockSecureNetVault.secureNetPtr).thenReturn(mockSecureNetPtr);
      when(() => mockCrypto.generateKeypair(any(), any(), any(), any())).thenReturn(Uint8List.fromList([0, 1, 2, 3]));
      when(() => mockWalletDetails.setId(any())).thenReturn(null);
      when(() => mockWalletDetails.setDevicePin(any())).thenReturn(null);
      when(() => mockWalletDetails.toEntity()).thenReturn(TgnWalletEntity('id', Uint8List.fromList([0])));
      when(() => mockWalletStorage.write(any())).thenAnswer((_) => Future.value());
      expect(() => tagionWallet.create(passphrase, pinCode, salt), returnsNormally);
    });

    test('create throws CryptoApiException when failed to generate keypair', () {
      when(() => mockSecureNetVault.secureNetPtr).thenReturn(mockSecureNetPtr);
      when(() => mockCrypto.generateKeypair(any(), any(), any(), any()))
          .thenThrow(CryptoApiException(TagionErrorCode.error, 'message'));
      expect(
        () => tagionWallet.create(passphrase, pinCode, salt),
        throwsA(isA<CryptoApiException>()),
      );
    });

    test('create throws TgnWalletStorageException when failed to write data to a storage', () {
      when(() => mockSecureNetVault.secureNetPtr).thenReturn(mockSecureNetPtr);
      when(() => mockCrypto.generateKeypair(any(), any(), any(), any())).thenReturn(Uint8List.fromList([0, 1, 2, 3]));
      when(() => mockWalletDetails.setId(any())).thenReturn(null);
      when(() => mockWalletDetails.setDevicePin(any())).thenReturn(null);
      when(() => mockWalletDetails.toEntity()).thenReturn(TgnWalletEntity('id', Uint8List.fromList([0])));
      when(() => mockWalletStorage.write(any())).thenThrow(TgnWalletStorageException(''));
      expect(
        () => tagionWallet.create(passphrase, pinCode, salt),
        throwsA(isA<TgnWalletStorageException>()),
      );
    });
  });
}
