import 'package:flutter/material.dart';
import 'daily_entry_screen.dart';
import 'database_helper.dart';
class Product {
  String name;
  String unit;
  double purchasePrice;
  double sellingPrice;

  Product({
    required this.name,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
  });
}

class ProductSetupScreen extends StatefulWidget {
  const ProductSetupScreen({super.key});

  @override
  State<ProductSetupScreen> createState() => _ProductSetupScreenState();
}

class _ProductSetupScreenState extends State<ProductSetupScreen> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  final List<Product> _products = [];

  void _addProduct() {
    if (_nameController.text.isEmpty ||
        _unitController.text.isEmpty ||
        _purchasePriceController.text.isEmpty ||
        _sellingPriceController.text.isEmpty) {
      return;
    }

    setState(() {
      _products.add(Product(
        name: _nameController.text,
        unit: _unitController.text,
        purchasePrice: double.parse(_purchasePriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
      ));
    });

    _nameController.clear();
    _unitController.clear();
    _purchasePriceController.clear();
    _sellingPriceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          'Setup Your Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Product Name', 'e.g. Groundnut Oil'),
            const SizedBox(height: 10),
            _buildTextField(_unitController, 'Unit Type', 'e.g. Litre / 500ml / Kg'),
            const SizedBox(height: 10),
            _buildTextField(_purchasePriceController, 'Purchase Price (₹)', 'e.g. 140',
                isNumber: true),
            const SizedBox(height: 10),
            _buildTextField(_sellingPriceController, 'Selling Price (₹)', 'e.g. 195',
                isNumber: true),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Product',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52B788),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _products.isEmpty
                  ? const Center(
                      child: Text(
                        'No products added yet.\nAdd at least one to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.oil_barrel,
                                color: Color(0xFF1B4332)),
                            title: Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${p.unit}  |  Buy: ₹${p.purchasePrice}  |  Sell: ₹${p.sellingPrice}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _products.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (_products.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    for (var product in _products) {
                      await DatabaseHelper.instance.insertProduct(product);
                    }
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DailyEntryScreen(products: _products),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue →',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF1B4332)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1B4332), width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCED4DA)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}