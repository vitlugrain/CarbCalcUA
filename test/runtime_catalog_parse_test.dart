import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';

void main() {
  const runtimeCatalogs = <String>[
    'assets/products.json',
    'assets/ua_branded_products.json',
    'assets/usda_products.json',
  ];

  for (final path in runtimeCatalogs) {
    test('runtime catalog parses completely: $path', () {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'Missing runtime catalog: $path');

      final decoded = jsonDecode(file.readAsStringSync());
      expect(decoded, isA<List<dynamic>>(), reason: '$path must contain a JSON list');

      final rows = decoded as List<dynamic>;
      for (var i = 0; i < rows.length; i++) {
        final raw = rows[i];
        expect(raw, isA<Map<String, dynamic>>(), reason: '$path row $i is not an object');
        try {
          Product.fromJson(raw as Map<String, dynamic>);
        } catch (e) {
          fail('Failed to parse $path row $i (id=${raw['id']} name=${raw['name']}): $e');
        }
      }
    });
  }
}
