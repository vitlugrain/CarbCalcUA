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
    expect(r!.grams, 40);
    expect(r.nutritionAmount, 40);
    expect(r.nutritionUnit, QuantityUnit.grams);
    expect(r.carbs, 20);
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
    expect(r!.grams, closeTo(260, 0.001));
    expect(r.nutritionAmount, 250);
    expect(r.nutritionUnit, QuantityUnit.milliliters);
    expect(r.carbs, closeTo(26.5, 0.001));
  });

  test('100 ml basis works directly from ml even without density', () {
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
      quantity: const Quantity(250, QuantityUnit.milliliters),
      xeGrams: 10,
    );
    expect(r, isNotNull);
    expect(r!.grams, isNull);
    expect(r.nutritionAmount, 250);
    expect(r.nutritionUnit, QuantityUnit.milliliters);
    expect(r.carbs, closeTo(26.5, 0.001));
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
  test('fixed-weight product converts pieces to grams for carb calculation', () {
    final p = Product(
      id: 'cookie',
      name: 'Печиво Марія',
      category: 'Печиво',
      carbs: 70,
      gramsPerPiece: 7,
      quantityUnits: const ['г', 'шт'],
    );
    final r = FoodCalculationService.calculate(
      product: p,
      quantity: const Quantity(2, QuantityUnit.pieces),
      xeGrams: 10,
    );
    expect(r, isNotNull);
    expect(r!.grams, 14);
    expect(r.nutritionAmount, 14);
    expect(r.nutritionUnit, QuantityUnit.grams);
    expect(r.carbs, closeTo(9.8, 0.001));
    expect(r.xe, closeTo(0.98, 0.001));
  });

  test('pieces cannot be calculated without a piece weight', () {
    final p = Product(
      id: 'produce',
      name: 'Помідор',
      category: 'Овочі',
      carbs: 4,
      quantityUnits: const ['г'],
    );
    final r = FoodCalculationService.calculate(
      product: p,
      quantity: const Quantity(1, QuantityUnit.pieces),
      xeGrams: 10,
    );
    expect(r, isNull);
  });

}
