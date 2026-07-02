import 'package:flutter/material.dart';
import '../../domain/entities/home_summary.dart';
import '../../../../app/theme/mobo_colors.dart';
import 'package:mobo_app/features/business/presentation/screens/quick_sale_entry_screen.dart';
import 'package:mobo_app/features/insights/presentation/screens/insights_screen.dart';

class HomeContent extends StatelessWidget {
  final HomeSummary summary;
  final dynamic db;
  const HomeContent({super.key, required this.summary, this.db});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MoboColors>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (summary.isStale)
          Container(
            padding: const EdgeInsets.all(8),
            color: colors.gold.withOpacity(0.12),
            child: const Text('Updating...'),
          ),
        Card(
          child: ListTile(
            title: const Text("Today's Sales"),
            trailing: Text('₹${summary.todaySales.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Pending Udhaar to Collect'),
                trailing: Text('₹${summary.totalReceivables.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CustomerDirectoryScreen(db: db))),
              ),
            ),
        if (summary.lowStockCount > 0) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Low Stock Items'),
              trailing: Text('${summary.lowStockCount}'),
            ),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuickSaleEntryScreen(db: db)));
          },
          style: ElevatedButton.styleFrom(backgroundColor: colors.action),
          child: const Text('Record Sale'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InsightsScreen())), child: const Text('Insights')),
      ],
    );
  }
}
