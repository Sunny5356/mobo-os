class HomeSummary {
  final double todaySales;
  final double totalReceivables;
  final int lowStockCount;
  final DateTime asOf;
  final bool isStale;

  const HomeSummary({
    required this.todaySales,
    required this.totalReceivables,
    required this.lowStockCount,
    required this.asOf,
    required this.isStale,
  });
}
