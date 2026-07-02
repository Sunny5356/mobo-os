import 'dart:convert';
import 'package:mobo_app/core/database/app_database.dart';
import 'package:mobo_app/core/database/sync_queue_dao.dart';

class CustomersRepository {
  final AppDatabase _db;
  final SyncQueueDao _queue;

  CustomersRepository(this._db) : _queue = SyncQueueDao(_db);

  Future<List<CustomersData>> getAllCustomers() async {
    return _db.select(_db.customers).get();
  }

  Future<CustomersData?> getCustomerById(String id) async {
    return (_db.select(_db.customers)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<void> addCustomer(String name, {String? phone}) async {
    final clientId = const Uuid().v4();
    await _db.into(_db.customers).insert(
      CustomersCompanion.insert(
        tenantId: 'local',
        name: name,
        phoneNumber: Value(phone),
        clientId: Value(clientId),
      ),
    );
  }

  Future<void> recordPayment(String customerId, double amount, {String? note, required String createdBy}) async {
    final clientId = const Uuid().v4();
    // ledger entry: negative amount reduces balance
    await _db.transaction(() async {
      await _db.into(_db.ledgerEntries).insert(
        LedgerEntriesCompanion.insert(
          tenantId: 'local',
          customerId: customerId,
          entryType: 'payment_received',
          amount: -amount,
          sourceTable: Value('manual'),
          sourceId: Value(null),
          createdBy: createdBy,
          clientId: Value(clientId),
        ),
      );

      // update denormalized balance locally
      final customer = await getCustomerById(customerId);
      if (customer != null) {
        final newBalance = customer.currentBalance + (-amount);
        await (_db.update(_db.customers)..where((c) => c.id.equals(customerId))).write(
          CustomersCompanion(currentBalance: Value(newBalance)),
        );
      }

      // enqueue ledger entry for sync
      await _queue.enqueue(table: 'ledger_entries', clientId: clientId, syncVersion: 1, operation: 'create', payload: {
        'customer_id': customerId,
        'entry_type': 'payment_received',
        'amount': -amount,
        'created_by': createdBy,
        'note': note,
      });
    });
  }

  Future<void> sendReminder(String customerId, String channel, {required String createdBy}) async {
    final clientId = const Uuid().v4();
    // Enqueue a reminder payload; actual send will be performed by backend when synced.
    await _queue.enqueue(table: 'reminders', clientId: clientId, syncVersion: 1, operation: 'create', payload: {
      'customer_id': customerId,
      'channel': channel,
      'created_by': createdBy,
    });
  }
}
