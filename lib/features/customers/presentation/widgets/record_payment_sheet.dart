import 'package:flutter/material.dart';
import 'package:mobo_app/core/database/app_database.dart';
import 'package:mobo_app/features/customers/data/customers_repository.dart';

class RecordPaymentSheet extends StatefulWidget {
  final AppDatabase db;
  final String customerId;
  final VoidCallback? onDone;
  const RecordPaymentSheet({super.key, required this.db, required this.customerId, this.onDone});

  @override
  State<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends State<RecordPaymentSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = CustomersRepository(widget.db);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
          TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Note (optional)')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () async {
              final amt = double.tryParse(_amountController.text) ?? 0.0;
              if (amt <= 0) return;
              setState(() => _isSubmitting = true);
              await repo.recordPayment(widget.customerId, amt, note: _noteController.text, createdBy: 'local_user');
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded')));
              widget.onDone?.call();
            },
            child: _isSubmitting ? const CircularProgressIndicator() : const Text('Save Payment'),
          ),
        ],
      ),
    );
  }
}
