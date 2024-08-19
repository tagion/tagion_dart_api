import 'dart:typed_data';

abstract interface class ITagionWallet {
  bool create(String passPhrase, String pinCode, String salt);
  bool login(String pinCode);
  void logout();
  bool isLoggedIn();
  bool delete();
  Uint8List getPublicKey();
}
