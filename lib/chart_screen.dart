import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  // Last 6 months data
  List<Map<String, dynamic>> _chartData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  // Load last 6 months summary from database
  Future<void> _loadChartData() async {
    setState(() => _loading = true);

    List<Map<String, dynamic>> data = [];
    final now = DateTime.now();

    // Loop through last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthStr =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final summary =
          await DatabaseHelper.instance.getMonthlySummary(monthStr);

      data.add({
        'month': _shortMonth(month.month),
        'cash': summary['cash']!,
        'expenses': summary['expenses']! + summary['restock_cost']!,
        'profit': summary['profit']!,
      });
    }

    setState(() {
      _chartData = data;
      _loading = false;
    });
  }

  // Short month name
  String _shortMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          'Revenue vs Expenses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B4332),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Legend ──────────────────────────────
                  Row(
                    children: [
                      _legendDot(const Color(0xFF52B788), 'Revenue'),
                      const SizedBox(width: 20),
                      _legendDot(const Color(0xFFF4A261), 'Expenses'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Bar Chart ───────────────────────────
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) =>
                                const Color(0xFF1B4332),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '₹${rod.toY.toStringAsFixed(0)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '₹${value.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= _chartData.length) {
                                  return const Text('');
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _chartData[index]['month'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1B4332),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: const Color(0xFFCED4DA),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _chartData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              // Revenue bar
                              BarChartRodData(
                                toY: data['cash'],
                                color: const Color(0xFF52B788),
                                width: 16,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                              // Expenses bar
                              BarChartRodData(
                                toY: data['expenses'],
                                color: const Color(0xFFF4A261),
                                width: 16,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Monthly Profit List ─────────────────
                  const Text(
                    'Monthly Profit Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      itemCount: _chartData.length,
                      itemBuilder: (context, index) {
                        final data = _chartData[index];
                        final isProfit = data['profit'] >= 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['month'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₹${data['profit'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isProfit
                                      ? const Color(0xFF1B4332)
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Get max Y value for chart scaling
  double _getMaxY() {
    double max = 100;
    for (var data in _chartData) {
      if (data['cash'] > max) max = data['cash'];
      if (data['expenses'] > max) max = data['expenses'];
    }
    return max * 1.2;
  }

  // Legend dot widget
  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}