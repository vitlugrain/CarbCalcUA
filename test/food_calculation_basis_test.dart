import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';
import '../lib/models/quantity.dart';
import '../lib/services/food_calculation_service.dart';

void main() {
  test('solid product is calculated per 100 g', () {
    final p = Product(id: 'solid', name: 'Хліб', category: 'Хліб', carbs: 50);
    final r = FoodCalculationService.calculate(
      product: p,
      quantity: const Quantity(40, QuantityUnit.grams),
      xeGrams: 10,
    );
    expect(r, isNotNull);
    expect(r!.carbs, 20);
    expect(r.xe, 2);
  });

  test('liquid product is calculated from ml when basis is 100 ml', () {
    final p = Product(
      id: 'drink',
      name: 'Напій',
      category: 'Напої',
      carbs: 10.6,
      nutritionBasis: '100ml',
      gramsPerMl: 1.04,
      quantityUnits: const ['мл'],
    );
    final r = FoodCalculationService.calculate(
      product: p,
      quantity: const Quantity(250, QuantityUnit.milliliters),
      xeGrams: 10,
    );
    expect(r, isNotNull);
    expect(r!.carbs, closeTo(26.5, 0.001));
  });

  test('100 ml basis does not silently assume density for grams', () {
    final p = Product(
      id: 'drink',
      name: 'Напій',
      category: 'Напої',
      carbs: 10.6,
      nutritionBasis: '100ml',
      quantityUnits: const ['мл'],
    );
    final r = FoodCalculationService.calculate(
      product: p,
      quantity: const Quantity(100, QuantityUnit.grams),
      xeGrams: 10,
    );
    expect(r, isNull);
  });
}
