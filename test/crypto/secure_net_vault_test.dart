import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault/secure_net_vault.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:test/test.dart';

class MockPointerManager extends Mock implements IPointerManager {}

void main() {
  registerFallbackValue(Pointer<SecureNet>.fromAddress(0));

  group('SecureNetVault Unit.', () {
    Pointer<SecureNet> secureNetPtr = malloc.allocate<SecureNet>(1);
    final MockPointerManager mockPointerManager = MockPointerManager();
    when(() => mockPointerManager.allocate<SecureNet>()).thenReturn(secureNetPtr);
    final SecureNetVault secureNetVault = SecureNetVault(mockPointerManager);
    final SecureNetVault secureNetVault2 = SecureNetVault(mockPointerManager);

    test('is a singleton', () {
      int hashCode1 = secureNetVault.hashCode;
      int hashCode2 = secureNetVault2.hashCode;
      expect(hashCode1, equals(hashCode2));

      verify(() => mockPointerManager.allocate<SecureNet>()).called(1);
    });

    test('open exits when already allocated', () {
      secureNetVault.open();
      verifyNever(() => mockPointerManager.allocate<SecureNet>());
    });

    test('zeroes out secureNetPtr on close', () {
      when(() => mockPointerManager.zeroOutAndFree(any(), any())).thenAnswer((_) {});
      secureNetVault.close();

      verify(() => mockPointerManager.zeroOutAndFree(secureNetPtr, 1)).called(1);
    });
  });
}
