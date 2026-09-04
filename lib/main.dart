import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'services/glucose_import_service.dart';
import 'models/product.dart';
import 'models/quantity.dart';
import 'services/food_search_service.dart';
import 'services/food_calculation_service.dart';
double _xeForCarbs(double carbs, double xeGrams) => xeGrams > 0 ? carbs / xeGrams : 0;

class FoodItem {
  final Product product;
  final double grams;
  FoodItem(this.product,this.grams);
  double get carbs=>grams*product.carbs/100;
}

Future<List<Product>> loadProducts() async {
  final raw=await rootBundle.loadString('assets/products.json');
  final usdaRaw=await rootBundle.loadString('assets/usda_products.json');
  final local=(jsonDecode(raw) as List).map((e)=>Product.fromJson(e)).toList();
  final usda=(jsonDecode(usdaRaw) as List).map((e)=>Product.fromJson(e)).toList();
  return [...local,...usda];
}
Future<List<Product>> loadAllProducts() async {
  final base = await loadProducts();
  final customRows = await AppDb.customProducts();
  final custom = customRows.map(Product.fromCustomDb).toList();
  final byId = <String, Product>{for (final x in base) x.id: x};
  for (final x in custom) { byId[x.id] = x; }
  return byId.values.toList();
}

class AppDb {
  static Database? _db;
  static Future<Database> get db async {
    if(_db!=null)return _db!;
    final path=p.join(await getDatabasesPath(),'carbcalc_ua.db');
    _db=await openDatabase(path,version:6,onCreate:(d,v)async{
      await d.execute('CREATE TABLE recipes(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,finished_weight REAL NOT NULL)');
      await d.execute('CREATE TABLE recipe_ingredients(id INTEGER PRIMARY KEY AUTOINCREMENT,recipe_id INTEGER NOT NULL,product_id TEXT NOT NULL,grams REAL NOT NULL)');
      await d.execute("CREATE TABLE diary(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT NOT NULL,meal TEXT NOT NULL,name TEXT NOT NULL,grams REAL NOT NULL,amount_value REAL NOT NULL DEFAULT 0,amount_unit TEXT NOT NULL DEFAULT 'г',carbs REAL NOT NULL,xe REAL NOT NULL,meal_group_id TEXT,meal_time TEXT,product_id TEXT)");
      await d.execute('CREATE TABLE glucose(id INTEGER PRIMARY KEY AUTOINCREMENT,timestamp TEXT NOT NULL,value_mmol REAL NOT NULL,source TEXT,original_unit TEXT)');
      await d.execute('CREATE TABLE custom_products(id TEXT PRIMARY KEY,name TEXT NOT NULL,category TEXT NOT NULL,carbs REAL NOT NULL,protein REAL NOT NULL,fat REAL NOT NULL,fiber REAL NOT NULL,calories REAL NOT NULL,barcode TEXT,manufacturer TEXT,source TEXT,updated_at TEXT,grams_per_piece REAL,grams_per_ml REAL,serving_grams REAL)');
    },onUpgrade:(d,oldV,newV)async{
      if(oldV<2){
        await d.execute('CREATE TABLE IF NOT EXISTS diary(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT NOT NULL,meal TEXT NOT NULL,name TEXT NOT NULL,grams REAL NOT NULL,carbs REAL NOT NULL,xe REAL NOT NULL)');
        await d.execute('CREATE TABLE IF NOT EXISTS custom_products(id TEXT PRIMARY KEY,name TEXT NOT NULL,category TEXT NOT NULL,carbs REAL NOT NULL,protein REAL NOT NULL,fat REAL NOT NULL,fiber REAL NOT NULL,calories REAL NOT NULL)');
      }
      if(oldV<3){
        await d.execute('ALTER TABLE custom_products ADD COLUMN barcode TEXT');
        await d.execute('ALTER TABLE custom_products ADD COLUMN manufacturer TEXT');
        await d.execute('ALTER TABLE custom_products ADD COLUMN source TEXT');
        await d.execute('ALTER TABLE custom_products ADD COLUMN updated_at TEXT');
      }
      if(oldV<4){
        await d.execute('ALTER TABLE diary ADD COLUMN amount_value REAL NOT NULL DEFAULT 0');
        await d.execute("ALTER TABLE diary ADD COLUMN amount_unit TEXT NOT NULL DEFAULT 'г'");
      }
      if(oldV<5){
        await d.execute('ALTER TABLE custom_products ADD COLUMN grams_per_piece REAL');
        await d.execute('ALTER TABLE custom_products ADD COLUMN grams_per_ml REAL');
        await d.execute('ALTER TABLE custom_products ADD COLUMN serving_grams REAL');
      }
      if(oldV<6){
        await d.execute('ALTER TABLE diary ADD COLUMN meal_group_id TEXT');
        await d.execute('ALTER TABLE diary ADD COLUMN meal_time TEXT');
        await d.execute('ALTER TABLE diary ADD COLUMN product_id TEXT');
        await d.execute('CREATE TABLE IF NOT EXISTS glucose(id INTEGER PRIMARY KEY AUTOINCREMENT,timestamp TEXT NOT NULL,value_mmol REAL NOT NULL,source TEXT,original_unit TEXT)');
      }
    });
    return _db!;
  }
  static Future<List<Map<String,dynamic>>> diary(String date) async=>(await db).query('diary',where:'date=?',whereArgs:[date],orderBy:'id ASC');
  static Future<List<Map<String,dynamic>>> mealGroups(String date) async {
    final rows = await diary(date);
    final groups = <String, Map<String,dynamic>>{};
    for (final row in rows) {
      final id = (row['meal_group_id'] as String?) ?? 'legacy_${row['meal']}_${row['meal_time'] ?? ''}';
      groups.putIfAbsent(id, () => {'id': id, 'meal': row['meal'], 'time': row['meal_time'] ?? ''});
    }
    return groups.values.toList();
  }
  static Future<void> addDiary({required String date,required String meal,required String name,required double grams,required double amountValue,required String amountUnit,required double carbs,required double xe,String? mealGroupId,String? mealTime,String? productId})async{
    await (await db).insert('diary',{'date':date,'meal':meal,'name':name,'grams':grams,'amount_value':amountValue,'amount_unit':amountUnit,'carbs':carbs,'xe':xe,'meal_group_id':mealGroupId,'meal_time':mealTime,'product_id':productId});
  }
  static Future<void> updateDiary({required int id,required double grams,required double amountValue,required String amountUnit,required double carbs,required double xe})async=> (await db).update('diary',{'grams':grams,'amount_value':amountValue,'amount_unit':amountUnit,'carbs':carbs,'xe':xe},where:'id=?',whereArgs:[id]);
  static Future<void> deleteDiary(int id)async=> (await db).delete('diary',where:'id=?',whereArgs:[id]);
  static Future<List<Map<String,dynamic>>> glucose()async=>(await db).query('glucose',orderBy:'timestamp ASC');
  static Future<int> countGlucoseDuplicates(List<GlucoseReading> rs)async{final rows=await glucose();return rs.where((r)=>rows.any((x)=>x['timestamp']==r.timestamp.toIso8601String()&&((x['value_mmol'] as num).toDouble()-r.valueMmol).abs()<0.01)).length;}
  static Future<List<GlucoseReading>> onlyNewGlucose(List<GlucoseReading> rs)async{final rows=await glucose();return rs.where((r)=>!rows.any((x)=>x['timestamp']==r.timestamp.toIso8601String()&&((x['value_mmol'] as num).toDouble()-r.valueMmol).abs()<0.01)).toList();}
  static Future<void> insertGlucoseBatch(List<GlucoseReading> rs)async{final d=await db;await d.transaction((t)async{for(final r in rs){await t.insert('glucose',{'timestamp':r.timestamp.toIso8601String(),'value_mmol':r.valueMmol,'source':r.source,'original_unit':r.originalUnit});}});}
  static Future<List<Map<String,dynamic>>> recipes()async=>(await db).query('recipes',orderBy:'id DESC');
  static Future<int> saveRecipe(String name,double weight,List<FoodItem> items)async{
    final d=await db;
    return d.transaction((t)async{
      final id=await t.insert('recipes',{'name':name,'finished_weight':weight});
      for(final i in items){await t.insert('recipe_ingredients',{'recipe_id':id,'product_id':i.product.id,'grams':i.grams});}
      return id;
    });
  }
  static Future<void> deleteRecipe(int id)async{
    final d=await db;
    await d.transaction((t)async{
      await t.delete('recipe_ingredients',where:'recipe_id=?',whereArgs:[id]);
      await t.delete('recipes',where:'id=?',whereArgs:[id]);
    });
  }
  static Future<List<Map<String,dynamic>>> customProducts()async=>(await db).query('custom_products',orderBy:'name');
  static Future<Map<String,dynamic>?> customProductByBarcode(String barcode) async {
    final rows=await (await db).query('custom_products',where:'barcode=?',whereArgs:[barcode],limit:1);
    return rows.isEmpty?null:rows.first;
  }
  static Future<void> saveCustomProduct(Product x)async=> (await db).insert('custom_products',{
    'id':x.id,'name':x.name,'category':x.category,'carbs':x.carbs,'protein':x.protein,'fat':x.fat,'fiber':x.fiber,'calories':x.calories,'barcode':x.barcode,'manufacturer':x.manufacturer,'source':x.source,'updated_at':x.updatedAt,'grams_per_piece':x.gramsPerPiece,'grams_per_ml':x.gramsPerMl,'serving_grams':x.servingGrams},
    conflictAlgorithm:ConflictAlgorithm.replace);
  static Future<void> deleteCustomProduct(String id)async=>(await db).delete('custom_products',where:'id=?',whereArgs:[id]);
  static Future<Product?> customProductById(String id) async {
    final rows=await (await db).query('custom_products',where:'id=?',whereArgs:[id],limit:1);
    return rows.isEmpty ? null : Product.fromCustomDb(rows.first);
  }
}

void main()=>runApp(const CarbCalcApp());

class CarbCalcApp extends StatelessWidget{
  const CarbCalcApp({super.key});
  @override Widget build(BuildContext c)=>MaterialApp(
    title:'CarbCalc UA',debugShowCheckedModeBanner:false,
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    supportedLocales: const [Locale('uk'), Locale('en')],
    theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.teal,scaffoldBackgroundColor:const Color(0xFFF7F9F8)),
    home:const HomePage());
}

class HomePage extends StatefulWidget{const HomePage({super.key});@override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{
  int tab=0;
  void refresh()=>setState((){});
  @override Widget build(BuildContext c){
    final pages=[
      Dashboard(onNavigate:(i)=>setState(()=>tab=i)),
      AddFoodPage(onAdded:refresh),
      RecipesPage(onAdded:refresh),
      DiaryPage(onChanged:refresh),
      SettingsPage(onChanged:refresh),
    ];
    return Scaffold(body:SafeArea(child:pages[tab]),bottomNavigationBar:NavigationBar(
      selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),
      destinations:const[
        NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Головна'),
        NavigationDestination(icon:Icon(Icons.add_circle_outline),selectedIcon:Icon(Icons.add_circle),label:'Додати'),
        NavigationDestination(icon:Icon(Icons.restaurant_outlined),selectedIcon:Icon(Icons.restaurant),label:'Страви'),
        NavigationDestination(icon:Icon(Icons.calendar_month_outlined),selectedIcon:Icon(Icons.calendar_month),label:'Щоденник'),
        NavigationDestination(icon:Icon(Icons.settings_outlined),selectedIcon:Icon(Icons.settings),label:'Налаштування'),
      ]));
  }
}

class Dashboard extends StatelessWidget{
  final void Function(int) onNavigate;
  const Dashboard({super.key,required this.onNavigate});
  @override Widget build(BuildContext c)=>FutureBuilder<List<Map<String,dynamic>>>(
    future:AppDb.diary(_dateKey(DateTime.now())),builder:(c,s){
      final rows=s.data??[];
      final carbs=rows.fold<double>(0,(a,x)=>a+(x['carbs'] as num).toDouble());
      final xe=rows.fold<double>(0,(a,x)=>a+(x['xe'] as num).toDouble());
      return ListView(padding:const EdgeInsets.all(20),children:[
        const Text('CarbCalc UA',style:TextStyle(fontSize:30,fontWeight:FontWeight.bold)),
        const SizedBox(height:6),const Text('Щоденний контроль харчових вуглеводів'),
        const SizedBox(height:20),
        Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Сьогодні',style:TextStyle(fontSize:18,fontWeight:FontWeight.w600)),
          const SizedBox(height:8),Text('${carbs.toStringAsFixed(1)} г',style:const TextStyle(fontSize:36,fontWeight:FontWeight.bold)),
          Text('${xe.toStringAsFixed(2)} ХО'),
          const SizedBox(height:10),Text('${rows.length} записів'),
        ]))),
        const SizedBox(height:12),
        FilledButton.icon(onPressed:()=>onNavigate(1),icon:const Icon(Icons.add),label:const Padding(padding:EdgeInsets.all(12),child:Text('Додати їжу'))),
        OutlinedButton.icon(onPressed:()=>onNavigate(3),icon:const Icon(Icons.calendar_month),label:const Text('Відкрити щоденник')),
        OutlinedButton.icon(onPressed:()=>onNavigate(2),icon:const Icon(Icons.restaurant),label:const Text('Мої страви')),
        const SizedBox(height:20),
        const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Дані призначені для розрахунку харчових вуглеводів. Застосунок не визначає дозу інсуліну та не замінює рекомендації лікаря.'))),
      ]);
    });
}

class AddFoodPage extends StatefulWidget{
  final VoidCallback onAdded;
  const AddFoodPage({super.key,required this.onAdded});
  @override State<AddFoodPage> createState()=>_AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage>{
  Product? selected;
  double amount=100;
  QuantityUnit unit=QuantityUnit.grams;
  String q='';
  String meal='Сніданок';
  String? mealGroupId;
  late String mealTime;
  DateTime mealDate = DateTime.now();
  ParsedFoodQuery parsed=const ParsedFoodQuery(original:'',productQuery:'');
  final controller=TextEditingController(text:'100');

  @override void initState(){super.initState();final now=DateTime.now();mealDate=DateTime(now.year,now.month,now.day);mealTime='${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';}

  Future<void> _pickMealDate() async {
    final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: mealDate, locale: const Locale('uk'), helpText: 'Дата прийому їжі');
    if (picked != null && mounted) setState(() { mealDate = DateTime(picked.year,picked.month,picked.day); mealGroupId = null; });
  }

  Future<void> _pickMealTime() async {
    final parts = mealTime.split(':');
    final initial = TimeOfDay(hour:int.tryParse(parts.first) ?? DateTime.now().hour, minute:int.tryParse(parts.length > 1 ? parts[1] : '') ?? DateTime.now().minute);
    final picked = await showTimePicker(context: context, initialTime: initial, helpText: 'Час прийому їжі');
    if (picked != null && mounted) setState(() { mealTime = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}'; });
  }

  @override void dispose(){controller.dispose();super.dispose();}

  double? _toGrams(Product p)=>FoodCalculationService.toGrams(p, Quantity(amount, unit));

  List<QuantityUnit> _unitsFor(Product p){
    final units=<QuantityUnit>[QuantityUnit.grams];
    if(p.gramsPerMl!=null) units.add(QuantityUnit.milliliters);
    if(p.gramsPerPiece!=null) units.add(QuantityUnit.pieces);
    if(p.servingGrams!=null) units.add(QuantityUnit.portion);
    return units;
  }

  QuantityUnit? _mapParsedUnit(ParsedQuantityUnit? u){
    switch(u){
      case ParsedQuantityUnit.grams: return QuantityUnit.grams;
      case ParsedQuantityUnit.milliliters: return QuantityUnit.milliliters;
      case ParsedQuantityUnit.pieces: return QuantityUnit.pieces;
      case ParsedQuantityUnit.portion: return QuantityUnit.portion;
      case null: return null;
    }
  }

  void _select(Product p){
    final units=_unitsFor(p);
    final parsedUnit=_mapParsedUnit(parsed.unit);
    var nextUnit=unit;
    if(parsedUnit!=null && units.contains(parsedUnit)) nextUnit=parsedUnit;
    else if(!units.contains(nextUnit)) nextUnit=units.first;
    final nextAmount=parsed.amount ?? (nextUnit==QuantityUnit.grams?100:1);
    setState((){
      selected=p;
      unit=nextUnit;
      amount=nextAmount;
      controller.text=FoodSearchService.parseQuery(q).amount?.toString() ?? nextAmount.toString();
    });
  }

  Future<void> _lookupBarcode(String barcode) async {
    setState(() { selected = null; });
    if (!mounted) return;
    showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final product = await FoodSearchService.findByBarcode(
        barcode,
        customProductLookup: AppDb.customProductByBarcode,
      );
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Продукт зі штрихкодом $barcode не знайдено.')));
        return;
      }
      final parsedUnit = parsed.unit;
      final units = _unitsFor(product);
      var nextUnit = _mapParsedUnit(parsedUnit);
      if (nextUnit == null || !units.contains(nextUnit)) nextUnit = units.first;
      var verifiedProduct = product;
      if (product.source == 'Open Food Facts') {
        final review = await showDialog<ProductReviewResult>(
          context: context,
          builder: (_) => ProductReviewDialog(product: product),
        );
        if (!mounted || review == null) return;
        verifiedProduct = review.product;
        if (review.saveLocally) {
          await AppDb.saveCustomProduct(verifiedProduct);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Перевірений продукт збережено локально.')),
            );
          }
        }
      }

      final verifiedUnits = _unitsFor(verifiedProduct);
      var verifiedUnit = _mapParsedUnit(parsed.unit);
      if (verifiedUnit == null || !verifiedUnits.contains(verifiedUnit)) verifiedUnit = verifiedUnits.first;
      setState(() {
        q = verifiedProduct.name;
        parsed = ParsedFoodQuery(original: barcode, productQuery: verifiedProduct.name);
        selected = verifiedProduct;
        unit = verifiedUnit!;
        amount = verifiedUnit == QuantityUnit.grams ? 100 : 1;
        controller.text = amount.toString();
      });
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка пошуку за штрихкодом: $e')));
    }
  }

  void _updateQuery(String value){
    final parsedNow=FoodSearchService.parseQuery(value);
    setState((){
      q=value;
      parsed=parsedNow;
      selected=null;
    });
  }

  @override Widget build(BuildContext c)=>FutureBuilder<List<Product>>(future:loadAllProducts(),builder:(c,s){
    if(!s.hasData)return const Center(child:CircularProgressIndicator());
    final results=FoodSearchService.search(q,s.data!);
    final list=results.map((r)=>r.product).toList();
    final grams=selected==null?null:_toGrams(selected!);
    final carbs=selected==null||grams==null?0.0:(grams*selected!.carbs/100).toDouble();
    final units=selected==null?<QuantityUnit>[QuantityUnit.grams]:_unitsFor(selected!);
    final hasParsedAmount=parsed.amount!=null;
    return ListView(padding:const EdgeInsets.all(20),children:[
      const Text('Додати їжу',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
      const SizedBox(height:14),
      DropdownButtonFormField<String>(value:meal,decoration:const InputDecoration(labelText:'Прийом їжі',border:OutlineInputBorder()),items:['Сніданок','Обід','Вечеря','Перекус'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(x)=>setState((){meal=x!;mealGroupId=null;})),
      const SizedBox(height:8),
      FutureBuilder<List<Map<String,dynamic>>>(future:AppDb.mealGroups(_dateKey(mealDate)),builder:(context, snapshot){
        final groups = snapshot.data ?? const <Map<String,dynamic>>[];
        return Column(children:[
          DropdownButtonFormField<String>(value:mealGroupId,decoration:const InputDecoration(labelText:'Додати до існуючого прийому',hintText:'Не вибрано — створити новий',border:OutlineInputBorder()),items:groups.map((g)=>DropdownMenuItem<String>(value:g['id'] as String,child:Text('${g['meal']}${(g['time'] as String).isEmpty ? '' : ' • ${g['time']}'}'))).toList(),onChanged:(id){if(id==null)return;final g=groups.firstWhere((x)=>x['id']==id);setState((){mealGroupId=id;meal=g['meal'] as String;mealTime=(g['time'] as String).isEmpty?mealTime:g['time'] as String;});}),
          const SizedBox(height:8),
          SizedBox(width:double.infinity,child:OutlinedButton.icon(
            onPressed:(){final now=DateTime.now();setState((){mealGroupId=null;mealTime='${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';});},
            icon:const Icon(Icons.add_circle_outline),
            label:const Text('Створити новий прийом їжі'),
          )),
        ]);
      }),
      const SizedBox(height:8),
      Row(children:[
        Expanded(child:OutlinedButton.icon(onPressed:_pickMealDate,icon:const Icon(Icons.calendar_today),label:Text(_prettyDate(mealDate)))),
        const SizedBox(width:8),
        Expanded(child:OutlinedButton.icon(onPressed:_pickMealTime,icon:const Icon(Icons.schedule),label:Text('Час: $mealTime'))),
      ]),
      const SizedBox(height:12),
      TextField(
        decoration:const InputDecoration(labelText:'Що ви зʼїли?',hintText:'Наприклад: 150 г гречки вареної на воді',prefixIcon:Icon(Icons.search),border:OutlineInputBorder()),
        onChanged:_updateQuery,
      ),
      const SizedBox(height:10),
      OutlinedButton.icon(
        onPressed: () async {
          final barcode = await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
          );
          if (barcode == null || !mounted) return;
          await _lookupBarcode(barcode);
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Сканувати штрихкод'),
      ),
      if(q.trim().isNotEmpty && list.isNotEmpty)...[
        const SizedBox(height:8),
        Text(hasParsedAmount?'Знайдено для «${parsed.productQuery}»':'Оберіть продукт',style:const TextStyle(fontWeight:FontWeight.w600)),
        ...list.take(10).map((p)=>Card(child:ListTile(
          leading:Icon(p.state=='cooked'?Icons.restaurant:Icons.inventory_2_outlined),
          title:Text(p.name),
          subtitle:Text('${p.carbs.toStringAsFixed(1)} г вуглеводів / 100 г${p.manufacturer==null?'':' • ${p.manufacturer}'}'),
          trailing:const Icon(Icons.chevron_right),
          onTap:()=>_select(p),
        ))),
      ] else if(q.trim().isNotEmpty && list.isEmpty)
        const Padding(padding:EdgeInsets.symmetric(vertical:18),child:Text('У локальній базі продукт не знайдено. Спробуйте іншу назву або пізніше використайте пошук за штрихкодом.')),
      if(selected!=null)...[
        const Divider(height:24),
        Text(selected!.name,style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold)),
        if(selected!.manufacturer!=null)Text(selected!.manufacturer!),
        if(selected!.barcode!=null)Text('Штрихкод: ${selected!.barcode}'),
        const SizedBox(height:8),
        if(parsed.amount!=null)Text('З вашого запиту: ${parsed.amount!.toStringAsFixed(parsed.amount==parsed.amount!.roundToDouble()?0:2)} ${_mapParsedUnit(parsed.unit)?.label ?? ''}',style:const TextStyle(color:Colors.teal)),
        const SizedBox(height:8),
        Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Expanded(child:TextFormField(controller:controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Кількість',border:OutlineInputBorder()),onChanged:(v)=>setState(()=>amount=double.tryParse(v.replaceAll(',','.'))??0))),
          const SizedBox(width:10),
          Expanded(child:DropdownButtonFormField<QuantityUnit>(value:unit,decoration:const InputDecoration(labelText:'Одиниця',border:OutlineInputBorder()),items:units.map((u)=>DropdownMenuItem(value:u,child:Text(u.label))).toList(),onChanged:(u){if(u==null)return;setState((){unit=u;amount=u==QuantityUnit.grams?100:1;controller.text=amount.toString();});})),
        ]),
        const SizedBox(height:8),
        if(grams==null)const Text('Для цієї одиниці немає даних для перерахунку. Оберіть грами або додайте вагу/обʼєм одиниці до даних продукту.',style:TextStyle(color:Colors.orange)),
        FutureBuilder<double>(future:_xeGrams(),builder:(context,xeSnap){
          final xeGrams=xeSnap.data??10;
          final result=selected==null?null:FoodCalculationService.calculate(product:selected!,quantity:Quantity(amount,unit),xeGrams:xeGrams);
          final displayCarbs=result?.carbs??carbs;
          final displayXe=result?.xe??0;
          return Card(child:ListTile(title:const Text('Вуглеводи'),subtitle:Text('${displayXe.toStringAsFixed(2)} ХО'),trailing:Text('${displayCarbs.toStringAsFixed(1)} г',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold))));
        }),
        FilledButton(onPressed:amount>0&&grams!=null?()async{
          final xeGrams=await _xeGrams();
          final groupId = mealGroupId ?? 'meal_${mealDate.microsecondsSinceEpoch}_${meal.replaceAll(' ','_')}';
          mealGroupId = groupId;
          await AppDb.addDiary(date:_dateKey(mealDate),meal:meal,name:selected!.name,grams:grams!,amountValue:amount,amountUnit:unit.label,carbs:carbs,xe:_xeForCarbs(carbs,xeGrams),mealGroupId:groupId,mealTime:mealTime,productId:selected!.id);
          if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content:Text('Додано до щоденника')));
          widget.onAdded();
        }:null,child:const Text('Додати до щоденника')),
      ]
    ]);
  });

  Future<double> _xeGrams() async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getDouble('xe_grams')??10;
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});
  @override State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool handled = false;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Сканувати штрихкод')),
    body: Stack(children: [
      MobileScanner(
        onDetect: (capture) {
          if (handled) return;
          for (final code in capture.barcodes) {
            final value = code.rawValue;
            if (value != null && value.trim().isNotEmpty) {
              handled = true;
              Navigator.of(context).pop(value.trim());
              break;
            }
          }
        },
      ),
      Center(child: Container(width: 280,height: 150,decoration: BoxDecoration(border: Border.all(color: Colors.white,width: 2),borderRadius: BorderRadius.circular(12)))),
      const Positioned(left: 0,right: 0,bottom: 32,child: Center(child: Text('Наведіть камеру на штрихкод',style: TextStyle(color: Colors.white,fontSize: 16))))
    ]),
  );
}

class DiaryPage extends StatefulWidget {
  final VoidCallback onChanged;
  const DiaryPage({super.key, required this.onChanged});
  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime date = DateTime.now();

  String get key => _dateKey(date);

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: date,
      locale: const Locale('uk'),
      helpText: 'Оберіть дату',
    );
    if (picked != null && mounted) {
      setState(() => date = picked);
    }
  }

  Future<Product?> productFor(Map<String, dynamic> row) async {
    final productId = row['product_id'] as String?;
    final products = await loadAllProducts();
    if (productId != null) {
      for (final product in products) {
        if (product.id == productId) return product;
      }
    }
    for (final product in products) {
      if (product.name == row['name']) return product;
    }
    return null;
  }

  Future<void> editRow(Map<String, dynamic> row) async {
    final product = await productFor(row);
    if (product == null || !mounted) return;

    final unit = _unitFromLabel((row['amount_unit'] as String?) ?? 'г');
    final initial = (row['amount_value'] as num?)?.toDouble() ??
        (row['grams'] as num).toDouble();
    final controller = TextEditingController(text: _n(initial));

    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Змінити: ${product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Кількість',
            suffixText: unit.label,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (value == null || value <= 0) return;
    final grams = FoodCalculationService.toGrams(product, Quantity(value, unit));
    if (grams == null) return;

    final carbs = grams * product.carbs / 100;
    final prefs = await SharedPreferences.getInstance();
    final xeGrams = prefs.getDouble('xe_grams') ?? 10;

    await AppDb.updateDiary(
      id: row['id'] as int,
      grams: grams,
      amountValue: value,
      amountUnit: unit.label,
      carbs: carbs,
      xe: _xeForCarbs(carbs, xeGrams),
    );

    if (mounted) setState(() {});
    widget.onChanged();
  }

  Future<void> deleteRow(Map<String, dynamic> row) async {
    await AppDb.deleteDiary(row['id'] as int);
    if (mounted) setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AppDb.diary(key),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rows = snapshot.data!;
        final groups = <String, List<Map<String, dynamic>>>{};
        for (final row in rows) {
          final groupId = (row['meal_group_id'] as String?) ??
              'legacy_${row['meal']}_${row['meal_time'] ?? ''}';
          groups.putIfAbsent(groupId, () => <Map<String, dynamic>>[]).add(row);
        }

        final totalCarbs = rows.fold<double>(
          0,
          (sum, row) => sum + (row['carbs'] as num).toDouble(),
        );
        final totalXe = rows.fold<double>(
          0,
          (sum, row) => sum + (row['xe'] as num).toDouble(),
        );

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Щоденник',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Попередній день',
                      onPressed: () => setState(
                        () => date = date.subtract(const Duration(days: 1)),
                      ),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      tooltip: 'Календар',
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_month),
                    ),
                    IconButton(
                      tooltip: 'Наступний день',
                      onPressed: () => setState(
                        () => date = date.add(const Duration(days: 1)),
                      ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
            Text(_prettyDate(date), style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text('Підсумок дня'),
                subtitle: Text('${rows.length} продуктів'),
                trailing: Text(
                  '${totalCarbs.toStringAsFixed(1)} г\n${totalXe.toStringAsFixed(2)} ХО',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: Text('За цей день записів немає.')),
              )
            else
              ...groups.values.map((items) {
                final meal = (items.first['meal'] as String?) ?? '';
                final time = (items.first['meal_time'] as String?) ?? '';
                final groupCarbs = items.fold<double>(
                  0,
                  (sum, row) => sum + (row['carbs'] as num).toDouble(),
                );
                final groupXe = items.fold<double>(
                  0,
                  (sum, row) => sum + (row['xe'] as num).toDouble(),
                );

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              meal.isEmpty ? 'Прийом їжі' : meal,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(time),
                          ],
                        ),
                        const Divider(),
                        ...items.map(
                          (row) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(row['name'] as String),
                            subtitle: Text(_displayDiaryAmount(row)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(row['carbs'] as num).toStringAsFixed(1)} г',
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') await editRow(row);
                                    if (value == 'delete') await deleteRow(row);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Змінити'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Видалити'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Разом: ${groupCarbs.toStringAsFixed(1)} г • ${groupXe.toStringAsFixed(2)} ХО',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsPage()),
              ),
              icon: const Icon(Icons.table_chart),
              label: const Text('Звіти за день / тиждень / місяць'),
            ),
          ],
        );
      },
    );
  }
}

class RecipesPage extends StatefulWidget{
  final VoidCallback onAdded; const RecipesPage({super.key,required this.onAdded});
  @override State<RecipesPage> createState()=>_RecipesPageState();
}
class _RecipesPageState extends State<RecipesPage>{
  Future<void> create()async{
    final r=await showDialog<_RecipeDraft>(context:context,builder:(_)=>const RecipeEditor());
    if(r!=null){await AppDb.saveRecipe(r.name,r.weight,r.items);setState((){});widget.onAdded();}
  }
  @override Widget build(BuildContext c)=>FutureBuilder<List<Map<String,dynamic>>>(future:AppDb.recipes(),builder:(c,s){
    if(!s.hasData)return const Center(child:CircularProgressIndicator());
    return ListView(padding:const EdgeInsets.all(20),children:[
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Мої страви',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),FilledButton.icon(onPressed:create,icon:const Icon(Icons.add),label:const Text('Нова'))]),
      const SizedBox(height:14),
      if(s.data!.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('Створіть рецепт — наприклад, борщ, суп або домашню випічку.'))),
      ...s.data!.map((r)=>Card(child:ListTile(title:Text(r['name']),subtitle:Text('Готова вага: ${r['finished_weight']} г'),onLongPress:()async{await AppDb.deleteRecipe(r['id'] as int);setState((){});},onTap:()=>_showRecipe(c,r['id'] as int,r['name'],(r['finished_weight'] as num).toDouble())))),
    ]);
  });
  Future<void> _showRecipe(BuildContext c,int id,String name,double weight)async{
    final ps=await loadProducts();final d=await AppDb.db;final rows=await d.query('recipe_ingredients',where:'recipe_id=?',whereArgs:[id]);
    final items=<FoodItem>[];for(final x in rows){final p=ps.firstWhere((z)=>z.id==x['product_id']);items.add(FoodItem(p,(x['grams'] as num).toDouble()));}
    final total=items.fold<double>(0,(a,x)=>a+x.carbs);final per=weight>0?(total/weight*100).toDouble():0.0;
    if(!c.mounted)return;
    showDialog(context:c,builder:(_)=>PortionDialog(name:name,per100:per,total:total,onAdd:(grams)async{
      final carbs=per*grams/100;final prefs=await SharedPreferences.getInstance(); final xeGrams=prefs.getDouble('xe_grams')??10; await AppDb.addDiary(date:_dateKey(DateTime.now()),meal:'',name:name,grams:grams,amountValue:grams,amountUnit:'г',carbs:carbs,xe:_xeForCarbs(carbs,xeGrams));
    }));
  }
}

class _RecipeDraft{final String name;final double weight;final List<FoodItem> items;_RecipeDraft(this.name,this.weight,this.items);}
class RecipeEditor extends StatefulWidget{const RecipeEditor({super.key});@override State<RecipeEditor> createState()=>_RecipeEditorState();}
class _RecipeEditorState extends State<RecipeEditor>{
  final name=TextEditingController(),weight=TextEditingController();final items=<FoodItem>[];Product? selected;double grams=100;String q='';
  @override Widget build(BuildContext c)=>AlertDialog(title:const Text('Нова страва'),content:SizedBox(width:560,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    TextField(controller:name,decoration:const InputDecoration(labelText:'Назва страви')),
    TextField(controller:weight,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Вага готової страви',suffixText:'г')),
    const SizedBox(height:10),
    FutureBuilder<List<Product>>(future:loadProducts(),builder:(c,s){
      if(!s.hasData)return const CircularProgressIndicator();
      final ps=s.data!.where((p)=>p.name.toLowerCase().contains(q.toLowerCase())).take(5).toList();
      return Column(children:[
        TextField(decoration:const InputDecoration(labelText:'Пошук інгредієнта'),onChanged:(v)=>setState(()=>q=v)),
        ...ps.map((p)=>ListTile(title:Text(p.name),subtitle:Text('${p.carbs} г/100 г'),onTap:()=>setState(()=>selected=p))),
        if(selected!=null)Row(children:[Expanded(child:Text(selected!.name)),SizedBox(width:90,child:TextFormField(initialValue:'100',keyboardType:const TextInputType.numberWithOptions(decimal:true),onChanged:(v)=>grams=double.tryParse(v.replaceAll(',','.'))??0,decoration:const InputDecoration(suffixText:'г'))),IconButton(onPressed:()=>setState(()=>items.add(FoodItem(selected!,grams))),icon:const Icon(Icons.add))]),
      ]);
    }),
    const Divider(),
    ...items.asMap().entries.map((e)=>ListTile(title:Text(e.value.product.name),subtitle:Text('${e.value.grams} г → ${e.value.carbs.toStringAsFixed(1)} г'),trailing:IconButton(onPressed:()=>setState(()=>items.removeAt(e.key)),icon:const Icon(Icons.delete_outline)))),
    if(items.isNotEmpty)Text('Всього вуглеводів: ${items.fold<double>(0,(a,x)=>a+x.carbs).toStringAsFixed(1)} г'),
  ]))),actions:[
    TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Скасувати')),
    FilledButton(onPressed:items.isNotEmpty&&name.text.trim().isNotEmpty&&(double.tryParse(weight.text.replaceAll(',','.'))??0)>0?()=>Navigator.pop(c,_RecipeDraft(name.text.trim(),double.parse(weight.text.replaceAll(',','.')),items)):null,child:const Text('Зберегти')),
  ]);
}

class PortionDialog extends StatefulWidget{
  final String name;final double per100,total;final Future<void> Function(double) onAdd;
  const PortionDialog({super.key,required this.name,required this.per100,required this.total,required this.onAdd});
  @override State<PortionDialog> createState()=>_PortionDialogState();
}
class _PortionDialogState extends State<PortionDialog>{
  double grams=100;
  @override Widget build(BuildContext c){final carbs=widget.per100*grams/100;return AlertDialog(title:Text(widget.name),content:Column(mainAxisSize:MainAxisSize.min,children:[
    Text('Всього: ${widget.total.toStringAsFixed(1)} г вуглеводів'),Text('${widget.per100.toStringAsFixed(1)} г / 100 г'),
    TextFormField(initialValue:'100',keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Вага порції',suffixText:'г'),onChanged:(v)=>setState(()=>grams=double.tryParse(v.replaceAll(',','.'))??0)),
    const SizedBox(height:10),Text('${carbs.toStringAsFixed(1)} г',style:const TextStyle(fontSize:28,fontWeight:FontWeight.bold)),Text('${(carbs/10).toStringAsFixed(2)} ХО'),
  ]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Скасувати')),FilledButton(onPressed:grams>0?()async{await widget.onAdd(grams);if(c.mounted)Navigator.pop(c);}:null,child:const Text('Додати сьогодні'))]);}
}

class SettingsPage extends StatefulWidget{
  final VoidCallback onChanged;const SettingsPage({super.key,required this.onChanged});@override State<SettingsPage> createState()=>_SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage>{
  double xe=10;
  @override void initState(){super.initState();load();}
  Future<void> load()async{final p=await SharedPreferences.getInstance();setState(()=>xe=p.getDouble('xe_grams')??10);}
  Future<void> save(double v)async{final p=await SharedPreferences.getInstance();await p.setDouble('xe_grams',v);setState(()=>xe=v);}
  Future<void> custom()async{
    final r=await showDialog<Product>(context:context,builder:(_)=>const CustomProductDialog());
    if(r!=null){await AppDb.saveCustomProduct(r);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Продукт збережено')));widget.onChanged();}
  }
  @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Налаштування',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
    const SizedBox(height:12),
    Card(child:ListTile(title:const Text('1 ХО містить вуглеводів'),subtitle:const Text('За замовчуванням 10 г'),trailing:SizedBox(width:80,child:TextFormField(initialValue:xe.toString(),keyboardType:const TextInputType.numberWithOptions(decimal:true),onFieldSubmitted:(v)=>save(double.tryParse(v.replaceAll(',','.'))??10),decoration:const InputDecoration(suffixText:'г'))))),
    const SizedBox(height:12),
    FilledButton.icon(onPressed:custom,icon:const Icon(Icons.add),label:const Text('Додати мій продукт')),
    const SizedBox(height:18),
    const Text('Мої продукти',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),
    FutureBuilder<List<Product>>(
      future: AppDb.customProducts().then((rows)=>rows.map(Product.fromCustomDb).toList()),
      builder:(context,snap){
        if(!snap.hasData)return const Center(child:CircularProgressIndicator());
        final items=snap.data!;
        if(items.isEmpty)return const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Власних продуктів ще немає.')));
        return Column(children:items.map((product)=>Card(child:ListTile(
          leading:const Icon(Icons.star_outline),
          title:Text(product.name),
          subtitle:Text('${product.carbs.toStringAsFixed(1)} г вуглеводів / 100 г${product.barcode==null?'':' • ${product.barcode}'}'),
          onTap:()async{
            final result=await showDialog<ProductReviewResult>(context:context,builder:(_)=>ProductReviewDialog(product:product,customProductMode:true));
            if(result==null)return;
            await AppDb.saveCustomProduct(result.product);
            if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Продукт оновлено')));}
            widget.onChanged();
          },
          onLongPress:()async{
            final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(
              title:const Text('Видалити продукт?'),content:Text('«${product.name}» буде видалено з «Моїх продуктів».'),
              actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Скасувати')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Видалити'))],
            ));
            if(ok==true){await AppDb.deleteCustomProduct(product.id);if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Продукт видалено')));}widget.onChanged();}
          },
        ))).toList());
      },
    ),
    const SizedBox(height:12),
    FilledButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const GlucoseImportPage())),icon:const Icon(Icons.upload_file),label:const Text('Імпорт глюкози (CSV / PDF)')),
    const SizedBox(height:8),
    OutlinedButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const GlucoseHistoryPage())),icon:const Icon(Icons.bloodtype),label:const Text('Історія глюкози')),
    const SizedBox(height:8),
    OutlinedButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const ReportsPage())),icon:const Icon(Icons.table_chart),label:const Text('Звіти харчування')),
    const SizedBox(height:12),
    const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Застосунок не визначає дозу інсуліну, не змінює лікування та не замінює рекомендації лікаря.'))),
  ]);
}


class ProductReviewResult {
  final Product product;
  final bool saveLocally;
  const ProductReviewResult({required this.product, required this.saveLocally});
}

class ProductReviewDialog extends StatefulWidget {
  final Product product;
  final bool customProductMode;
  const ProductReviewDialog({super.key, required this.product, this.customProductMode=false});

  @override
  State<ProductReviewDialog> createState() => _ProductReviewDialogState();
}

class _ProductReviewDialogState extends State<ProductReviewDialog> {
  late final TextEditingController name;
  late final TextEditingController manufacturer;
  late final TextEditingController carbs;
  late final TextEditingController protein;
  late final TextEditingController fat;
  late final TextEditingController fiber;
  late final TextEditingController calories;
  late final TextEditingController gramsPerPiece;
  late final TextEditingController gramsPerMl;
  late final TextEditingController servingGrams;

  @override
  void initState() {
    super.initState();
    final x = widget.product;
    name = TextEditingController(text: x.name);
    manufacturer = TextEditingController(text: x.manufacturer ?? '');
    carbs = TextEditingController(text: _n(x.carbs));
    protein = TextEditingController(text: _n(x.protein));
    fat = TextEditingController(text: _n(x.fat));
    fiber = TextEditingController(text: _n(x.fiber));
    calories = TextEditingController(text: _n(x.calories));
    gramsPerPiece = TextEditingController(text: x.gramsPerPiece == null ? '' : _n(x.gramsPerPiece!));
    gramsPerMl = TextEditingController(text: x.gramsPerMl == null ? '' : _n(x.gramsPerMl!));
    servingGrams = TextEditingController(text: x.servingGrams == null ? '' : _n(x.servingGrams!));
  }

  static String _n(double value) => value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  double _d(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;
  double? _optional(TextEditingController c) {
    final text = c.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  Product _buildProduct() {
    final x = widget.product;
    return Product(
      id: x.id,
      name: name.text.trim(),
      category: x.category,
      state: x.state,
      carbs: _d(carbs),
      protein: _d(protein),
      fat: _d(fat),
      fiber: _d(fiber),
      calories: _d(calories),
      barcode: x.barcode,
      manufacturer: manufacturer.text.trim().isEmpty ? null : manufacturer.text.trim(),
      source: x.source,
      updatedAt: DateTime.now().toIso8601String(),
      gramsPerPiece: _optional(gramsPerPiece),
      gramsPerMl: _optional(gramsPerMl),
      servingGrams: _optional(servingGrams),
    );
  }

  @override
  void dispose() {
    for (final c in [name, manufacturer, carbs, protein, fat, fiber, calories, gramsPerPiece, gramsPerMl, servingGrams]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _dec(String label, {String? suffix}) => InputDecoration(
    labelText: label,
    suffixText: suffix,
    border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customProductMode ? 'Редагувати продукт' : 'Перевірте продукт'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.customProductMode ? 'Змініть дані продукту. Після збереження оновлені значення використовуватимуться в пошуку.' : 'Перевірте дані перед використанням. За потреби їх можна виправити.',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: _dec('Назва продукту')),
              const SizedBox(height: 8),
              TextField(controller: manufacturer, decoration: _dec('Виробник')),
              const SizedBox(height: 8),
              TextField(controller: carbs, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Вуглеводи / 100 г', suffix: 'г')),
              const SizedBox(height: 8),
              TextField(controller: protein, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Білки / 100 г', suffix: 'г')),
              const SizedBox(height: 8),
              TextField(controller: fat, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Жири / 100 г', suffix: 'г')),
              const SizedBox(height: 8),
              TextField(controller: fiber, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Клітковина / 100 г', suffix: 'г')),
              const SizedBox(height: 8),
              TextField(controller: calories, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Калорійність / 100 г', suffix: 'ккал')),
              const SizedBox(height: 14),
              const Align(alignment: Alignment.centerLeft, child: Text('Дані для одиниць вимірювання', style: TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(height: 8),
              TextField(controller: gramsPerPiece, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Вага 1 штуки', suffix: 'г')),
              const SizedBox(height: 8),
              TextField(controller: gramsPerMl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Грамів у 1 мл', suffix: 'г/мл')),
              const SizedBox(height: 8),
              TextField(controller: servingGrams, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Вага 1 порції', suffix: 'г')),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Штрихкод: ${widget.product.barcode ?? '—'}'),
                      Text('Джерело: ${widget.product.source ?? '—'}'),
                    ],
                  ),
                ),
              ),
              if (_d(carbs) <= 0)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Увага: вуглеводи не заповнені. Перевірте дані перед розрахунком.', style: TextStyle(color: Colors.orange)),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
        if(!widget.customProductMode) OutlinedButton(
          onPressed: name.text.trim().isEmpty ? null : () => Navigator.pop(context, ProductReviewResult(product: _buildProduct(), saveLocally: false)),
          child: const Text('Використати один раз'),
        ),
        FilledButton(
          onPressed: name.text.trim().isEmpty ? null : () => Navigator.pop(context, ProductReviewResult(product: _buildProduct(), saveLocally: true)),
          child: Text(widget.customProductMode ? 'Зберегти зміни' : 'Підтвердити і зберегти'),
        ),
      ],
    );
  }
}

class CustomProductDialog extends StatefulWidget {
  const CustomProductDialog({super.key});
  @override State<CustomProductDialog> createState() => _CustomProductDialogState();
}
class _CustomProductDialogState extends State<CustomProductDialog> {
  final n=TextEditingController(),cat=TextEditingController(text:'Мої продукти'),c=TextEditingController(),p=TextEditingController(),f=TextEditingController(),fi=TextEditingController(),cal=TextEditingController();
  final barcode=TextEditingController(),gramsPerPiece=TextEditingController(),gramsPerMl=TextEditingController(),servingGrams=TextEditingController();
  double? _num(TextEditingController x)=>double.tryParse(x.text.replaceAll(',','.').trim());
  @override void dispose(){for(final x in [n,cat,c,p,f,fi,cal,barcode,gramsPerPiece,gramsPerMl,servingGrams])x.dispose();super.dispose();}
  @override Widget build(BuildContext context){return AlertDialog(title:const Text('Мій продукт'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    TextField(controller:n,decoration:const InputDecoration(labelText:'Назва')),
    TextField(controller:cat,decoration:const InputDecoration(labelText:'Категорія')),
    TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Вуглеводи / 100 г')),
    TextField(controller:p,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Білки / 100 г')),
    TextField(controller:f,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Жири / 100 г')),
    TextField(controller:fi,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Клітковина / 100 г')),
    TextField(controller:cal,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Ккал / 100 г')),
    const SizedBox(height:8),const Align(alignment:Alignment.centerLeft,child:Text('Дані для швидкого введення',style:TextStyle(fontWeight:FontWeight.w600))),
    TextField(controller:barcode,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Штрихкод (необовʼязково)')),
    TextField(controller:gramsPerPiece,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Вага 1 шт, г')),
    TextField(controller:gramsPerMl,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Грамів у 1 мл')),
    TextField(controller:servingGrams,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Вага 1 порції, г')),
  ])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Скасувати')),FilledButton(onPressed:n.text.trim().isNotEmpty&&c.text.isNotEmpty?()=>Navigator.pop(context,Product(id:'custom_${DateTime.now().microsecondsSinceEpoch}',name:n.text.trim(),category:cat.text.trim(),carbs:_num(c)??0,protein:_num(p)??0,fat:_num(f)??0,fiber:_num(fi)??0,calories:_num(cal)??0,barcode:barcode.text.trim().isEmpty?null:barcode.text.trim(),source:'Користувач',gramsPerPiece:_num(gramsPerPiece),gramsPerMl:_num(gramsPerMl),servingGrams:_num(servingGrams))):null,child:const Text('Зберегти'))]);}
}

class ReportsPage extends StatefulWidget{const ReportsPage({super.key});@override State<ReportsPage> createState()=>_ReportsPageState();}
class _ReportsPageState extends State<ReportsPage>{int days=1;DateTime end=DateTime.now();DateTime get start=>DateTime(end.year,end.month,end.day).subtract(Duration(days:days-1));Future<List<Map<String,dynamic>>> load()async=> (await AppDb.db).query('diary',where:'date>=? AND date<?',whereArgs:[_dateKey(start),_dateKey(end.add(const Duration(days:1)))],orderBy:'date ASC,id ASC');@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Звіти')),body:FutureBuilder<List<Map<String,dynamic>>>(future:load(),builder:(context,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final rows=s.data!;final total=rows.fold<double>(0,(a,x)=>a+(x['carbs'] as num).toDouble());return ListView(padding:const EdgeInsets.all(16),children:[DropdownButtonFormField<int>(value:days,decoration:const InputDecoration(labelText:'Період',border:OutlineInputBorder()),items:const[DropdownMenuItem(value:1,child:Text('День')),DropdownMenuItem(value:7,child:Text('7 днів')),DropdownMenuItem(value:30,child:Text('30 днів'))],onChanged:(v){if(v!=null){setState(()=>days=v);}}),const SizedBox(height:10),Text('${_prettyDate(start)} — ${_prettyDate(end)}'),Card(child:ListTile(title:const Text('Всього вуглеводів'),trailing:Text('${total.toStringAsFixed(1)} г',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)))),if(rows.isNotEmpty)SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(columns:const[DataColumn(label:Text('Дата')),DataColumn(label:Text('Прийом')),DataColumn(label:Text('Час')),DataColumn(label:Text('Продукт')),DataColumn(label:Text('Кількість')),DataColumn(label:Text('Вуглеводи'))],rows:rows.map((r)=>DataRow(cells:[DataCell(Text(_prettyDate(DateTime.parse(r['date'] as String)))),DataCell(Text((r['meal'] as String?)??'')),DataCell(Text((r['meal_time'] as String?)??'')),DataCell(Text(r['name'] as String)),DataCell(Text(_displayDiaryAmount(r))),DataCell(Text('${(r['carbs'] as num).toStringAsFixed(1)} г'))])).toList()))else const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('За вибраний період записів немає.'))),const SizedBox(height:10),Text('Середнє за день: ${(total/days).toStringAsFixed(1)} г')]);}));}
}

class GlucoseImportPage extends StatefulWidget{const GlucoseImportPage({super.key});@override State<GlucoseImportPage> createState()=>_GlucoseImportPageState();}
class _GlucoseImportPageState extends State<GlucoseImportPage>{bool busy=false;GlucoseImportResult? result;String? fileName;Future<void> pick()async{final picked=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['csv','pdf'],withData:true);if(picked==null||picked.files.isEmpty)return;final file=picked.files.single;if(file.bytes==null)return;setState((){busy=true;fileName=file.name;});try{final parsed=file.extension?.toLowerCase()=='pdf'?GlucoseImportService.fromPdf(file.bytes!,source:file.name):GlucoseImportService.fromCsv(utf8.decode(file.bytes!,allowMalformed:true),source:file.name);final fresh=await AppDb.onlyNewGlucose(parsed.readings);final dup=parsed.readings.length-fresh.length;if(mounted)setState(()=>result=GlucoseImportResult(fresh,[...parsed.warnings,'Дублікатів: $dup']));}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Помилка імпорту: $e')));}finally{if(mounted)setState(()=>busy=false);}}Future<void> save()async{final r=result;if(r==null||r.readings.isEmpty)return;await AppDb.insertGlucoseBatch(r.readings);if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Імпортовано ${r.readings.length} показників.')));setState(()=>result=null);}}@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Імпорт глюкози')),body:ListView(padding:const EdgeInsets.all(20),children:[const Text('Універсальний імпорт',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('CSV — основний формат. PDF підтримується для текстових таблиць; для складних PDF краще використовувати CSV.'),const SizedBox(height:16),FilledButton.icon(onPressed:busy?null:pick,icon:const Icon(Icons.upload_file),label:Text(busy?'Обробка...':'Вибрати CSV або PDF')),if(fileName!=null)Text(fileName!),if(result!=null)...[const SizedBox(height:16),Text('Нових показників: ${result!.readings.length}'),...result!.readings.take(20).map((r)=>ListTile(leading:const Icon(Icons.bloodtype),title:Text('${r.valueMmol.toStringAsFixed(1)} ммоль/л'),subtitle:Text(_prettyDateTime(r.timestamp)))),FilledButton(onPressed:save,child:Text('Імпортувати ${result!.readings.length}'))]]));}}

class GlucoseHistoryPage extends StatelessWidget{const GlucoseHistoryPage({super.key});@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Історія глюкози')),body:FutureBuilder<List<Map<String,dynamic>>>(future:AppDb.glucose(),builder:(context,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());return ListView.builder(itemCount:s.data!.length,itemBuilder:(context,i){final r=s.data![i];final d=DateTime.parse(r['timestamp'] as String);return Card(child:ListTile(leading:const Icon(Icons.bloodtype),title:Text('${(r['value_mmol'] as num).toStringAsFixed(1)} ммоль/л'),subtitle:Text('${_prettyDateTime(d)} • ${r['source']??'імпорт'}')));});}));}}

String _prettyDateTime(DateTime d)=>'${_prettyDate(d)} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
String _n(double v)=>v%1==0?v.toStringAsFixed(0):v.toStringAsFixed(2);
String _displayDiaryAmount(Map<String,dynamic> x){final v=(x['amount_value'] as num?)?.toDouble()??(x['grams'] as num).toDouble();final u=(x['amount_unit'] as String?)??'г';return Quantity(v,_unitFromLabel(u)).display;}
QuantityUnit _unitFromLabel(String u){switch(u){case 'мл':return QuantityUnit.milliliters;case 'шт':return QuantityUnit.pieces;case 'порція':return QuantityUnit.portion;default:return QuantityUnit.grams;}}
String _dateKey(DateTime d)=>'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
String _prettyDate(DateTime d)=>'${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}';
