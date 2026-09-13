#!/usr/bin/env python3
from pathlib import Path

p = Path('lib/main.dart')
s = p.read_text(encoding='utf-8')

old_loader = """Future<List<Product>> loadProducts() async {\n  final raw=await rootBundle.loadString('assets/products.json');\n  final usdaRaw=await rootBundle.loadString('assets/usda_products.json');\n  final brandedRaw=await rootBundle.loadString('assets/ua_branded_products.json');\n  final local=(jsonDecode(raw) as List).map((e)=>Product.fromJson(e)).toList();\n  final branded=(jsonDecode(brandedRaw) as List).map((e)=>Product.fromJson(e)).toList();\n  final usda=(jsonDecode(usdaRaw) as List).map((e)=>Product.fromJson(e)).toList();\n  return [...local,...branded,...usda];\n}\nFuture<List<Product>> loadAllProducts() async {\n  final base = await loadProducts();\n  final customRows = await AppDb.customProducts();\n  final custom = customRows.map(Product.fromCustomDb).toList();\n  final byId = <String, Product>{for (final x in base) x.id: x};\n  for (final x in custom) { byId[x.id] = x; }\n  return byId.values.toList();\n}\n"""
new_loader = """Future<List<Product>>? _baseProductsFuture;\n\nFuture<List<Product>> _loadProductsOnce() async {\n  final values = await Future.wait([\n    rootBundle.loadString('assets/products.json'),\n    rootBundle.loadString('assets/usda_products.json'),\n    rootBundle.loadString('assets/ua_branded_products.json'),\n  ]);\n  final local=(jsonDecode(values[0]) as List).map((e)=>Product.fromJson(e)).toList(growable:false);\n  final usda=(jsonDecode(values[1]) as List).map((e)=>Product.fromJson(e)).toList(growable:false);\n  final branded=(jsonDecode(values[2]) as List).map((e)=>Product.fromJson(e)).toList(growable:false);\n  return List<Product>.unmodifiable([...local,...branded,...usda]);\n}\n\nFuture<List<Product>> loadProducts() => _baseProductsFuture ??= _loadProductsOnce();\n\nFuture<List<Product>> loadAllProducts() async {\n  final base = await loadProducts();\n  final customRows = await AppDb.customProducts();\n  if (customRows.isEmpty) return base;\n  final custom = customRows.map(Product.fromCustomDb);\n  final byId = <String, Product>{for (final x in base) x.id: x};\n  for (final x in custom) { byId[x.id] = x; }\n  return List<Product>.unmodifiable(byId.values);\n}\n"""
if old_loader not in s:
    raise SystemExit('Expected loader block not found; refusing unsafe patch')
s = s.replace(old_loader, new_loader, 1)

old_fields = """  final quantitySectionKey=GlobalKey();\n\n  @override void initState(){\n    super.initState();\n"""
new_fields = """  final quantitySectionKey=GlobalKey();\n  late Future<List<Product>> productsFuture;\n\n  @override void initState(){\n    super.initState();\n    productsFuture=loadAllProducts();\n"""
if old_fields not in s:
    raise SystemExit('Expected AddFood state field block not found; refusing unsafe patch')
s = s.replace(old_fields, new_fields, 1)

old_build = """  @override Widget build(BuildContext c)=>FutureBuilder<List<Product>>(future:loadAllProducts(),builder:(c,s){\n    if(!s.hasData)return const Center(child:CircularProgressIndicator());\n"""
new_build = """  @override Widget build(BuildContext c)=>FutureBuilder<List<Product>>(future:productsFuture,builder:(c,s){\n    if(s.hasError){\n      return Center(child:Padding(\n        padding:const EdgeInsets.all(24),\n        child:Column(mainAxisSize:MainAxisSize.min,children:[\n          const Icon(Icons.error_outline,size:48),\n          const SizedBox(height:12),\n          const Text('Не вдалося завантажити базу продуктів',textAlign:TextAlign.center,style:TextStyle(fontSize:18,fontWeight:FontWeight.w600)),\n          const SizedBox(height:8),\n          Text('${s.error}',textAlign:TextAlign.center),\n          const SizedBox(height:16),\n          FilledButton.icon(\n            onPressed:()=>setState(()=>productsFuture=loadAllProducts()),\n            icon:const Icon(Icons.refresh),\n            label:const Text('Спробувати ще раз'),\n          ),\n        ]),\n      ));\n    }\n    if(!s.hasData)return const Center(child:CircularProgressIndicator());\n"""
if old_build not in s:
    raise SystemExit('Expected AddFood FutureBuilder block not found; refusing unsafe patch')
s = s.replace(old_build, new_build, 1)

p.write_text(s, encoding='utf-8')
print('Applied runtime catalog cache and AddFood FutureBuilder performance fix')
