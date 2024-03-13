import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'cart_database.db';
  static const _databaseVersion = 1;

  static const tableCartProducts = 'cartproducts';
  static const columnProductId = 'productid';
  static const columnProductName = 'productname';
  static const columnPrice = 'price';
  static const columnImageUrl = 'imageurl';
  static const columnCount = 'count';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCartProducts (
        $columnProductId INTEGER PRIMARY KEY,
        $columnProductName TEXT NOT NULL,
        $columnPrice REAL NOT NULL,
        $columnImageUrl TEXT NOT NULL,
        $columnCount INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertProduct(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableCartProducts, row);
  }

  Future<List<Map<String, dynamic>>> queryAllProducts() async {
    Database db = await instance.database;
    return await db.query(tableCartProducts);
  }

  Future<int> updateProductCount(int productId, int newCount) async {
    Database db = await instance.database;
    return await db.update(
      tableCartProducts,
      {columnCount: newCount},
      where: '$columnProductId = ?',
      whereArgs: [productId],
    );
  }
  Future<void> removeProductFromCart(int productId) async {
    Database db = await instance.database;
    await db.delete(
      tableCartProducts,
      where: '$columnProductId = ?',
      whereArgs: [productId],
    );
  }
  Future<bool> isProductInCart(int productId) async {
    List<Map<String, dynamic>> product = await queryProduct(productId);
    return product.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> queryProduct(int productId) async {
    Database db = await instance.database;
    return await db.query(tableCartProducts, where: '$columnProductId = ?', whereArgs: [productId]);
  }
}