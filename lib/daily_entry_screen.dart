import 'package:flutter/material.dart';
import 'product_setup_screen.dart';
import 'monthly_summary_screen.dart';
import 'settings_screen.dart';

class DailyEntryScreen extends StatefulWidget {
  final List<Product> products;

  const DailyEntryScreen({super.key, required this.products});

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  final _cashController = TextEditingController();
  final _expensesController = TextEditingController();
  final Map<String, TextEditingController> _restockControllers = {};

  double _restockCost = 0;
  double _profit = 0;
  bool _calculated = false;

  @override
  void initState() {
    super.initState();
    for (var product in widget.products) {
      _restockControllers[product.name] = TextEditingController();
    }
  }

  void _calculate() {
    double cash = double.tryParse(_cashController.text) ?? 0;
    double expenses = double.tryParse(_expensesController.text) ?? 0;

    double totalRestockCost = 0;
    for (var product in widget.products) {
      double units =
          double.tryParse(_restockControllers[product.name]!.text) ?? 0;
      totalRestockCost += units * product.purchasePrice;
    }

    setState(() {
      _restockCost = totalRestockCost;
      _profit = cash - expenses - totalRestockCost;
      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateString = '${today.day} / ${today.month} / ${today.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          'Daily Entry',
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
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MonthlySummaryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              label: Text(
                dateString,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _sectionTitle('Units Restocked Today'),
            const SizedBox(height: 10),

            ...widget.products.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${product.name}\n(${product.unit})',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1B4332),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _restockControllers[product.name],
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Units'),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            _sectionTitle('Cash & Expenses'),
            const SizedBox(height: 10),
            TextField(
              controller: _cashController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Total Cash Received (₹)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _expensesController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Total Expenses (₹)'),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52B788),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Calculate Today\'s Profit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_calculated)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF52B788), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    const Divider(),
                    _resultRow(
                        'Cash Received',
                        '₹${double.tryParse(_cashController.text) ?? 0}',
                        Colors.black87),
                    _resultRow(
                        'Restock Cost', '- ₹$_restockCost', Colors.orange),
                    _resultRow(
                        'Expenses',
                        '- ₹${double.tryParse(_expensesController.text) ?? 0}',
                        Colors.redAccent),
                    const Divider(),
                    _resultRow(
                      'Net Profit',
                      '₹$_profit',
                      _profit >= 0
                          ? const Color(0xFF1B4332)
                          : Colors.redAccent,
                      bold: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B4332),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF1B4332)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1B4332), width: 2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFCED4DA)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _resultRow(String label, String value, Color valueColor,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  color: valueColor,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}