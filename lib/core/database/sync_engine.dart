import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_database.dart';
import 'sync_queue_dao.dart';

class SyncEngine {
  final AppDatabase _db;
  final SyncQueueDao _queue;
  Timer? _timer;

  // Endpoint for sync; change if your backend runs elsewhere.
  final Uri _syncUrl = Uri.parse('http://localhost:3001/v1/sync/push');

  SyncEngine(this._db) : _queue = SyncQueueDao(_db) {
    // periodic retry every 30s
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => syncNow());
  }

  Future<void> dispose() async {
    _timer?.cancel();
  }

  Future<void> syncNow() async {
    final batch = await _queue.pendingBatch(limit: 50);
    if (batch.isEmpty) return;

    // Build changes array and map local id -> queue entry
    final changes = <Map<String, dynamic>>[];
    final Map<int, SyncQueueData> byLocalId = {};
    for (final item in batch) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        changes.add({
          'type': item.tableName,
          'id': payload['id'],
          'local_id': item.id,
          'client_id': item.clientId,
          'payload': payload,
        });
        byLocalId[item.id] = item;
      } catch (e) {
        await _queue.markFailedByIds([item.id]);
      }
    }

    if (changes.isEmpty) return;

    try {
      final res = await http.post(_syncUrl, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'changes': changes}));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final List<dynamic>? results = body['applied'] ?? body['results'] ?? body['results'] as List<dynamic>?;
        final List<int> failedIds = [];

        if (results != null) {
          for (final r in results) {
            final localId = r['local_id'] ?? r['client_id'] ?? r['localId'];
            if (localId == null) continue;
            final entry = byLocalId[localId];
            if (entry == null) continue;
            final status = r['status'] ?? 'applied';
            if (status == 'applied' || status == 'ok' || status == 'applied') {
              await _queue.markSynced(entry.clientId, tableName: entry.tableName);
            } else {
              failedIds.add(entry.id);
            }
          }
        } else {
          // unknown response shape: mark all as synced
          for (final entry in byLocalId.values) {
            await _queue.markSynced(entry.clientId, tableName: entry.tableName);
          }
        }

        if (failedIds.isNotEmpty) {
          await _queue.markFailedByIds(failedIds);
        }
      } else {
        // server error: mark none and retry later
      }
    } catch (e) {
      // network or JSON failure: leave pending to retry
    }
  }
}
