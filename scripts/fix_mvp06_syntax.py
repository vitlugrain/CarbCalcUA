from pathlib import Path
import re

p = Path('lib/main.dart')
s = p.read_text()
start = s.index('class DiaryPage extends StatefulWidget')
end = s.index('class RecipesPage extends StatefulWidget')

replacement = r'''class DiaryPage extends StatefulWidget {
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

'''

s = s[:start] + replacement + s[end:]
s = s.replace("import 'dart:typed_data';\n", '')
s = s.replace("import 'services/barcode_service.dart';\n", '')
p.write_text(s)
print('Diary block repaired')
