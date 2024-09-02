import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:tagion_dart_api_example/path_provider.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_entity.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_sql_object.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_exception.dart';
import 'package:tagion_dart_api_example/wallet_storage/wallet_storage_interface.dart';

class TgnWalletStorageSqflite implements ITgnWalletStorage<TgnWalletEntity> {
  final IPathProvider _pathProvider;
  Database? _db;

  TgnWalletStorageSqflite(this._pathProvider);

  @override
  Future<void> init() async {
    String appPath = await _pathProvider.getApplpicationDocumentsPath();
    String dbPath = '${appPath}_sqflite.db';
    _db = await openDatabase(dbPath, version: 1, onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Wallet (id TEXT PRIMARY KEY, devicePin BLOB)');
    });
  }

  @override
  Future<void> write(TgnWalletEntity walletDetails) async {
    TgnWalletSqlObject storageObject = walletDetails.toStorable();
    int? insertedRowId = await _db?.transaction<int>((txn) async {
      return await txn
          .rawInsert('INSERT INTO Wallet(id, devicePin) VALUES(?, ?)', [storageObject.id, storageObject.devicePin]);
    });
    if (insertedRowId == null || insertedRowId == 0) {
      throw TgnWalletStorageException('Failed to insert');
    }
  }

  @override
  Future<TgnWalletEntity> read(String id) async {
    List<Map<String, Object?>>? list = await _db?.rawQuery('SELECT * FROM Wallet WHERE id = $id');
    if (list == null || list.isEmpty) {
      throw TgnWalletStorageException('Empty or failed to read. wallet_id: $id');
    }

    TgnWalletSqlObject storageObject = TgnWalletSqlObject(list[0]['id'] as String, list[0]['devicePin'] as Uint8List);
    TgnWalletEntity walletEntity = TgnWalletEntity.fromStorable(storageObject);
    return walletEntity;
  }

  @override
  Future<void> clearAll() async {
    await _db?.delete('Wallet');
  }
}
