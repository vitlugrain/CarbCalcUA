import 'package:flutter/material.dart';

class MealHeaderEditResult {
  final String meal;
  final DateTime date;
  final String time;

  const MealHeaderEditResult({
    required this.meal,
    required this.date,
    required this.time,
  });
}

class MealHeaderMenu extends StatelessWidget {
  final String meal;
  final String time;
  final VoidCallback onAddProduct;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  const MealHeaderMenu({
    super.key,
    required this.meal,
    required this.time,
    required this.onAddProduct,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.isEmpty ? 'Прийом їжі' : meal,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (time.isNotEmpty)
                Text(time, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Дії з прийомом їжі',
          onSelected: (value) async {
            switch (value) {
              case 'add':
                onAddProduct();
                break;
              case 'edit':
                await onEdit();
                break;
              case 'delete':
                await onDelete();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'add',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.add),
                title: Text('Додати продукт'),
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_outlined),
                title: Text('Змінити прийом'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_outline),
                title: Text('Видалити прийом'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<MealHeaderEditResult?> showMealHeaderEditDialog(
  BuildContext context, {
  required String initialMeal,
  required DateTime initialDate,
  required String initialTime,
}) async {
  var meal = initialMeal.isEmpty ? 'Сніданок' : initialMeal;
  var date = initialDate;
  var time = initialTime.isEmpty
      ? TimeOfDay.now()
      : TimeOfDay(
          hour: int.tryParse(initialTime.split(':').first) ?? TimeOfDay.now().hour,
          minute: int.tryParse(initialTime.split(':').last) ?? TimeOfDay.now().minute,
        );

  return showDialog<MealHeaderEditResult>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Змінити прийом їжі'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: meal,
              decoration: const InputDecoration(
                labelText: 'Тип прийому',
                border: OutlineInputBorder(),
              ),
              items: const ['Сніданок', 'Обід', 'Вечеря', 'Перекус']
                  .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => meal = value);
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: date,
                  locale: const Locale('uk'),
                );
                if (picked != null) setState(() => date = picked);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null) setState(() => time = picked);
              },
              icon: const Icon(Icons.schedule),
              label: Text(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              MealHeaderEditResult(
                meal: meal,
                date: date,
                time:
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              ),
            ),
            child: const Text('Зберегти'),
          ),
        ],
      ),
    ),
  );
}

Future<bool> confirmDeleteMeal(BuildContext context, String meal) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Видалити весь прийом їжі?'),
          content: Text(
            'Усі продукти з «${meal.isEmpty ? 'Прийом їжі' : meal}» будуть видалені. Цю дію не можна скасувати.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Видалити'),
            ),
          ],
        ),
      ) ??
      false;
}
