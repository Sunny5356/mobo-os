import 'package:flutter/material.dart';
import 'package:mobo_app/core/database/app_database.dart';
import 'package:mobo_app/features/customers/data/customers_repository.dart';
import 'customer_detail_screen.dart';

class CustomerDirectoryScreen extends StatefulWidget {
  final AppDatabase db;
  const CustomerDirectoryScreen({super.key, required this.db});

  @override
  State<CustomerDirectoryScreen> createState() => _CustomerDirectoryScreenState();
}

class _CustomerDirectoryScreenState extends State<CustomerDirectoryScreen> {
  late final CustomersRepository _repo;
  late Future<List<CustomersData>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _repo = CustomersRepository(widget.db);
    _customersFuture = _repo.getAllCustomers();
  }

  Future<void> _refresh() async {
    setState(() {
      _customersFuture = _repo.getAllCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: FutureBuilder<List<CustomersData>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data ?? [];
          if (list.isEmpty) return const Center(child: Text('No customers yet'));
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final c = list[i];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.phoneNumber ?? ''),
                  trailing: Text('₹${c.currentBalance.toStringAsFixed(0)}'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CustomerDetailScreen(db: widget.db, customerId: c.id))),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
