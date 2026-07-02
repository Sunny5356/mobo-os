import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Items extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get tenantId => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  RealColumn get stockQty => real().withDefault(const Constant(0.0))();
  RealColumn get lowStockThreshold => real().nullable()();
  TextColumn get barcode => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get clientId => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  @override
  Set<Column> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get tenantId => text()();
  TextColumn get name => text()();
  TextColumn get phoneNumber => text().nullable()();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get clientId => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  @override
  Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get tenantId => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get paymentType => text()();
  RealColumn get totalAmount => real()();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get clientId => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  @override
  Set<Column> get primaryKey => {id};
}

class SaleItems extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get saleId => text()();
  TextColumn get itemId => text().nullable()();
  TextColumn get itemNameSnapshot => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  @override
  Set<Column> get primaryKey => {id};
}

class LedgerEntries extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get tenantId => text()();
  TextColumn get customerId => text()();
  TextColumn get entryType => text()();
  RealColumn get amount => real()();
  TextColumn get sourceTable => text().nullable()();
  TextColumn get sourceId => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get clientId => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName => text()();
  TextColumn get clientId => text()();
  IntColumn get syncVersion => integer()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Items, Customers, Sales, SaleItems, LedgerEntries, SyncQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Example DAO methods
  Future<List<Item>> getAllItems() => select(items).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final docDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(docDir.path, 'mobo.sqlite'));
    return NativeDatabase(file);
  });
}

// Minimal UUID helper to avoid adding uuid package in scaffold
class Uuid {
  const Uuid();
  String v4() => DateTime.now().microsecondsSinceEpoch.toRadixString(16);
}
