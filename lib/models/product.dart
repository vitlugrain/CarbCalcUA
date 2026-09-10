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
  final List<String> barcodes;
  final String? manufacturer;
  final String? source;
  final String? updatedAt;
  final double? gramsPerPiece;
  final double? gramsPerMl;
  final double? servingGrams;
  final List<String> aliases;
  final String nutritionBasis;
  final List<String> quantityUnits;

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
    this.barcodes = const [],
    this.manufacturer,
    this.source,
    this.updatedAt,
    this.gramsPerPiece,
    this.gramsPerMl,
    this.servingGrams,
    this.aliases = const [],
    this.nutritionBasis = '100g',
    this.quantityUnits = const [],
  });

  List<String> get allBarcodes => <String>{
        if (barcode != null && barcode!.trim().isNotEmpty) barcode!.trim(),
        ...barcodes.map((x) => x.trim()).where((x) => x.isNotEmpty),
      }.toList(growable: false);

  bool get nutritionPer100Ml => nutritionBasis.toLowerCase() == '100ml';

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: '${j['id']}',
        name: _decodeHtmlEntities('${j['name']}'),
        category: _decodeHtmlEntities('${j['category']}'),
        carbs: (j['carbs'] as num).toDouble(),
        protein: ((j['protein'] ?? 0) as num).toDouble(),
        fat: ((j['fat'] ?? 0) as num).toDouble(),
        fiber: ((j['fiber'] ?? 0) as num).toDouble(),
        calories: ((j['calories'] ?? 0) as num).toDouble(),
        state: j['state'] ?? 'raw',
        barcode: _stringOrNull(j['barcode']),
        barcodes: _stringList(j['barcodes']),
        manufacturer: _decodedStringOrNull(j['manufacturer']),
        source: _stringOrNull(j['source']),
        updatedAt: _stringOrNull(j['updatedAt'] ?? j['updated_at']),
        gramsPerPiece: _numberOrNull(j['gramsPerPiece'] ?? j['grams_per_piece']),
        gramsPerMl: _numberOrNull(j['gramsPerMl'] ?? j['grams_per_ml']),
        servingGrams: _numberOrNull(j['servingGrams'] ?? j['serving_grams']),
        aliases: _stringList(j['aliases']),
        nutritionBasis: _stringOrNull(j['nutritionBasis'] ?? j['nutrition_basis']) ?? '100g',
        quantityUnits: _stringList(j['quantityUnits'] ?? j['quantity_units']),
      );

  factory Product.fromCustomDb(Map<String, dynamic> j) => Product(
        id: '${j['id']}',
        name: _decodeHtmlEntities('${j['name']}'),
        category: _decodeHtmlEntities('${j['category']}'),
        carbs: (j['carbs'] as num).toDouble(),
        protein: ((j['protein'] ?? 0) as num).toDouble(),
        fat: ((j['fat'] ?? 0) as num).toDouble(),
        fiber: ((j['fiber'] ?? 0) as num).toDouble(),
        calories: ((j['calories'] ?? 0) as num).toDouble(),
        state: j['state'] ?? 'raw',
        barcode: _stringOrNull(j['barcode']),
        barcodes: _stringList(j['barcodes']),
        manufacturer: _decodedStringOrNull(j['manufacturer']),
        source: _stringOrNull(j['source']),
        updatedAt: _stringOrNull(j['updated_at'] ?? j['updatedAt']),
        gramsPerPiece: _numberOrNull(j['grams_per_piece'] ?? j['gramsPerPiece']),
        gramsPerMl: _numberOrNull(j['grams_per_ml'] ?? j['gramsPerMl']),
        servingGrams: _numberOrNull(j['serving_grams'] ?? j['servingGrams']),
        aliases: _stringList(j['aliases']),
        nutritionBasis: _stringOrNull(j['nutrition_basis'] ?? j['nutritionBasis']) ?? '100g',
        quantityUnits: _stringList(j['quantity_units'] ?? j['quantityUnits']),
      );

  static List<String> _stringList(dynamic value) {
    if (value is String) {
      return value.split(',').map((x) => _decodeHtmlEntities(x.trim())).where((x) => x.isNotEmpty).toList(growable: false);
    }
    if (value is! List) return const [];
    return value
        .map((x) => _decodeHtmlEntities(x.toString().trim()))
        .where((x) => x.isNotEmpty)
        .toList(growable: false);
  }

  static double? _numberOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  static String _decodeHtmlEntities(String value) {
    return value
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  static String? _decodedStringOrNull(dynamic value) {
    final s = _stringOrNull(value);
    return s == null ? null : _decodeHtmlEntities(s);
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}
