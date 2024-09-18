import 'dart:ffi';

import 'package:tagion_dart_api/module/crypto/ffi/crypto_ffi.dart';

abstract interface class ISecureNetVault {
  Pointer<SecureNet> get secureNetPtr;

  void allocatePtr();

  void removePtr();
}
