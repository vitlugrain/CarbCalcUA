import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';
import '../lib/services/food_search_service.dart';

void main() {
  final products = <Product>[
    Product(id: 'dry', name: 'Гречка, суха', category: 'Крупи', carbs: 71.5, state: 'raw'),
    Product(id: 'cooked', name: 'Гречка, варена', category: 'Крупи', carbs: 19.9, state: 'cooked'),
    Product(id: 'water', name: 'Гречка варена на воді', category: 'Крупи', carbs: 19.9, state: 'cooked'),
    Product(id: 'milk', name: 'Гречка варена на молоці', category: 'Крупи', carbs: 13.5, state: 'cooked'),
    Product(id: 'cookie', name: 'Печиво Марія', category: 'Печиво', carbs: 74, gramsPerPiece: 7),
  ];

  test('parses Ukrainian quantity and unit', () {
    final q = FoodSearchService.parseQuery('150 г гречки вареної на воді');
    expect(q.amount, 150);
    expect(q.unit, ParsedQuantityUnit.grams);
    expect(q.productQuery, 'гречки вареної на воді');
  });

  test('parses quantity at the end', () {
    final q = FoodSearchService.parseQuery('печива Марія 2 шт');
    expect(q.amount, 2);
    expect(q.unit, ParsedQuantityUnit.pieces);
    expect(q.productQuery, 'печива Марія');
  });

  test('bare buckwheat returns several relevant variants', () {
    final r = FoodSearchService.search('гречка', products);
    expect(r.length, greaterThanOrEqualTo(3));
    expect(r.any((x) => x.product.id == 'dry'), isTrue);
    expect(r.any((x) => x.product.id == 'cooked'), isTrue);
  });

  test('water buckwheat ranks above milk and dry buckwheat', () {
    final r = FoodSearchService.search('гречка варена на воді', products);
    expect(r.first.product.id, 'water');
  });

  test('morphology finds Maria cookie', () {
    final r = FoodSearchService.search('2 шт печива Марія', products);
    expect(r.first.product.id, 'cookie');
  });
}
