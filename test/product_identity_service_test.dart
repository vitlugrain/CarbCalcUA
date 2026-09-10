import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';
import '../lib/services/product_identity_service.dart';

void main() {
  Product p({
    required String id,
    required String name,
    double carbs = 0,
    double calories = 0,
    String? brand,
    String? barcode,
    List<String> barcodes = const [],
  }) => Product(
        id: id,
        name: name,
        category: 'Напої',
        carbs: carbs,
        calories: calories,
        manufacturer: brand,
        barcode: barcode,
        barcodes: barcodes,
        nutritionBasis: '100ml',
        quantityUnits: const ['ml'],
      );

  test('Pepsi and Пепсі with same nutrients are analogues', () {
    final a = p(id: 'a', name: 'Pepsi Zero', brand: 'Pepsi', carbs: 0, calories: 0);
    final b = p(id: 'b', name: 'Пепсі Zero', brand: 'Pepsi', carbs: 0, calories: 0);
    expect(ProductIdentityService.isLikelySameProduct(a, b), isTrue);
  });

  test('regular and zero drink are never silently merged', () {
    final regular = p(id: 'a', name: 'Pepsi', brand: 'Pepsi', carbs: 10.6, calories: 42);
    final zero = p(id: 'b', name: 'Pepsi Zero', brand: 'Pepsi', carbs: 0, calories: 0);
    expect(ProductIdentityService.isLikelySameProduct(regular, zero), isFalse);
  });

  test('different brands are not analogues', () {
    final a = p(id: 'a', name: 'Cola Zero', brand: 'Pepsi', carbs: 0);
    final b = p(id: 'b', name: 'Cola Zero', brand: 'Coca-Cola', carbs: 0);
    expect(ProductIdentityService.isLikelySameProduct(a, b), isFalse);
  });

  test('new package barcode is appended without losing old codes', () {
    final existing = p(
      id: 'a',
      name: 'Pepsi Zero',
      brand: 'Pepsi',
      barcode: '1111111111111',
      barcodes: const ['1111111111111', '2222222222222'],
    );
    final merged = ProductIdentityService.mergeBarcode(existing, '3333333333333');
    expect(merged.allBarcodes.toSet(), {
      '1111111111111',
      '2222222222222',
      '3333333333333',
    });
    expect(merged.nutritionBasis, '100ml');
    expect(merged.quantityUnits, const ['ml']);
  });

  test('findAnalogue selects Ukrainian/English equivalent', () {
    final scanned = p(id: 'scan', name: 'Pepsi Zero Sugar', brand: 'Pepsi', carbs: 0, calories: 0);
    final candidates = [
      p(id: 'apple', name: 'Яблуко', brand: null, carbs: 13.8, calories: 52),
      p(id: 'pepsi', name: 'Пепсі Zero Sugar', brand: 'Pepsi', carbs: 0, calories: 0),
    ];
    expect(ProductIdentityService.findAnalogue(scanned, candidates)?.id, 'pepsi');
  });
}
