import 'dart:typed_data';

import 'package:tagion_dart_api_example/wallet_storage/entity_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_sql_object.dart';

class TgnWalletEntity implements ITgnEntity<TgnWalletSqlObject> {
  final String id;
  final Uint8List devicePin;

  TgnWalletEntity(this.id, this.devicePin);

  @override
  TgnWalletSqlObject toStorable() {
    return TgnWalletSqlObject(id, devicePin);
  }

  factory TgnWalletEntity.fromStorable(TgnWalletSqlObject storable) {
    return TgnWalletEntity(storable.id, storable.devicePin);
  }
}
