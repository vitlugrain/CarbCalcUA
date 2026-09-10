from pathlib import Path

path = Path('lib/main.dart')
text = path.read_text(encoding='utf-8')


def replace_once(old: str, new: str):
    global text
    if old not in text:
        raise SystemExit(f'Marker not found:\n{old[:180]}')
    text = text.replace(old, new, 1)

replace_once(
    "import 'services/food_calculation_service.dart';\n",
    "import 'services/food_calculation_service.dart';\nimport 'services/product_unit_service.dart';\n",
)

replace_once("openDatabase(path,version:6", "openDatabase(path,version:7")
replace_once(
    "serving_grams REAL)');",
    "serving_grams REAL,barcodes TEXT,nutrition_basis TEXT,quantity_units TEXT)');",
)
replace_once(
    "      if(oldV<6){\n        await d.execute('ALTER TABLE diary ADD COLUMN meal_group_id TEXT');\n        await d.execute('ALTER TABLE diary ADD COLUMN meal_time TEXT');\n        await d.execute('ALTER TABLE diary ADD COLUMN product_id TEXT');\n        await d.execute('CREATE TABLE IF NOT EXISTS glucose(id INTEGER PRIMARY KEY AUTOINCREMENT,timestamp TEXT NOT NULL,value_mmol REAL NOT NULL,source TEXT,original_unit TEXT)');\n      }\n",
    "      if(oldV<6){\n        await d.execute('ALTER TABLE diary ADD COLUMN meal_group_id TEXT');\n        await d.execute('ALTER TABLE diary ADD COLUMN meal_time TEXT');\n        await d.execute('ALTER TABLE diary ADD COLUMN product_id TEXT');\n        await d.execute('CREATE TABLE IF NOT EXISTS glucose(id INTEGER PRIMARY KEY AUTOINCREMENT,timestamp TEXT NOT NULL,value_mmol REAL NOT NULL,source TEXT,original_unit TEXT)');\n      }\n      if(oldV<7){\n        await d.execute('ALTER TABLE custom_products ADD COLUMN barcodes TEXT');\n        await d.execute('ALTER TABLE custom_products ADD COLUMN nutrition_basis TEXT');\n        await d.execute('ALTER TABLE custom_products ADD COLUMN quantity_units TEXT');\n      }\n",
)

replace_once(
    "  static Future<Map<String,dynamic>?> customProductByBarcode(String barcode) async {\n    final rows=await (await db).query('custom_products',where:'barcode=?',whereArgs:[barcode],limit:1);\n    return rows.isEmpty?null:rows.first;\n  }",
    "  static Future<Map<String,dynamic>?> customProductByBarcode(String barcode) async {\n    final d=await db;\n    final rows=await d.query('custom_products',where:'barcode=?',whereArgs:[barcode],limit:1);\n    if(rows.isNotEmpty)return rows.first;\n    final all=await d.query('custom_products',where:'barcodes IS NOT NULL');\n    for(final row in all){\n      final codes='${row['barcodes'] ?? ''}'.split(',').map((x)=>x.trim());\n      if(codes.contains(barcode))return row;\n    }\n    return null;\n  }",
)
replace_once(
    "'grams_per_piece':x.gramsPerPiece,'grams_per_ml':x.gramsPerMl,'serving_grams':x.servingGrams},",
    "'grams_per_piece':x.gramsPerPiece,'grams_per_ml':x.gramsPerMl,'serving_grams':x.servingGrams,'barcodes':x.allBarcodes.join(','),'nutrition_basis':x.nutritionBasis,'quantity_units':x.quantityUnits.join(',')},",
)

replace_once(
    "  List<QuantityUnit> _unitsFor(Product p){\n    final units=<QuantityUnit>[QuantityUnit.grams];\n    if(p.gramsPerMl!=null) units.add(QuantityUnit.milliliters);\n    if(p.gramsPerPiece!=null) units.add(QuantityUnit.pieces);\n    if(p.servingGrams!=null) units.add(QuantityUnit.portion);\n    return units;\n  }",
    "  List<QuantityUnit> _unitsFor(Product p)=>ProductUnitService.unitsFor(p);\n\n  double _defaultAmount(QuantityUnit u)=>\n      (u==QuantityUnit.grams || u==QuantityUnit.milliliters)?100:1;",
)
replace_once(
    "    else nextUnit=QuantityUnit.grams;\n    final nextAmount=parsed.amount ?? (nextUnit==QuantityUnit.grams?100:1);",
    "    else nextUnit=units.first;\n    final nextAmount=parsed.amount ?? _defaultAmount(nextUnit);",
)
replace_once(
    "        amount = verifiedUnit == QuantityUnit.grams ? 100 : 1;",
    "        amount = _defaultAmount(verifiedUnit);",
)
replace_once(
    "    final grams=selected==null?null:_toGrams(selected!);\n    final carbs=selected==null||grams==null?0.0:(grams*selected!.carbs/100).toDouble();",
    "    final preview=selected==null?null:FoodCalculationService.calculate(product:selected!,quantity:Quantity(amount,unit),xeGrams:10);\n    final grams=preview?.grams;\n    final carbs=preview?.carbs??0.0;",
)
replace_once(
    "subtitle:Text('${p.carbs.toStringAsFixed(1)} г вуглеводів / 100 г${p.manufacturer==null?'':' • ${p.manufacturer}'}'),",
    "subtitle:Text('${p.carbs.toStringAsFixed(1)} г вуглеводів / ${ProductUnitService.nutritionBasisLabel(p)}${p.manufacturer==null?'':' • ${p.manufacturer}'}'),",
)
replace_once(
    "onChanged:(u){if(u==null)return;setState((){unit=u;amount=u==QuantityUnit.grams?100:1;controller.text=amount.toString();});}",
    "onChanged:(u){if(u==null)return;setState((){unit=u;amount=_defaultAmount(u);controller.text=amount.toString();});}",
)
replace_once(
    "        if(grams==null)const Text('Для цієї одиниці немає даних для перерахунку. Оберіть грами або додайте вагу/обʼєм одиниці до даних продукту.',style:TextStyle(color:Colors.orange)),",
    "        if(preview==null)const Text('Для цієї одиниці немає достатніх даних для коректного розрахунку. Оберіть доступну одиницю або додайте потрібну вагу/щільність.',style:TextStyle(color:Colors.orange)),",
)
replace_once(
    "        FilledButton(onPressed:amount>0&&grams!=null?()async{",
    "        FilledButton(onPressed:amount>0&&preview!=null?()async{",
)
replace_once(
    "          await AppDb.addDiary(date:_dateKey(mealDate),meal:meal,name:selected!.name,grams:grams!,amountValue:amount,amountUnit:unit.label,carbs:carbs,xe:_xeForCarbs(carbs,xeGrams),mealGroupId:groupId,mealTime:effectiveMealTime,productId:selected!.id);",
    "          final finalResult=FoodCalculationService.calculate(product:selected!,quantity:Quantity(amount,unit),xeGrams:xeGrams);\n          if(finalResult==null)return;\n          await AppDb.addDiary(date:_dateKey(mealDate),meal:meal,name:selected!.name,grams:finalResult.grams??0,amountValue:amount,amountUnit:unit.label,carbs:finalResult.carbs,xe:finalResult.xe,mealGroupId:groupId,mealTime:effectiveMealTime,productId:selected!.id);",
)

replace_once(
    "    final grams = FoodCalculationService.toGrams(product, Quantity(value, unit));\n    if (grams == null) return;\n\n    final carbs = grams * product.carbs / 100;\n    final prefs = await SharedPreferences.getInstance();\n    final xeGrams = prefs.getDouble('xe_grams') ?? 10;",
    "    final prefs = await SharedPreferences.getInstance();\n    final xeGrams = prefs.getDouble('xe_grams') ?? 10;\n    final result = FoodCalculationService.calculate(product: product, quantity: Quantity(value, unit), xeGrams: xeGrams);\n    if (result == null) return;",
)
replace_once(
    "      grams: grams,\n      amountValue: value,\n      amountUnit: unit.label,\n      carbs: carbs,\n      xe: _xeForCarbs(carbs, xeGrams),",
    "      grams: result.grams ?? 0,\n      amountValue: value,\n      amountUnit: unit.label,\n      carbs: result.carbs,\n      xe: result.xe,",
)

# User-facing custom product list respects 100g/100ml metadata.
replace_once(
    "subtitle:Text('${product.carbs.toStringAsFixed(1)} г вуглеводів / 100 г${product.barcode==null?'':' • ${product.barcode}'}'),",
    "subtitle:Text('${product.carbs.toStringAsFixed(1)} г вуглеводів / ${ProductUnitService.nutritionBasisLabel(product)}${product.barcode==null?'':' • ${product.barcode}'}'),",
)

path.write_text(text, encoding='utf-8')
print('Applied nutrition basis + unit UI integration')
