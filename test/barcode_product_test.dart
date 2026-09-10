import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';
import '../lib/services/barcode_service.dart';

void main() {
  test('legacy single barcode remains supported', () {
    final product = Product.fromJson({
      'id': 'legacy',
      'name': 'Pepsi',
      'category': 'Напої',
      'carbs': 10.6,
      'barcode': '4820000000001',
    });
    expect(product.allBarcodes, contains('4820000000001'));
    expect(BarcodeService.hasBarcode(product, '4820000000001'), isTrue);
  });

  test('one product can contain multiple package barcodes', () {
    final product = Product.fromJson({
      'id': 'pepsi',
      'name': 'Pepsi',
      'category': 'Напої',
      'carbs': 10.6,
      'barcode': '4820000000001',
      'barcodes': ['4820000000002', '4820000000003'],
    });
    expect(product.allBarcodes.length, 3);
    expect(BarcodeService.hasBarcode(product, '4820 0000 0000 3'), isTrue);
  });
}
