import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'barcode_alias_store.dart';
import 'product_identity_service.dart';
typedef CustomProductLookup = Future<Map<String, dynamic>?> Function(String barcode);

class BarcodeService {
  static final http.Client _client = http.Client();

  static String normalize(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String decodeHtmlEntities(String value) {
    return value
        .replaceAll(RegExp(r'&quot;|&#34;|&#x22;', caseSensitive: false), '"')
        .replaceAll(RegExp(r'&amp;|&#38;|&#x26;', caseSensitive: false), '&')
        .replaceAll(RegExp(r'&apos;|&#39;|&#x27;', caseSensitive: false), "'")
        .replaceAll(RegExp(r'&lt;|&#60;|&#x3c;', caseSensitive: false), '<')
        .replaceAll(RegExp(r'&gt;|&#62;|&#x3e;', caseSensitive: false), '>')
        .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
        .trim();
  }

  static String? cleanName(dynamic value) {
    if (value == null) return null;
    final text = decodeHtmlEntities(value.toString()).trim();
    return text.isEmpty ? null : text;
  }

  static bool hasBarcode(Product product, String rawBarcode) {
    final wanted = normalize(rawBarcode);
    if (wanted.isEmpty) return false;
    return product.allBarcodes.any((code) => normalize(code) == wanted);
  }

  static Future<List<Product>> _loadBundledBarcodeProducts() async {
    final out = <Product>[];
    for (final asset in const [
      'assets/products.json',
      'assets/ua_branded_products.json',
    ]) {
      try {
        final raw = await rootBundle.loadString(asset);
        final rows = jsonDecode(raw);
        if (rows is List) {
          out.addAll(rows.whereType<Map>().map((e) => Product.fromJson(e.cast<String, dynamic>())));
        }
      } catch (_) {
        // A missing optional generated asset must not break barcode scanning.
      }
    }
    return out;
  }

  static Future<Product?> findLocal(String rawBarcode, {CustomProductLookup? customProductLookup}) async {
    final barcode = normalize(rawBarcode);
    if (barcode.isEmpty) return null;

    // First check package aliases learned from previous scans. This makes a
    // newly attached EAN survive app restarts and future APK updates.
    final aliased = await BarcodeAliasStore.find(barcode);
    if (aliased != null) return aliased;

    if (customProductLookup != null) {
      final custom = await customProductLookup(barcode);
      if (custom != null) return Product.fromCustomDb(custom);
    }
    final products = await _loadBundledBarcodeProducts();
    for (final product in products) {
      if (hasBarcode(product, barcode)) return product;
    }
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
    final name = _firstNonEmpty([cleanName(p['product_name_uk']),cleanName(p['product_name'])]);
    if (name == null) return null;
    final category = _firstNonEmpty([p['categories_tags'] is List ? cleanName((p['categories_tags'] as List).firstOrNull) : null]) ?? 'Зовнішні дані';
    final beverage = _isLikelyBeverage(name, category);
    return Product(
      id:'off_$barcode',
      name:name,
      category:category,
      carbs:_number(n['carbohydrates_100g']),
      protein:_number(n['proteins_100g']),
      fat:_number(n['fat_100g']),
      fiber:_number(n['fiber_100g']),
      calories:_number(n['energy-kcal_100g']),
      barcode:barcode,
      barcodes:[barcode],
      manufacturer:_firstNonEmpty([cleanName(p['brands'])]),
      source:'Open Food Facts',
      updatedAt:DateTime.now().toIso8601String(),
      nutritionBasis: beverage ? '100ml' : '100g',
      quantityUnits: beverage ? const ['ml'] : const ['g'],
    );
  }

  static Future<Product?> find(String barcode, {CustomProductLookup? customProductLookup}) async {
    final local = await findLocal(barcode, customProductLookup: customProductLookup);
    if (local != null) return local;

    final external = await findExternal(barcode);
    if (external == null) return null;

    // If Open Food Facts returned another package size of a product already in
    // the bundled catalog, reuse the canonical record and persist the new EAN.
    final candidates = await _loadBundledBarcodeProducts();
    final analogue = ProductIdentityService.findAnalogue(external, candidates);
    if (analogue != null) {
      final merged = ProductIdentityService.mergeBarcode(analogue, barcode);
      await BarcodeAliasStore.save(merged);
      return merged;
    }
    return external;
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
      final name=_firstNonEmpty([cleanName(p['product_name_uk']),cleanName(p['product_name'])]); if(name==null)continue;
      final carbs=_number(n['carbohydrates_100g']);
      final code=_firstNonEmpty([cleanName(p['code'])]);
      final category=_firstNonEmpty([p['categories_tags'] is List ? cleanName((p['categories_tags'] as List).firstOrNull) : null])??'Онлайн-база';
      final beverage=_isLikelyBeverage(name,category);
      out.add(Product(
        id:'off_${p['code']??name.hashCode}',
        name:name,
        category:category,
        carbs:carbs,
        protein:_number(n['proteins_100g']),
        fat:_number(n['fat_100g']),
        fiber:_number(n['fiber_100g']),
        calories:_number(n['energy-kcal_100g']),
        barcode:code,
        barcodes:code == null ? const [] : [code],
        manufacturer:_firstNonEmpty([cleanName(p['brands'])]),
        source:'Open Food Facts',
        updatedAt:DateTime.now().toIso8601String(),
        nutritionBasis: beverage ? '100ml' : '100g',
        quantityUnits: beverage ? const ['ml'] : const ['g'],
      ));
    }
    return out;
  }

  static bool _isLikelyBeverage(String name, String category) {
    final text='${name.toLowerCase()} ${category.toLowerCase()}';
    return RegExp(r'напій|напиток|beverage|drink|cola|coca|pepsi|сік|juice|water|вода|лимонад|lemonade|квас').hasMatch(text);
  }

  static double _number(dynamic value) { if (value is num) return value.toDouble(); return double.tryParse('$value'.replaceAll(',', '.')) ?? 0; }
  static String? _firstNonEmpty(Iterable<dynamic> values) { for (final value in values) { if (value == null) continue; final text=value.toString().trim(); if(text.isNotEmpty)return text; } return null; }
}

extension<T> on List<T> { T? get firstOrNull => isEmpty ? null : first; }
