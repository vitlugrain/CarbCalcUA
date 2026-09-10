import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';
import '../lib/services/food_search_service.dart';

void main(){
  test('zero query does not promote unrelated zero carb foods',(){
    final products=[
      Product(id:'drink',name:'Pepsi Zero',category:'Напої',carbs:0),
      Product(id:'turkey',name:'Індичка, запечена',category:'Мʼясо',carbs:0),
    ];
    final r=FoodSearchService.search('Pepsi Zero',products);
    expect(r,isNotEmpty); expect(r.first.product.id,'drink'); expect(r.any((x)=>x.product.id=='turkey'),isFalse);
  });

  test('unrelated turkey is excluded from mushroom query',(){
    final products=[
      Product(id:'ua_core_mushroom',name:'Печериці, сирі',category:'Гриби',carbs:3.3,aliases:const ['гриб','гриби','печериці']),
      Product(id:'turkey',name:'Індичка, запечена',category:'Мʼясо',carbs:0),
    ];
    final r=FoodSearchService.search('гриб',products);
    expect(r.any((x)=>x.product.id=='ua_core_mushroom'),isTrue); expect(r.any((x)=>x.product.id=='turkey'),isFalse);
  });

  test('Ukrainian core ranks above raw USDA fallback',(){
    final products=[
      Product(id:'ua_core_apple',name:'Яблуко, свіже',category:'Фрукти',carbs:13.8,aliases:const ['яблуко']),
      Product(id:'usda_apple',name:'Apples, raw, with skin',category:'Fruits',carbs:13.8,source:'USDA SR Legacy'),
    ];
    final r=FoodSearchService.search('яблуко',products);
    expect(r.first.product.id,'ua_core_apple');
  });

  test('obvious Pepsi duplicates collapse',(){
    final products=[
      Product(id:'a',name:'Pepsi Zero',category:'Напої',carbs:0,manufacturer:'Pepsi'),
      Product(id:'b',name:'Пепсі Zero',category:'Напої',carbs:0,manufacturer:'Pepsi'),
    ];
    final r=FoodSearchService.search('Pepsi Zero',products);
    expect(r.length,1);
  });
}
