import 'dart:ffi';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault/secure_net_vault_interface.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// A singleton class.
/// Designed to store a [_secureNetPtr] pointer, obtained
/// as a result of keypair generation or device pin decryption.
/// The [_secureNetPtr] field is a pointer to a [SecureNet] object.
class SecureNetVault implements ISecureNetVault {
  /// Pointer to the [SecureNet] keypair.
  final IPointerManager _pointerManager;
  late Pointer<SecureNet> _secureNetPtr;
  static SecureNetVault? _instance;

  SecureNetVault._(this._pointerManager) {
    open();
  }

  factory SecureNetVault(IPointerManager pointerManager) {
    _instance ??= SecureNetVault._(pointerManager);
    return _instance!;
  }

  @override
  Pointer<SecureNet> get secureNetPtr => _secureNetPtr;

  /// State of the pointer.
  bool _allocated = false;

  /// Allocates memory for the pointer.
  /// Sets [_allocated] flag to true.
  /// If already allocated, does nothing.
  @override
  void open() {
    if (_allocated) return;
    _secureNetPtr = _pointerManager.allocate<SecureNet>();
    _allocated = true;
  }

  /// Frees memory for the pointer.
  /// Sets [_allocated] flag to false.
  /// If not allocated, does nothing.
  @override
  void close() {
    _pointerManager.zeroOutAndFree(_secureNetPtr, 1);
    _allocated = false;
  }
}
