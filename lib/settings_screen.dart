import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'product_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  // Delete a product from database
  Future<void> _deleteProduct(int index) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'products',
      where: 'name = ?',
      whereArgs: [_products[index].name],
    );
    setState(() {
      _products.removeAt(index);
    });
  }

  // Show edit dialog for a product
  void _editProduct(int index) {
    final product = _products[index];
    final purchaseController =
        TextEditingController(text: product.purchasePrice.toString());
    final sellingController =
        TextEditingController(text: product.sellingPrice.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          product.name,
          style: const TextStyle(
            color: Color(0xFF1B4332),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: purchaseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Purchase Price (₹)',
                labelStyle: TextStyle(color: Color(0xFF1B4332)),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(0xFF1B4332), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCED4DA)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sellingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Selling Price (₹)',
                labelStyle: TextStyle(color: Color(0xFF1B4332)),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(0xFF1B4332), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCED4DA)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = await DatabaseHelper.instance.database;
              await db.update(
                'products',
                {
                  'purchase_price':
                      double.tryParse(purchaseController.text) ??
                          product.purchasePrice,
                  'selling_price':
                      double.tryParse(sellingController.text) ??
                          product.sellingPrice,
                },
                where: 'name = ?',
                whereArgs: [product.name],
              );
              if (!mounted) return;
              Navigator.pop(context);
              _loadProducts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4332),
            ),
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add new product dialog
  void _addNewProduct() {
    final nameController = TextEditingController();
    final unitController = TextEditingController();
    final purchaseController = TextEditingController();
    final sellingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Product',
          style: TextStyle(
            color: Color(0xFF1B4332),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameController, 'Product Name', 'e.g. Sesame Oil'),
              const SizedBox(height: 12),
              _dialogField(unitController, 'Unit Type', 'e.g. Litre'),
              const SizedBox(height: 12),
              _dialogField(purchaseController, 'Purchase Price (₹)', 'e.g. 140',
                  isNumber: true),
              const SizedBox(height: 12),
              _dialogField(sellingController, 'Selling Price (₹)', 'e.g. 195',
                  isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  unitController.text.isEmpty ||
                  purchaseController.text.isEmpty ||
                  sellingController.text.isEmpty) return;

              final newProduct = Product(
                name: nameController.text,
                unit: unitController.text,
                purchasePrice:
                    double.tryParse(purchaseController.text) ?? 0,
                sellingPrice:
                    double.tryParse(sellingController.text) ?? 0,
              );

              await DatabaseHelper.instance.insertProduct(newProduct);
              if (!mounted) return;
              Navigator.pop(context);
              _loadProducts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4332),
            ),
            child: const Text('Add',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  TextField _dialogField(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProduct,
        backgroundColor: const Color(0xFF1B4332),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B4332),
              ),
            )
          : _products.isEmpty
              ? const Center(
                  child: Text(
                    'No products found.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.oil_barrel,
                            color: Color(0xFF1B4332)),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                        subtitle: Text(
                          '${p.unit}  |  Buy: ₹${p.purchasePrice}  |  Sell: ₹${p.sellingPrice}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Color(0xFF52B788)),
                              onPressed: () => _editProduct(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () => _deleteProduct(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}