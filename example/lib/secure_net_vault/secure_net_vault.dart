import 'dart:ffi';

import 'package:tagion_dart_api/module/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

import 'secure_net_vault_interface.dart';

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
    allocatePtr();
  }

  factory SecureNetVault(IPointerManager pointerManager) {
    _instance ??= SecureNetVault._(pointerManager);
    return _instance!;
  }

  @override
  Pointer<SecureNet> get secureNetPtr => _secureNetPtr;

  static final Finalizer<Pointer<SecureNet>> _finalizer = Finalizer<Pointer<SecureNet>>(
    (pointer) => const PointerManager().zeroOutAndFree(pointer, 1),
  );

  /// State of the pointer.
  bool _allocated = false;

  /// Allocates memory for the pointer.
  /// Sets [_allocated] flag to true.
  /// If already allocated, does nothing.
  @override
  void allocatePtr() {
    if (_allocated) {
      throw TagionApiException(
          TagionErrorCode.exception, '_secureNetPtr already allocated. Call close() before opening again.');
    }
    _secureNetPtr = _pointerManager.allocate<SecureNet>();
    _allocated = true;
    _finalizer.attach(this, _secureNetPtr);
  }

  /// Frees memory for the pointer.
  /// Sets [_allocated] flag to false.
  /// If not allocated, does nothing.
  @override
  void removePtr() {
    _pointerManager.zeroOutAndFree(_secureNetPtr, 1);
    _allocated = false;
    _finalizer.detach(this);
  }
}
