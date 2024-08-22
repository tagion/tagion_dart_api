import 'dart:typed_data';

class TgnWalletSqlObject {
  final String id;
  final Uint8List devicePin;

  TgnWalletSqlObject(this.id, this.devicePin);
}
