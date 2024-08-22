import 'package:tagion_dart_api_example/storable_interface.dart';
import 'package:tagion_dart_api_example/tagion_bill_interface.dart';
import 'package:tagion_dart_api_example/tagion_currency_interface.dart';

abstract interface class IWalletDetails implements IStorable {
  void addBill(ITagionBill bill);
  void removeBill(String key);
  void unlockBill(String key);
  ITagionCurrency getLockedBalance();
  ITagionCurrency getBalance();
  ITagionCurrency getTotalBalance();
}
