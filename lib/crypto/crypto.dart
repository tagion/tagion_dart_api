import 'dart:ffi';
import 'dart:typed_data';

import 'package:tagion_dart_api/crypto/crypto_interface.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/crypto/secure_net_vault.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';

/// Crypto class.
/// Implements the ICrypto interface.
/// Provides methods for generating a keypair, decrypting a device pin, and signing a message.
/// Uses the [CryptoFfi] class to call the native functions.
/// Uses the [PointerManager] class to manage the memory.
/// Uses the [ErrorMessage] class to get the error message.
/// Uses the [SecureNetVault] class to set or get access to a stored keypair pointer.
class Crypto implements ICrypto {
  final CryptoFfi _cryptoFfi;
  final PointerManager _pointerManager;
  final ErrorMessage _errorMessage;
  final SecureNetVault _vault;

  const Crypto(
    this._cryptoFfi,
    this._pointerManager,
    this._errorMessage,
    this._vault,
  );

  /// Generates a keypair.
  /// Returns a [Uint8List] device pin.
  /// Throws a [TagionException] if an error occurs.
  /// The [passphrase] parameter is a string.
  /// The [pinCode] parameter is a string.
  /// The [salt] parameter is a string.
  @override
  Uint8List generateKeypair(String passphrase, String pinCode, String salt) {
    /// Data lengths.
    final passphraseLen = passphrase.length;
    final pinCodeLen = pinCode.length;
    final saltLen = salt.length;

    /// In.
    final Pointer<Char> passphrasePtr = _pointerManager.allocate<Char>(passphraseLen);
    final Pointer<Char> pinCodePtr = _pointerManager.allocate<Char>(pinCodeLen);
    final Pointer<Char> saltPtr = _pointerManager.allocate<Char>(saltLen);

    /// Fill pointers.
    _pointerManager.stringToPointer(passphrasePtr, passphrase);
    _pointerManager.stringToPointer(pinCodePtr, pinCode);
    _pointerManager.stringToPointer(saltPtr, salt);

    /// Out.
    final Pointer<Pointer<Uint8>> devicePinPtr = _pointerManager.allocate<Pointer<Uint8>>();
    final Pointer<Uint64> devicePinLenPtr = _pointerManager.allocate<Uint64>();

    int status = _cryptoFfi.tagion_generate_keypair(
      passphrasePtr,
      passphraseLen,
      saltPtr,
      saltLen,
      _vault.secureNetPtr, // Uses the secureNetPtr field in the SecureNetVault class.
      pinCodePtr,
      pinCodeLen,
      devicePinPtr,
      devicePinLenPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free memory.
      _pointerManager.zeroOutAndFree(passphrasePtr, passphraseLen);
      _pointerManager.zeroOutAndFree(pinCodePtr, pinCodeLen);
      _pointerManager.zeroOutAndFree(saltPtr, saltLen);
      _pointerManager.free(devicePinPtr);
      _pointerManager.free(devicePinLenPtr);

      throw TagionException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the values.
    final devicePin = devicePinPtr.value.asTypedList(devicePinLenPtr.value);

    /// Free memory.
    _pointerManager.zeroOutAndFree(passphrasePtr, passphraseLen);
    _pointerManager.zeroOutAndFree(pinCodePtr, pinCodeLen);
    _pointerManager.zeroOutAndFree(saltPtr, saltLen);
    _pointerManager.free(devicePinPtr);
    _pointerManager.free(devicePinLenPtr);

    return devicePin;
  }

  /// Decrypts a device pin.
  /// Throws a [TagionException] if an error occurs.
  /// The [pinCode] parameter is a string.
  /// The [devicepin] parameter is a Uint8List.
  @override
  void decryptDevicePin(String pinCode, Uint8List devicepin) {
    /// Data lengths.
    final pinCodeLen = pinCode.length;
    final devicePinLen = devicepin.length;

    /// In.
    final Pointer<Char> pinCodePtr = _pointerManager.allocate<Char>(pinCodeLen);
    final Pointer<Uint8> devicePinPtr = _pointerManager.allocate<Uint8>(devicePinLen);

    /// Fill pointers.
    _pointerManager.stringToPointer(pinCodePtr, pinCode);
    _pointerManager.uint8ListToPointer(devicePinPtr, devicepin);

    int status = _cryptoFfi.tagion_decrypt_devicepin(
      pinCodePtr,
      pinCodeLen,
      devicePinPtr,
      devicePinLen,
      _vault.secureNetPtr, // Uses the secureNetPtr field in the SecureNetVault class.
    );

    /// Free memory.
    _pointerManager.zeroOutAndFree(pinCodePtr, pinCodeLen);
    _pointerManager.zeroOutAndFree(devicePinPtr, devicePinLen);

    /// Check the status.
    if (status != TagionErrorCode.none.value) {
      throw TagionException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }
  }

  /// Signs a given [Uint8List] typed list.
  /// Returns a signed data as a [Uint8List] typed list.
  /// Throws a [TagionException] if an error occurs.
  /// The [dataToSign] parameter is a Uint8List.
  @override
  Uint8List sign(Uint8List dataToSign) {
    /// Data lengths.
    final dataToSignLen = dataToSign.length;

    /// In.
    final Pointer<Uint8> dataToSignPtr = _pointerManager.allocate<Uint8>(dataToSignLen);

    /// Out.
    final Pointer<Pointer<Uint8>> signaturePtr = _pointerManager.allocate<Pointer<Uint8>>();
    final Pointer<Uint64> signatureLenPtr = _pointerManager.allocate<Uint64>();

    /// Fill the pointer.
    _pointerManager.uint8ListToPointer(dataToSignPtr, dataToSign);

    int status = _cryptoFfi.tagion_sign_message(
      _vault.secureNetPtr, // Uses the secureNetPtr field in the SecureNetVault class.
      dataToSignPtr,
      dataToSignLen,
      signaturePtr,
      signatureLenPtr,
    );

    if (status != TagionErrorCode.none.value) {
      /// Free memory.
      _pointerManager.free(dataToSignPtr);
      _pointerManager.free(signaturePtr);

      throw TagionException(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
    }

    /// Get the values.
    final signature = signaturePtr.value.asTypedList(signatureLenPtr.value);

    /// Free memory.
    _pointerManager.free(dataToSignPtr);
    _pointerManager.free(signaturePtr);

    return signature;
  }
}
