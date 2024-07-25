import 'dart:ffi';

import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// A singleton class.
/// Designed to store a [_secureNetPtr] pointer, obtained
/// as a result of keypair generation or device pin decryption.
/// The [_secureNetPtr] field is a pointer to a [SecureNet] object.
class SecureNetVault {
  /// Pointer to the [SecureNet] keypair.
  late final Pointer<SecureNet> _secureNetPtr;
  Pointer<SecureNet> get secureNetPtr => _secureNetPtr;

  /// State of the pointer.
  bool _allocated = false;
  bool get initialized => _allocated;

  final IPointerManager _pointerManager;

  static SecureNetVault? _instance;

  factory SecureNetVault(PointerManager pointerManager) {
    _instance ??= SecureNetVault._(pointerManager);
    return _instance!;
  }

  SecureNetVault._(this._pointerManager);

  /// Allocates memory for the pointer.
  /// Sets [_allocated] flag to true.
  /// If already allocated, does nothing.
  void open() {
    if (!_allocated) {
      _secureNetPtr = _pointerManager.allocate<SecureNet>();
      _allocated = true;
    }
  }

  /// Frees memory for the pointer.
  /// Sets [_allocated] flag to false.
  /// If not allocated, does nothing.
  void close() {
    if (_allocated) {
      _pointerManager.free(_secureNetPtr);
      _allocated = false;
    }
  }
}
