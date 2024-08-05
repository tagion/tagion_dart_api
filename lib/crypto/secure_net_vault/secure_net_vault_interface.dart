import 'dart:ffi';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';

abstract interface class ISecureNetVault {
  Pointer<SecureNet> get secureNetPtr;

  void open();

  void close();
}
