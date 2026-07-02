import 'package:flutter/material.dart';
import 'package:mobo_app/features/insights/data/insights_repository.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _repo = InsightsRepository();
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _repo.fetchSummary();
      setState(() { _summary = s; _loading = false; });
    } catch (e) {
      // fallback to empty
      setState(() { _summary = null; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: _summary == null
                  ? const Center(child: Text('No data'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(child: ListTile(title: const Text("Today's Sales"), trailing: Text('₹${_summary!['today_sales'] ?? 0}'))),
                        const SizedBox(height: 12),
                        Card(child: ListTile(title: const Text('Total Receivables'), trailing: Text('₹${_summary!['total_receivables'] ?? 0}'))),
                        const SizedBox(height: 24),
                        const Text('Sales Trend'),
                        SizedBox(height: 200, child: _buildChart(_summary!)),
                      ],
                    ),
            ),
    );
  }

  Widget _buildChart(Map<String, dynamic> data) {
    // Placeholder: draw sample line with 7 points
    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), (i + 1) * 10.0));
    return LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: spots, isCurved: true)]));
  }
}
