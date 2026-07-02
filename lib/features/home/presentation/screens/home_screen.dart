import 'package:flutter/material.dart';
import '../../domain/entities/home_summary.dart';
import '../widgets/home_content.dart';

class HomeScreen extends StatelessWidget {
  final dynamic db;
  const HomeScreen({super.key, this.db});

  @override
  Widget build(BuildContext context) {
    // placeholder summary
    final summary = HomeSummary(
      todaySales: 0.0,
      totalReceivables: 0.0,
      lowStockCount: 0,
      asOf: DateTime.now(),
      isStale: false,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('MOBO')),
        body: HomeContent(summary: summary, db: db),
      ),
    );
  }
}
