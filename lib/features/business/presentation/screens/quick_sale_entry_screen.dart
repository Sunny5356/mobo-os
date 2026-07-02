import 'package:flutter/material.dart';
import 'package:mobo_app/features/business/data/business_repository.dart';
import 'package:mobo_app/core/database/app_database.dart';

class QuickSaleEntryScreen extends StatefulWidget {
  final AppDatabase db;
  const QuickSaleEntryScreen({super.key, required this.db});

  @override
  State<QuickSaleEntryScreen> createState() => _QuickSaleEntryScreenState();
}

class _QuickSaleEntryScreenState extends State<QuickSaleEntryScreen> {
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  String _paymentType = 'cash';

  @override
  void dispose() {
    _itemController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = BusinessRepository(widget.db);
    return Scaffold(
      appBar: AppBar(title: const Text('Record Sale')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _itemController, decoration: const InputDecoration(labelText: 'Item name')),
            TextField(controller: _qtyController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButton<String>(value: _paymentType, items: const [DropdownMenuItem(value: 'cash', child: Text('Cash')), DropdownMenuItem(value: 'upi', child: Text('UPI')), DropdownMenuItem(value: 'credit', child: Text('Credit'))], onChanged: (v) => setState(() => _paymentType = v!)),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final item = _itemController.text.trim();
                final qty = double.tryParse(_qtyController.text) ?? 1.0;
                if (item.isEmpty) return;
                await repo.recordSale(customerId: null, paymentType: _paymentType, lineItems: [
                  {'itemNameSnapshot': item, 'quantity': qty, 'unitPrice': 1.0}
                ], amountPaid: _paymentType == 'cash' ? qty * 1.0 : 0.0);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale Recorded')));
                Navigator.of(context).pop();
              },
              child: const Text('Record Sale'),
            )
          ],
        ),
      ),
    );
  }
}
