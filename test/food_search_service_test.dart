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

  test('Ukrainian alias finds USDA English product', () {
    final usda = [
      Product(
        id: 'usda-rice',
        name: 'Rice, white, cooked',
        category: 'Cereal Grains and Pasta',
        carbs: 28,
        source: 'USDA SR Legacy',
      ),
    ];
    final r = FoodSearchService.search('рис', usda);
    expect(r, isNotEmpty);
    expect(r.first.product.id, 'usda-rice');
  });

  test('Ukrainian cooking state boosts cooked USDA result', () {
    final usda = [
      Product(
        id: 'usda-rice-raw',
        name: 'Rice, white, long-grain, raw',
        category: 'Cereal Grains and Pasta',
        carbs: 80,
        source: 'USDA SR Legacy',
      ),
      Product(
        id: 'usda-rice-cooked',
        name: 'Rice, white, long-grain, cooked',
        category: 'Cereal Grains and Pasta',
        carbs: 28,
        source: 'USDA SR Legacy',
      ),
    ];
    final r = FoodSearchService.search('рис варений', usda);
    expect(r, isNotEmpty);
    expect(r.first.product.id, 'usda-rice-cooked');
  });

  test('cheese query is not confused with raw-state adjective', () {
    final usda = [
      Product(
        id: 'usda-cheese',
        name: 'Cheese, cheddar',
        category: 'Dairy and Egg Products',
        carbs: 1.3,
        source: 'USDA SR Legacy',
      ),
    ];
    final r = FoodSearchService.search('сир', usda);
    expect(r, isNotEmpty);
    expect(r.first.product.id, 'usda-cheese');
  });

  test('searches local aliases', () {
    final local = [
      Product(
        id: 'ua-chicken',
        name: 'Куряче філе, сире',
        category: 'М\'ясо та птиця',
        carbs: 0,
        aliases: const ['курка', 'курятина', 'куряча грудка'],
      ),
    ];
    final r = FoodSearchService.search('курка', local);
    expect(r, isNotEmpty);
    expect(r.first.product.id, 'ua-chicken');
  });

  test('searches branded products by manufacturer', () {
    final branded = [
      Product(
        id: 'off-veres',
        name: 'Зелений горошок',
        category: 'Овочеві консерви',
        carbs: 6.5,
        manufacturer: 'Верес',
        source: 'Open Food Facts (ODbL)',
      ),
    ];
    final r = FoodSearchService.search('верес', branded);
    expect(r, isNotEmpty);
    expect(r.first.product.id, 'off-veres');
  });

  test('partial Ukrainian spaghetti query finds local spaghetti', () {
    final local = [
      Product(
        id: 'ua-spaghetti',
        name: 'Спагетті, варені',
        category: 'Макарони',
        carbs: 30.9,
        aliases: const ['спагетті', 'паста спагетті'],
      ),
    ];
    final r = FoodSearchService.search('спаге', local);
    expect(r, isNotEmpty);
    expect(r.first.product.id, 'ua-spaghetti');
  });

  test('base potato query includes fried potato variant', () {
    final local = [
      Product(id: 'raw-potato', name: 'Картопля, сира', category: 'Овочі', carbs: 17, state: 'raw'),
      Product(id: 'fried-potato', name: 'Картопля смажена', category: 'Страви з картоплі', carbs: 23.4, state: 'prepared'),
      Product(id: 'boiled-potato', name: 'Картопля відварена', category: 'Страви з картоплі', carbs: 17.6, state: 'cooked'),
    ];
    final r = FoodSearchService.search('картопля', local);
    expect(r.any((x) => x.product.id == 'raw-potato'), isTrue);
    expect(r.any((x) => x.product.id == 'fried-potato'), isTrue);
    expect(r.any((x) => x.product.id == 'boiled-potato'), isTrue);
  });

  test('common Ukrainian base food names find their variants', () {
    final local = [
      Product(id: 'carrot', name: 'Морква, сира', category: 'Овочі', carbs: 9.6),
      Product(id: 'onion', name: 'Цибуля ріпчаста, сира', category: 'Овочі', carbs: 9.3),
      Product(id: 'cabbage', name: 'Капуста білокачанна, сира', category: 'Овочі', carbs: 5.8),
      Product(id: 'eggplant', name: 'Баклажан, запечений', category: 'Овочі', carbs: 8.7),
      Product(id: 'cucumber', name: 'Огірок сирий зі шкіркою', category: 'Овочі', carbs: 3.6),
      Product(id: 'tomato', name: 'Помідор сирий', category: 'Овочі', carbs: 3.9),
      Product(id: 'beet', name: 'Буряк, варений', category: 'Овочі', carbs: 10),
      Product(id: 'zucchini', name: 'Кабачок, сирий', category: 'Овочі', carbs: 3.1),
      Product(id: 'pumpkin', name: 'Гарбуз, запечений', category: 'Овочі', carbs: 10.5),
    ];
    for (final q in ['морква','цибуля','капуста','баклажан','огірок','помідор','буряк','кабачок','гарбуз']) {
      final r = FoodSearchService.search(q, local);
      expect(r, isNotEmpty, reason: 'Base query should work: $q');
    }
  });

}
