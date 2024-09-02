import 'package:tagion_dart_api_example/wallet_storage/entity_interface.dart';

abstract interface class ITgnWalletStorage<E extends ITgnEntity> {
  Future<void> init();
  Future<void> write(E entity);
  Future<E> read(String id);

  /// Removes all data from storage.
  Future<void> clearAll();
}
