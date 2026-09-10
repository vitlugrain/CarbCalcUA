#!/usr/bin/env python3
from pathlib import Path

path = Path('lib/main.dart')
text = path.read_text(encoding='utf-8')
original = text


def replace_once(old: str, new: str, label: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly 1 match, found {count}')
    text = text.replace(old, new, 1)

replace_once(
    "import 'services/food_calculation_service.dart';\n",
    "import 'services/food_calculation_service.dart';\nimport 'services/meal_group_service.dart';\nimport 'widgets/meal_header_menu.dart';\n",
    'imports',
)

replace_once(
    "class AddFoodPage extends StatefulWidget{\n  final VoidCallback onAdded;\n  const AddFoodPage({super.key,required this.onAdded});\n",
    "class AddFoodPage extends StatefulWidget{\n  final VoidCallback onAdded;\n  final String? initialMealGroupId;\n  final String? initialMeal;\n  final String? initialMealTime;\n  final DateTime? initialMealDate;\n  const AddFoodPage({super.key,required this.onAdded,this.initialMealGroupId,this.initialMeal,this.initialMealTime,this.initialMealDate});\n",
    'AddFoodPage constructor',
)

replace_once(
    "  @override void initState(){super.initState();final now=DateTime.now();mealDate=DateTime(now.year,now.month,now.day);mealTime='${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';}\n",
    "  @override void initState(){\n    super.initState();\n    final now=DateTime.now();\n    mealDate=widget.initialMealDate ?? DateTime(now.year,now.month,now.day);\n    mealTime=widget.initialMealTime ?? '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';\n    meal=widget.initialMeal ?? 'Сніданок';\n    mealGroupId=widget.initialMealGroupId;\n    mealGroupExplicitSelection=widget.initialMealGroupId!=null;\n  }\n",
    'AddFoodPage initState',
)

needle = "  Future<void> deleteRow(Map<String, dynamic> row) async {\n    await AppDb.deleteDiary(row['id'] as int);\n    if (mounted) setState(() {});\n    widget.onChanged();\n  }\n"
insert = needle + "\n  Future<String> _persistentGroupId(\n    String groupKey,\n    List<Map<String, dynamic>> items,\n  ) async {\n    final current=(items.first['meal_group_id'] as String?);\n    if(current!=null && current.isNotEmpty)return current;\n    final meal=(items.first['meal'] as String?)??'';\n    final time=(items.first['meal_time'] as String?)??'';\n    final id=MealGroupService.newGroupId(meal);\n    await MealGroupService.moveLegacyGroup(\n      await AppDb.db,\n      date:key,\n      meal:meal,\n      time:time,\n      newGroupId:id,\n    );\n    return id;\n  }\n\n  Future<void> editMealGroup(\n    String groupKey,\n    List<Map<String, dynamic>> items,\n  ) async {\n    final meal=(items.first['meal'] as String?)??'';\n    final time=(items.first['meal_time'] as String?)??'';\n    final result=await showMealHeaderEditDialog(\n      context,\n      initialMeal:meal,\n      initialDate:date,\n      initialTime:time,\n    );\n    if(result==null || !mounted)return;\n    final id=await _persistentGroupId(groupKey,items);\n    await MealGroupService.updateGroup(\n      await AppDb.db,\n      groupId:id,\n      date:_dateKey(result.date),\n      meal:result.meal,\n      time:result.time,\n    );\n    if(mounted)setState((){});\n    widget.onChanged();\n  }\n\n  Future<void> deleteMealGroup(\n    String groupKey,\n    List<Map<String, dynamic>> items,\n  ) async {\n    final meal=(items.first['meal'] as String?)??'';\n    final ok=await confirmDeleteMeal(context,meal);\n    if(!ok || !mounted)return;\n    final id=await _persistentGroupId(groupKey,items);\n    await MealGroupService.deleteGroup(await AppDb.db,groupId:id);\n    if(mounted)setState((){});\n    widget.onChanged();\n  }\n\n  Future<void> addProductToMealGroup(\n    String groupKey,\n    List<Map<String, dynamic>> items,\n  ) async {\n    final id=await _persistentGroupId(groupKey,items);\n    if(!mounted)return;\n    final meal=(items.first['meal'] as String?)??'Сніданок';\n    final time=(items.first['meal_time'] as String?)??'';\n    await Navigator.of(context).push(\n      MaterialPageRoute(\n        builder:(_)=>Scaffold(\n          appBar:AppBar(title:const Text('Додати продукт')),\n          body:AddFoodPage(\n            onAdded:widget.onChanged,\n            initialMealGroupId:id,\n            initialMeal:meal.isEmpty?'Сніданок':meal,\n            initialMealTime:time,\n            initialMealDate:date,\n          ),\n        ),\n      ),\n    );\n    if(mounted)setState((){});\n  }\n"
replace_once(needle, insert, 'Diary meal group methods')

replace_once(
    "              ...groups.values.map((items) {\n",
    "              ...groups.entries.map((entry) {\n                final groupKey=entry.key;\n                final items=entry.value;\n",
    'group entries iteration',
)

old_header = "                        Row(\n                          mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                          children: [\n                            Text(\n                              meal.isEmpty ? 'Прийом їжі' : meal,\n                              style: const TextStyle(\n                                fontSize: 18,\n                                fontWeight: FontWeight.bold,\n                              ),\n                            ),\n                            Text(time),\n                          ],\n                        ),\n"
new_header = "                        MealHeaderMenu(\n                          meal:meal,\n                          time:time,\n                          onEdit:()=>editMealGroup(groupKey,items),\n                          onAddProduct:(){addProductToMealGroup(groupKey,items);},\n                          onDelete:()=>deleteMealGroup(groupKey,items),\n                        ),\n"
replace_once(old_header, new_header, 'meal header row')

if text == original:
    raise SystemExit('No changes produced')
path.write_text(text, encoding='utf-8')
print('Meal header integration applied to lib/main.dart')
