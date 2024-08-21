import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/exception_factory.dart';
import 'package:tagion_dart_api/scope_interface.dart';

/// The [Scope] class provides functionality to perform an action on the end of the operation.
/// Requires a [_pointerManager] object and an [_errorMessage] object.
class Scope implements IScope {
  final IErrorMessage _errorMessage;

  const Scope(this._errorMessage);

  /// Checks the status of the operation and throws an exception if it is not successful.
  /// If the operation is successful, returns the result of the [onDone] function.
  /// Guarantees [onFinally] function execution.
  @override
  T onExit<T, E extends Exception>(
    int status,
    T Function() onDone,
    void Function()? onFinally,
  ) {
    try {
      if (status != TagionErrorCode.none.value) {
        throw ExceptionFactory.create<E>(TagionErrorCode.fromInt(status), _errorMessage.getErrorText());
      }
      return onDone();
    } finally {
      onFinally?.call();
    }
  }
}
