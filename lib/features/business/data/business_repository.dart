import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobo_app/core/database/app_database.dart';
import 'package:mobo_app/core/database/sync_queue_dao.dart';

class BusinessRepository {
  final AppDatabase _db;
  final SyncQueueDao _queue;

  BusinessRepository(this._db) : _queue = SyncQueueDao(_db);

  Future<void> recordSale({required String? customerId, required String paymentType, required List<Map<String, dynamic>> lineItems, required double amountPaid}) async {
    final clientId = const Uuid().v4();
    final total = lineItems.fold<double>(0.0, (prev, li) => prev + (li['quantity'] as num).toDouble() * (li['unitPrice'] as num).toDouble());

    await _db.transaction(() async {
      await _db.into(_db.sales).insert(
        SalesCompanion.insert(
          tenantId: 'local',
          customerId: Value(customerId),
          paymentType: paymentType,
          totalAmount: total,
          amountPaid: amountPaid,
          createdBy: 'local_user',
          clientId: Value(clientId),
        ),
      );

      for (final li in lineItems) {
        await _db.into(_db.saleItems).insert(
          SaleItemsCompanion.insert(
            saleId: clientId,
            itemId: Value(li['itemId'] ?? ''),
            itemNameSnapshot: li['itemNameSnapshot'] as String,
            quantity: (li['quantity'] as num).toDouble(),
            unitPrice: (li['unitPrice'] as num).toDouble(),
          ),
        );
      }

      // enqueue for sync
      await _queue.enqueue(table: 'sales', clientId: clientId, syncVersion: 1, operation: 'create', payload: {
        'customer_id': customerId,
        'payment_type': paymentType,
        'line_items': lineItems,
        'amount_paid': amountPaid,
        'client_id': clientId,
      });
    });
  }
}
