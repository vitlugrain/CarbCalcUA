import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
typedef CustomProductLookup = Future<Map<String, dynamic>?> Function(String barcode);

class BarcodeService {
  static final http.Client _client = http.Client();

  static String normalize(String value) => value.replaceAll(RegExp(r'\D'), '');

  static Future<Product?> findLocal(String rawBarcode, {CustomProductLookup? customProductLookup}) async {
    final barcode = normalize(rawBarcode);
    if (barcode.isEmpty) return null;
    if (customProductLookup != null) {
      final custom = await customProductLookup(barcode);
      if (custom != null) return Product.fromCustomDb(custom);
    }
    final raw = await rootBundle.loadString('assets/products.json');
    final products = (jsonDecode(raw) as List).map((e) => Product.fromJson(e as Map<String, dynamic>));
    for (final product in products) { if (product.barcode == barcode) return product; }
    return null;
  }

  static Future<Product?> findExternal(String rawBarcode) async {
    final barcode = normalize(rawBarcode);
    if (barcode.isEmpty) return null;
    final uri = Uri.https('world.openfoodfacts.org','/api/v2/product/$barcode',{'fields':'code,product_name,product_name_uk,brands,categories_tags,nutriments'});
    final response = await _client.get(uri, headers:{'User-Agent':'CarbCalcUA/0.6 (mobile app)'}).timeout(const Duration(seconds:8));
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 1 || data['product'] is! Map) return null;
    final p = data['product'] as Map<String, dynamic>;
    final n = p['nutriments'] is Map ? p['nutriments'] as Map<String, dynamic> : <String, dynamic>{};
    final name = _firstNonEmpty([p['product_name_uk'],p['product_name']]);
    if (name == null) return null;
    return Product(id:'off_$barcode',name:name,category:_firstNonEmpty([p['categories_tags'] is List ? (p['categories_tags'] as List).firstOrNull : null]) ?? 'Зовнішні дані',carbs:_number(n['carbohydrates_100g']),protein:_number(n['proteins_100g']),fat:_number(n['fat_100g']),fiber:_number(n['fiber_100g']),calories:_number(n['energy-kcal_100g']),barcode:barcode,manufacturer:_firstNonEmpty([p['brands']]),source:'Open Food Facts',updatedAt:DateTime.now().toIso8601String());
  }

  static Future<Product?> find(String barcode, {CustomProductLookup? customProductLookup}) async {
    final local = await findLocal(barcode, customProductLookup: customProductLookup);
    if (local != null) return local;
    return findExternal(barcode);
  }

  static Future<List<Product>> searchExternalByName(String query, {int pageSize=8}) async {
    final q=query.trim(); if(q.isEmpty)return [];
    final uri=Uri.https('world.openfoodfacts.org','/api/v2/search',{'search_terms':q,'page_size':'$pageSize','fields':'code,product_name,product_name_uk,brands,categories_tags,nutriments','lc':'uk','cc':'ua'});
    final response=await _client.get(uri,headers:{'User-Agent':'CarbCalcUA/0.6 (mobile app)'}).timeout(const Duration(seconds:8));
    if(response.statusCode!=200)return [];
    final data=jsonDecode(response.body) as Map<String,dynamic>; final products=data['products']; if(products is! List)return [];
    final out=<Product>[];
    for(final item in products){
      if(item is! Map) continue;
      final p=item.cast<String,dynamic>(); final n=p['nutriments'] is Map ? (p['nutriments'] as Map).cast<String,dynamic>() : <String,dynamic>{};
      final name=_firstNonEmpty([p['product_name_uk'],p['product_name']]); if(name==null)continue;
      final carbs=_number(n['carbohydrates_100g']); if(carbs<=0)continue;
      out.add(Product(id:'off_${p['code']??name.hashCode}',name:name,category:_firstNonEmpty([p['categories_tags'] is List ? (p['categories_tags'] as List).firstOrNull : null])??'Онлайн-база',carbs:carbs,protein:_number(n['proteins_100g']),fat:_number(n['fat_100g']),fiber:_number(n['fiber_100g']),calories:_number(n['energy-kcal_100g']),barcode:_firstNonEmpty([p['code']]),manufacturer:_firstNonEmpty([p['brands']]),source:'Open Food Facts',updatedAt:DateTime.now().toIso8601String()));
    }
    return out;
  }

  static double _number(dynamic value) { if (value is num) return value.toDouble(); return double.tryParse('$value'.replaceAll(',', '.')) ?? 0; }
  static String? _firstNonEmpty(Iterable<dynamic> values) { for (final value in values) { if (value == null) continue; final text=value.toString().trim(); if(text.isNotEmpty)return text; } return null; }
}

extension<T> on List<T> { T? get firstOrNull => isEmpty ? null : first; }
