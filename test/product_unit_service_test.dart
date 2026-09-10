import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';
import '../lib/models/quantity.dart';
import '../lib/services/product_unit_service.dart';

void main() {
  test('100ml beverage without density still offers milliliters', () {
    final p = Product(
      id: 'drink',
      name: 'Pepsi',
      category: 'Напої',
      carbs: 10.6,
      nutritionBasis: '100ml',
      quantityUnits: const ['мл'],
    );
    expect(ProductUnitService.unitsFor(p), [QuantityUnit.milliliters]);
    expect(ProductUnitService.nutritionBasisLabel(p), '100 мл');
  });

  test('thick yogurt can be explicitly grams only', () {
    final p = Product(
      id: 'yogurt',
      name: 'Йогурт густий',
      category: 'Молочні продукти',
      carbs: 6,
      quantityUnits: const ['г'],
    );
    expect(ProductUnitService.unitsFor(p), [QuantityUnit.grams]);
  });

  test('legacy egg keeps grams and pieces', () {
    final p = Product(
      id: 'egg',
      name: 'Яйце',
      category: 'Яйця',
      carbs: 1,
      gramsPerPiece: 50,
    );
    expect(
      ProductUnitService.unitsFor(p),
      [QuantityUnit.grams, QuantityUnit.pieces],
    );
  });

  test('explicit unit metadata wins over legacy density hints', () {
    final p = Product(
      id: 'yogurt',
      name: 'Йогурт',
      category: 'Молочні продукти',
      carbs: 6,
      gramsPerMl: 1.03,
      quantityUnits: const ['г'],
    );
    expect(ProductUnitService.unitsFor(p), [QuantityUnit.grams]);
  });
}
