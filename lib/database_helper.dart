import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product_setup_screen.dart';

// DatabaseHelper is a singleton
// Singleton means only ONE instance of this class
// exists in the entire app at any time
// Like having one single ledger book — not multiple copies
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // This is our gateway to the database
  // If database exists return it
  // If not create it first then return it
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nature_touch.db');
    return _database!;
  }

  // Create the database file on the device
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create our two tables
  // This runs only once — when app is installed for first time
  Future _createDB(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        purchase_price REAL NOT NULL,
        selling_price REAL NOT NULL
      )
    ''');

    // Daily entries table
    await db.execute('''
      CREATE TABLE daily_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        units_restocked REAL NOT NULL,
        cash_received REAL NOT NULL,
        expenses REAL NOT NULL,
        restock_cost REAL NOT NULL,
        profit REAL NOT NULL
      )
    ''');
  }

  // ── Product Operations ────────────────────────────────

  // Save a product to database
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', {
      'name': product.name,
      'unit': product.unit,
      'purchase_price': product.purchasePrice,
      'selling_price': product.sellingPrice,
    });
  }

  // Get all products from database
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');

    return maps.map((map) => Product(
      name: map['name'] as String,
      unit: map['unit'] as String,
      purchasePrice: map['purchase_price'] as double,
      sellingPrice: map['selling_price'] as double,
    )).toList();
  }

  // Check if products exist already
  // Used to decide whether to show onboarding or home screen
  Future<bool> hasProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.isNotEmpty;
  }

  // ── Daily Entry Operations ────────────────────────────

  // Save a daily entry
  Future<int> insertDailyEntry({
    required String date,
    required int productId,
    required double unitsRestocked,
    required double cashReceived,
    required double expenses,
    required double restockCost,
    required double profit,
  }) async {
    final db = await database;
    return await db.insert('daily_entries', {
      'date': date,
      'product_id': productId,
      'units_restocked': unitsRestocked,
      'cash_received': cashReceived,
      'expenses': expenses,
      'restock_cost': restockCost,
      'profit': profit,
    });
  }

  // Get all entries for a specific month
  // Month format: 2026-05
  Future<List<Map<String, dynamic>>> getMonthlyEntries(String month) async {
    final db = await database;
    return await db.query(
      'daily_entries',
      where: "date LIKE ?",
      whereArgs: ['$month%'],
    );
  }

  // Get monthly summary — total revenue, expenses, profit
  Future<Map<String, double>> getMonthlySummary(String month) async {
    final entries = await getMonthlyEntries(month);

    double totalCash = 0;
    double totalExpenses = 0;
    double totalRestockCost = 0;
    double totalProfit = 0;

    for (var entry in entries) {
      totalCash += entry['cash_received'] as double;
      totalExpenses += entry['expenses'] as double;
      totalRestockCost += entry['restock_cost'] as double;
      totalProfit += entry['profit'] as double;
    }

    return {
      'cash': totalCash,
      'expenses': totalExpenses,
      'restock_cost': totalRestockCost,
      'profit': totalProfit,
    };
  }

  // Close database connection
  Future close() async {
    final db = await database;
    db.close();
  }
}