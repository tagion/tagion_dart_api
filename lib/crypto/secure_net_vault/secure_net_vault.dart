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
  late final Pointer<SecureNet> _secureNetPtr;

  @override
  Pointer<SecureNet> get secureNetPtr => _secureNetPtr;

  /// State of the pointer.
  bool _allocated = false;

  @override
  bool get initialized => _allocated;

  final IPointerManager _pointerManager;

  static SecureNetVault? _instance;

  factory SecureNetVault(IPointerManager pointerManager) {
    _instance ??= SecureNetVault._(pointerManager);
    return _instance!;
  }

  SecureNetVault._(this._pointerManager);

  /// Allocates memory for the pointer.
  /// Sets [_allocated] flag to true.
  /// If already allocated, does nothing.
  @override
  void open() {
    if (!_allocated) {
      _secureNetPtr = _pointerManager.allocate<SecureNet>();
      _allocated = true;
    }
  }

  /// Frees memory for the pointer.
  /// Sets [_allocated] flag to false.
  /// If not allocated, does nothing.
  @override
  void close() {
    if (_allocated) {
      _pointerManager.free(_secureNetPtr);
      _allocated = false;
    }
  }
}
