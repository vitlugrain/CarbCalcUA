import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';
import '../lib/models/quantity.dart';
import '../lib/services/food_search_service.dart';
import '../lib/services/food_calculation_service.dart';

void main() {
  final products = <Product>[
    Product(id: 'dry', name: 'Гречка, суха', category: 'Крупи', carbs: 71.5, state: 'raw'),
    Product(id: 'water', name: 'Гречка варена на воді', category: 'Крупи', carbs: 19.9, state: 'cooked'),
    Product(id: 'milk', name: 'Гречка варена на молоці', category: 'Крупи', carbs: 13.5, state: 'cooked'),
    Product(id: 'cookie', name: 'Печиво Марія', category: 'Печиво', carbs: 74, gramsPerPiece: 7),
    Product(id: 'yogurt', name: 'Йогурт натуральний', category: 'Молочні продукти', carbs: 5, gramsPerMl: 1.03),
  ];

  test('parses amount and unit from natural Ukrainian input', () {
    final q = FoodSearchService.parseQuery('150 г гречки вареної на воді');
    expect(q.amount, 150);
    expect(q.unit, ParsedQuantityUnit.grams);
    expect(q.productQuery, 'гречки вареної на воді');
  });

  test('parses pieces at the end of input', () {
    final q = FoodSearchService.parseQuery('печива Марія 2 шт');
    expect(q.amount, 2);
    expect(q.unit, ParsedQuantityUnit.pieces);
    expect(q.productQuery, 'печива Марія');
  });

  test('bare product name returns alternatives instead of guessing', () {
    final r = FoodSearchService.search('гречка', products);
    expect(r.length, greaterThanOrEqualTo(2));
    expect(r.any((x) => x.product.id == 'dry'), isTrue);
    expect(r.any((x) => x.product.id == 'water'), isTrue);
    expect(r.any((x) => x.product.id == 'milk'), isTrue);
  });

  test('specific cooking context ranks water buckwheat first', () {
    final r = FoodSearchService.search('гречка варена на воді', products);
    expect(r.first.product.id, 'water');
  });

  test('morphology finds Maria cookie and supports pieces', () {
    final r = FoodSearchService.search('2 шт печива Марія', products);
    expect(r.first.product.id, 'cookie');
    final grams = 2 * products.lastWhere((x) => x.id == 'cookie').gramsPerPiece!;
    expect(grams, 14);
  });

  test('milliliters use product-specific grams-per-ml conversion', () {
    final yogurt = products.last;
    const amountMl = 150.0;
    final grams = amountMl * yogurt.gramsPerMl!;
    final carbs = grams * yogurt.carbs / 100;
    expect(grams, closeTo(154.5, 0.0001));
    expect(carbs, closeTo(7.725, 0.0001));
  });

  test('quantity units have Ukrainian labels', () {
    expect(Quantity(150, QuantityUnit.grams).display, '150 г');
    expect(Quantity(150, QuantityUnit.milliliters).display, '150 мл');
    expect(Quantity(2, QuantityUnit.pieces).display, '2 шт');
    expect(Quantity(1, QuantityUnit.portion).display, '1 порція');
  });

  test('calculation uses the selected unit and configurable XE value', () {
    final cookie = products.firstWhere((x) => x.id == 'cookie');
    final result = FoodCalculationService.calculate(
      product: cookie,
      quantity: const Quantity(2, QuantityUnit.pieces),
      xeGrams: 12,
    );
    expect(result, isNotNull);
    expect(result!.grams, closeTo(14, 0.0001));
    expect(result.carbs, closeTo(10.36, 0.0001));
    expect(result.xe, closeTo(10.36 / 12, 0.0001));
  });

  test('calculation returns null when conversion data is unavailable', () {
    final product = products.firstWhere((x) => x.id == 'dry');
    final result = FoodCalculationService.calculate(
      product: product,
      quantity: const Quantity(2, QuantityUnit.pieces),
      xeGrams: 10,
    );
    expect(result, isNull);
  });
}
