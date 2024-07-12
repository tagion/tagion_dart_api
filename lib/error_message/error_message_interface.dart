/// An interface for error functions.
abstract interface class IErrorMessage {
  /// Get the last error message.
  String getErrorText();

  /// Clear the all error messages.
  void clearErrors();
}
