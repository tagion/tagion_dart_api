import 'dart:typed_data';

import 'package:tagion_dart_api_example/bill_interface.dart';
import 'package:tagion_dart_api_example/currency_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_entity.dart';

abstract interface class ITgnWalletDetails {
  void setId(String id);
  // String get getId;
  void setDevicePin(Uint8List devicePin);
  // Uint8List get getDevicePin;
  TgnWalletEntity toEntity();
  void addBill(ITgnBill bill);
  void removeBill(String key);
  void unlockBill(String key);
  ITgnCurrency getLockedBalance();
  ITgnCurrency getBalance();
  ITgnCurrency getTotalBalance();
}
