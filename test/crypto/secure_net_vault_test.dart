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
    final Pointer<SecureNet> secureNetPtr = malloc.allocate<SecureNet>(sizeOf<SecureNet>());
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

    test('is initialized after instantiation', () {
      final bool isInitialized = secureNetVault.initialized;
      expect(isInitialized, isTrue);
    });

    test('returns same pointer', () {
      final int secureNetPtrAddress = secureNetVault.secureNetPtr.address;
      final int secureNetPtr2Address = secureNetVault2.secureNetPtr.address;
      expect(secureNetPtrAddress, equals(secureNetPtr2Address));
    });

    test('not initialized on close', () {
      when(() => mockPointerManager.zeroOutAndFree(any(), any())).thenReturn(null);
      secureNetVault.close();
      final bool isInitialized = secureNetVault.initialized;
      expect(isInitialized, isFalse);

      verify(() => mockPointerManager.zeroOutAndFree(secureNetPtr, sizeOf<SecureNet>())).called(1);
    });
  });
}
