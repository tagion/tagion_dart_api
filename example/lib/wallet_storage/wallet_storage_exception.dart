class TgnWalletStorageException implements Exception {
  final String message;

  TgnWalletStorageException(this.message);

  @override
  String toString() {
    return 'WalletStorageException: $message';
  }
}
