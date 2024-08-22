import 'package:tagion_dart_api_example/wallet_storage/entity_interface.dart';

abstract interface class ITgnWalletStorage<E extends ITgnEntity> {
  void init();
  void write(E entity);
}
