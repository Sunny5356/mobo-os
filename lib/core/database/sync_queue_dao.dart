import 'dart:convert';

import 'package:drift/drift.dart';
import 'app_database.dart';

class SyncQueueDao {
  final AppDatabase _db;
  SyncQueueDao(this._db);

  Future<void> enqueue({required String table, required String clientId, required int syncVersion, required String operation, required Map<String, dynamic> payload}) async {
    await _db.into(_db.syncQueue).insert(
      SyncQueueCompanion.insert(
        tableName: table,
        clientId: clientId,
        syncVersion: syncVersion,
        operation: operation,
        payload: jsonEncode(payload),
      ),
    );
  }

  Future<List<SyncQueueData>> pendingBatch({int limit = 50}) async {
    return (_db.select(_db.syncQueue)..where((t) => t.status.equals('pending'))..limit(limit)).get();
  }

  Future<void> markSynced(String clientId, {required String tableName}) async {
    await (_db.update(_db.syncQueue)..where((t) => t.clientId.equals(clientId) & t.tableName.equals(tableName))).write(
      const SyncQueueCompanion(status: Value('synced')),
    );
  }

  Future<void> markFailedByIds(List<int> ids) async {
    await _db.transaction(() async {
      for (final id in ids) {
        await (_db.update(_db.syncQueue)..where((t) => t.id.equals(id))).write(
          const SyncQueueCompanion(status: Value('failed')),
        );
      }
    });
  }
}
