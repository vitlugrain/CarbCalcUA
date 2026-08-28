from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
main_path = ROOT / 'lib' / 'main.dart'
pubspec_path = ROOT / 'pubspec.yaml'

main = main_path.read_text(encoding='utf-8')
pubspec = pubspec_path.read_text(encoding='utf-8')

# Calendar localization: showDatePicker with Ukrainian locale needs the
# Flutter localization package/delegates available in the app.
if 'flutter_localizations:' not in pubspec:
    pubspec = pubspec.replace(
        'dependencies:\n  flutter:\n    sdk: flutter\n',
        'dependencies:\n  flutter:\n    sdk: flutter\n  flutter_localizations:\n    sdk: flutter\n',
        1,
    )
    pubspec_path.write_text(pubspec, encoding='utf-8')

if "import 'package:flutter_localizations/flutter_localizations.dart';" not in main:
    main = main.replace(
        "import 'package:flutter/material.dart';\n",
        "import 'package:flutter/material.dart';\nimport 'package:flutter_localizations/flutter_localizations.dart';\n",
        1,
    )

# Enable Ukrainian Material/Cupertino localization for the date picker.
old = "title:'CarbCalc UA',debugShowCheckedModeBanner:false,\n    theme:ThemeData"
new = "title:'CarbCalc UA',debugShowCheckedModeBanner:false,\n    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],\n    supportedLocales: const [Locale('uk'), Locale('en')],\n    theme:ThemeData"
if old in main and 'GlobalMaterialLocalizations.delegate' not in main:
    main = main.replace(old, new, 1)

# Add a reusable list of existing meal groups for a selected date.
needle = "  static Future<List<Map<String,dynamic>>> diary(String date) async=>(await db).query('diary',where:'date=?',whereArgs:[date],orderBy:'id ASC');\n"
insert = needle + "  static Future<List<Map<String,dynamic>>> mealGroups(String date) async {\n    final rows = await diary(date);\n    final groups = <String, Map<String,dynamic>>{};\n    for (final row in rows) {\n      final id = (row['meal_group_id'] as String?) ?? 'legacy_${row['meal']}_${row['meal_time'] ?? ''}';\n      groups.putIfAbsent(id, () => {'id': id, 'meal': row['meal'], 'time': row['meal_time'] ?? ''});\n    }\n    return groups.values.toList();\n  }\n"
if needle in main and 'static Future<List<Map<String,dynamic>>> mealGroups' not in main:
    main = main.replace(needle, insert, 1)

# AddFoodPage: make meal date/time/group mutable and selectable.
old_fields = "  late final String mealGroupId;\n  late final String mealTime;\n"
new_fields = "  String? mealGroupId;\n  late String mealTime;\n  DateTime mealDate = DateTime.now();\n"
if old_fields in main:
    main = main.replace(old_fields, new_fields, 1)

old_init = "  @override void initState(){super.initState();final now=DateTime.now();mealGroupId='meal_${now.microsecondsSinceEpoch}';mealTime='${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';}\n"
new_init = "  @override void initState(){super.initState();final now=DateTime.now();mealDate=DateTime(now.year,now.month,now.day);mealTime='${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';}\n\n  Future<void> _pickMealDate() async {\n    final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: mealDate, locale: const Locale('uk'), helpText: 'Дата прийому їжі');\n    if (picked != null && mounted) setState(() { mealDate = DateTime(picked.year,picked.month,picked.day); mealGroupId = null; });\n  }\n\n  Future<void> _pickMealTime() async {\n    final parts = mealTime.split(':');\n    final initial = TimeOfDay(hour:int.tryParse(parts.first) ?? DateTime.now().hour, minute:int.tryParse(parts.length > 1 ? parts[1] : '') ?? DateTime.now().minute);\n    final picked = await showTimePicker(context: context, initialTime: initial, helpText: 'Час прийому їжі');\n    if (picked != null && mounted) setState(() { mealTime = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}'; });\n  }\n"
if old_init in main:
    main = main.replace(old_init, new_init, 1)

old_meal_ui = "      DropdownButtonFormField<String>(value:meal,decoration:const InputDecoration(labelText:'Прийом їжі',border:OutlineInputBorder()),items:['Сніданок','Обід','Вечеря','Перекус'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(x)=>setState(()=>meal=x!)),\n      const SizedBox(height:8),\n      Row(children:[const Icon(Icons.schedule,size:20),const SizedBox(width:8),Text('Час прийому: $mealTime')]),\n"
new_meal_ui = "      DropdownButtonFormField<String>(value:meal,decoration:const InputDecoration(labelText:'Прийом їжі',border:OutlineInputBorder()),items:['Сніданок','Обід','Вечеря','Перекус'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(x)=>setState((){meal=x!;mealGroupId=null;})),\n      const SizedBox(height:8),\n      FutureBuilder<List<Map<String,dynamic>>>(future:AppDb.mealGroups(_dateKey(mealDate)),builder:(context, snapshot){\n        final groups = snapshot.data ?? const <Map<String,dynamic>>[];\n        return DropdownButtonFormField<String>(value:mealGroupId,decoration:const InputDecoration(labelText:'Додати до існуючого прийому',hintText:'Не вибрано — створити новий',border:OutlineInputBorder()),items:groups.map((g)=>DropdownMenuItem<String>(value:g['id'] as String,child:Text('${g['meal']}${(g['time'] as String).isEmpty ? '' : ' • ${g['time']}'}'))).toList(),onChanged:(id){if(id==null)return;final g=groups.firstWhere((x)=>x['id']==id);setState((){mealGroupId=id;meal=g['meal'] as String;mealTime=(g['time'] as String).isEmpty?mealTime:g['time'] as String;});});\n      }),\n      const SizedBox(height:8),\n      Row(children:[\n        Expanded(child:OutlinedButton.icon(onPressed:_pickMealDate,icon:const Icon(Icons.calendar_today),label:Text(_prettyDate(mealDate)))),\n        const SizedBox(width:8),\n        Expanded(child:OutlinedButton.icon(onPressed:_pickMealTime,icon:const Icon(Icons.schedule),label:Text('Час: $mealTime'))),\n      ]),\n"
if old_meal_ui in main:
    main = main.replace(old_meal_ui, new_meal_ui, 1)

old_add = "          await AppDb.addDiary(date:_dateKey(DateTime.now()),meal:meal,name:selected!.name,grams:grams!,amountValue:amount,amountUnit:unit.label,carbs:carbs,xe:_xeForCarbs(carbs,xeGrams),mealGroupId:mealGroupId,mealTime:mealTime,productId:selected!.id);\n"
new_add = "          final groupId = mealGroupId ?? 'meal_${mealDate.microsecondsSinceEpoch}_${meal.replaceAll(' ','_')}';\n          mealGroupId = groupId;\n          await AppDb.addDiary(date:_dateKey(mealDate),meal:meal,name:selected!.name,grams:grams!,amountValue:amount,amountUnit:unit.label,carbs:carbs,xe:_xeForCarbs(carbs,xeGrams),mealGroupId:groupId,mealTime:mealTime,productId:selected!.id);\n"
if old_add in main:
    main = main.replace(old_add, new_add, 1)

main_path.write_text(main, encoding='utf-8')
