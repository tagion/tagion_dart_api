import 'dart:ffi';

import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/exception_factory.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/scope_interface.dart';

/// The [Scope] class provides functionality to perform an action on the end of the operation.
/// Requires a [_pointerManager] object and an [_errorMessage] object.
class Scope implements IScope {
  final IPointerManager _pointerManager;
  final IErrorMessage _errorMessage;

  const Scope(this._pointerManager, this._errorMessage);

  /// Checks the status of the operation and throws an exception if it is not successful.
  /// If the operation is successful, returns the result of the [onDone] function.
  /// Guarantees freeing the memory of the pointers in the [ptrs] list.
  @override
  T onExit<T, E extends Exception>(
    int status,
    T Function() onDone, [
    List<Pointer> ptrs = const [],
  ]) {
    try {
      if (status != TagionErrorCode.none.value) {
        throw ExceptionFactory.create<E>(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
      }
      return onDone();
    } finally {
      _pointerManager.freeAll(ptrs);
    }
  }
}
