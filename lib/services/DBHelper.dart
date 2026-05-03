import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import 'package:postman/models/Cart.dart';

class DBHelper {
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'cart.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart(
        id        INTEGER PRIMARY KEY,
        nama_barang TEXT,
        deskripsi   TEXT,
        harga       INTEGER,
        image       TEXT,
        quantity    INTEGER
      )
    ''');
  }

  // ─── INSERT ───────────────────────────────────────────────
  Future<Cart> insert(Cart cart) async {
    final dbClient = await database;
    await dbClient!.insert(
      'cart',
      cart.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return cart;
  }

  // ─── GET ALL CART ─────────────────────────────────────────
  Future<List<Cart>> getCartList() async {
    try {
      final dbClient = await database;
      final List<Map<String, Object?>> queryResult =
          await dbClient!.query('cart');
      return queryResult.map((result) => Cart.fromMap(result)).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── GET CART BY ID ───────────────────────────────────────
  Future<List<Cart>> getCartListDetail(int id) async {
    try {
      final dbClient = await database;
      final queryResult = await dbClient!.query(
        'cart',
        where: 'id = ?',
        whereArgs: [id],
      );
      return queryResult.map((result) => Cart.fromMap(result)).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── UPDATE QUANTITY ──────────────────────────────────────
  Future<int> updateQuantity(int id, int qty) async {
    final dbClient = await database;
    return await dbClient!.update(
      'cart',
      {"quantity": qty},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // ─── DELETE ───────────────────────────────────────────────
  Future<int> delete(int id) async {
    final dbClient = await database;
    return await dbClient!.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── DELETE ALL ✅ ─────────────────────────────────────────
  Future<void> deleteAll() async {
    final dbClient = await database;
    await dbClient!.delete('cart');
  }
}