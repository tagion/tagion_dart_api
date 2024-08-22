import 'dart:typed_data';

import 'package:tagion_dart_api_example/bill_interface.dart';
import 'package:tagion_dart_api_example/currency_interface.dart';
import 'package:tagion_dart_api_example/wallet_details/wallet_details_interface.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_entity.dart';

class TgnWalletDetails implements ITgnWalletDetails {
  String _id = 'Not set';
  Uint8List _devicePin = Uint8List(0);

  TgnWalletDetails();

  @override
  void setId(String id) {
    _id = id;
  }

  // @override
  // String get getId => _id;

  @override
  void setDevicePin(Uint8List devicePin) {
    _devicePin = devicePin;
  }

  // @override
  // Uint8List get getDevicePin => _devicePin;

  @override
  TgnWalletEntity toEntity() {
    return TgnWalletEntity(_id, _devicePin);
  }

  @override
  void addBill(ITgnBill bill) {
    throw UnimplementedError();
  }

  @override
  void removeBill(String key) {
    throw UnimplementedError();
  }

  @override
  void unlockBill(String key) {
    throw UnimplementedError();
  }

  @override
  ITgnCurrency getLockedBalance() {
    throw UnimplementedError();
  }

  @override
  ITgnCurrency getBalance() {
    throw UnimplementedError();
  }

  @override
  ITgnCurrency getTotalBalance() {
    throw UnimplementedError();
  }
}
