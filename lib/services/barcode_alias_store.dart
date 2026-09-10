import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';

/// Persists extra package barcodes independently from the legacy
/// `custom_products.barcode` column. This lets one logical product keep several
/// EAN/UPC codes without changing existing user data or diary records.
class BarcodeAliasStore {
  static const _table = 'product_barcode_aliases';

  static Future<Database> _database() async {
    final path = p.join(await getDatabasesPath(), 'carbcalc_ua.db');
    final db = await openDatabase(path);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_table(
        barcode TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        product_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    return db;
  }

  static String normalizeBarcode(String value) =>
      value.replaceAll(RegExp(r'\D'), '');

  static Future<Product?> find(String rawBarcode) async {
    final barcode = normalizeBarcode(rawBarcode);
    if (barcode.isEmpty) return null;
    final db = await _database();
    final rows = await db.query(
      _table,
      columns: const ['product_json'],
      where: 'barcode=?',
      whereArgs: [barcode],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      final map = jsonDecode(rows.first['product_json'] as String);
      if (map is Map<String, dynamic>) return Product.fromJson(map);
      if (map is Map) return Product.fromJson(map.cast<String, dynamic>());
    } catch (_) {}
    return null;
  }

  /// Saves a snapshot for every barcode known for [product]. Existing aliases
  /// are replaced atomically, so rescanning a new package updates the same
  /// logical product rather than creating a duplicate record.
  static Future<void> save(Product product) async {
    final codes = product.allBarcodes
        .map(normalizeBarcode)
        .where((x) => x.isNotEmpty)
        .toSet();
    if (codes.isEmpty) return;

    final db = await _database();
    final payload = jsonEncode(_toJson(product));
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      for (final barcode in codes) {
        await txn.insert(
          _table,
          {
            'barcode': barcode,
            'product_id': product.id,
            'product_json': payload,
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Map<String, dynamic> _toJson(Product x) => {
        'id': x.id,
        'name': x.name,
        'category': x.category,
        'state': x.state,
        'carbs': x.carbs,
        'protein': x.protein,
        'fat': x.fat,
        'fiber': x.fiber,
        'calories': x.calories,
        'barcode': x.barcode,
        'barcodes': x.allBarcodes,
        'manufacturer': x.manufacturer,
        'source': x.source,
        'updatedAt': x.updatedAt,
        'gramsPerPiece': x.gramsPerPiece,
        'gramsPerMl': x.gramsPerMl,
        'servingGrams': x.servingGrams,
        'aliases': x.aliases,
        'nutritionBasis': x.nutritionBasis,
        'quantityUnits': x.quantityUnits,
      };
}
