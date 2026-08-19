class Product {
  final String id;
  final String name;
  final String category;
  final String state;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;
  final double calories;
  final String? barcode;
  final String? manufacturer;
  final String? source;
  final String? updatedAt;
  final double? gramsPerPiece;
  final double? gramsPerMl;
  final double? servingGrams;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.carbs,
    this.protein = 0,
    this.fat = 0,
    this.fiber = 0,
    this.calories = 0,
    this.state = 'raw',
    this.barcode,
    this.manufacturer,
    this.source,
    this.updatedAt,
    this.gramsPerPiece,
    this.gramsPerMl,
    this.servingGrams,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: '${j['id']}',
        name: '${j['name']}',
        category: '${j['category']}',
        carbs: (j['carbs'] as num).toDouble(),
        protein: ((j['protein'] ?? 0) as num).toDouble(),
        fat: ((j['fat'] ?? 0) as num).toDouble(),
        fiber: ((j['fiber'] ?? 0) as num).toDouble(),
        calories: ((j['calories'] ?? 0) as num).toDouble(),
        state: j['state'] ?? 'raw',
        barcode: _stringOrNull(j['barcode']),
        manufacturer: _stringOrNull(j['manufacturer']),
        source: _stringOrNull(j['source']),
        updatedAt: _stringOrNull(j['updatedAt'] ?? j['updated_at']),
        gramsPerPiece: _numberOrNull(j['gramsPerPiece'] ?? j['grams_per_piece']),
        gramsPerMl: _numberOrNull(j['gramsPerMl'] ?? j['grams_per_ml']),
        servingGrams: _numberOrNull(j['servingGrams'] ?? j['serving_grams']),
      );

  factory Product.fromCustomDb(Map<String, dynamic> j) => Product(
        id: '${j['id']}',
        name: '${j['name']}',
        category: '${j['category']}',
        carbs: (j['carbs'] as num).toDouble(),
        protein: (j['protein'] as num).toDouble(),
        fat: (j['fat'] as num).toDouble(),
        fiber: (j['fiber'] as num).toDouble(),
        calories: (j['calories'] as num).toDouble(),
        barcode: _stringOrNull(j['barcode']),
        manufacturer: _stringOrNull(j['manufacturer']),
        source: _stringOrNull(j['source']),
        updatedAt: _stringOrNull(j['updated_at']),
        gramsPerPiece: _numberOrNull(j['grams_per_piece']),
        gramsPerMl: _numberOrNull(j['grams_per_ml']),
        servingGrams: _numberOrNull(j['serving_grams']),
      );

  static double? _numberOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}
