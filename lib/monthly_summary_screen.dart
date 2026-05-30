import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'chart_screen.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  DateTime _selectedMonth = DateTime.now();

  Map<String, double> _summary = {
    'cash': 0,
    'expenses': 0,
    'restock_cost': 0,
    'profit': 0,
  };

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);

    final monthStr =
        '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

    final summary = await DatabaseHelper.instance.getMonthlySummary(monthStr);

    setState(() {
      _summary = summary;
      _loading = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
    _loadSummary();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
    _loadSummary();
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isProfit = _summary['profit']! >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          'Monthly Summary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChartScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.show_chart,
              color: Colors.white,
            ),
          ),
        ],
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
                children: [

                  // ── Month Navigator ─────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCED4DA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(Icons.chevron_left,
                              color: Color(0xFF1B4332)),
                        ),
                        Text(
                          '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(Icons.chevron_right,
                              color: Color(0xFF1B4332)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Profit Card ─────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? const Color(0xFF1B4332)
                          : Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isProfit ? 'Good Month' : 'Loss Month',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_summary['profit']!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Net Profit',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Breakdown Cards ─────────────────────
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _summaryCard(
                          'Cash Received',
                          '₹${_summary['cash']!.toStringAsFixed(2)}',
                          Icons.payments_outlined,
                          const Color(0xFF52B788),
                        ),
                        _summaryCard(
                          'Restock Cost',
                          '₹${_summary['restock_cost']!.toStringAsFixed(2)}',
                          Icons.inventory_2_outlined,
                          const Color(0xFFF4A261),
                        ),
                        _summaryCard(
                          'Expenses',
                          '₹${_summary['expenses']!.toStringAsFixed(2)}',
                          Icons.receipt_long_outlined,
                          Colors.redAccent,
                        ),
                        _summaryCard(
                          'Days Recorded',
                          _getDaysRecorded().toString(),
                          Icons.calendar_month_outlined,
                          const Color(0xFF1B4332),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  int _getDaysRecorded() {
    if (_summary['cash'] == 0 &&
        _summary['expenses'] == 0 &&
        _summary['restock_cost'] == 0) {
      return 0;
    }
    return 1;
  }

  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCED4DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}