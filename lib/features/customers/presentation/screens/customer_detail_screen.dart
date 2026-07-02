import 'package:flutter/material.dart';
import 'package:mobo_app/core/database/app_database.dart';
import 'package:mobo_app/features/customers/data/customers_repository.dart';
import '../widgets/record_payment_sheet.dart';

class CustomerDetailScreen extends StatefulWidget {
  final AppDatabase db;
  final String customerId;
  const CustomerDetailScreen({super.key, required this.db, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final CustomersRepository _repo;
  late Future<CustomersData?> _customerFuture;

  @override
  void initState() {
    super.initState();
    _repo = CustomersRepository(widget.db);
    _customerFuture = _repo.getCustomerById(widget.customerId);
  }

  Future<void> _refresh() async {
    setState(() { _customerFuture = _repo.getCustomerById(widget.customerId); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Detail')),
      body: FutureBuilder<CustomersData?>(
        future: _customerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final c = snapshot.data;
          if (c == null) return const Center(child: Text('Customer not found'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Balance: ₹${c.currentBalance.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                Row(children: [
                  ElevatedButton(onPressed: () => showModalBottomSheet(context: context, builder: (_) => RecordPaymentSheet(db: widget.db, customerId: c.id, onDone: () { Navigator.of(context).pop(); _refresh(); })), child: const Text('Record Payment')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: () async { await _repo.sendReminder(c.id, 'whatsapp', createdBy: 'local_user'); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder queued'))); }, child: const Text('Send Reminder')),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
