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

  factory Product.fromJson(Map<String, dynamic> j) {
    final id = '${j['id']}';
    return Product(
      id: id,
      name: _decodeHtmlEntities('${j['name']}'),
      category: _decodeHtmlEntities('${j['category']}'),
      carbs: _requiredNumber(j['carbs'], field: 'carbs', productId: id),
      protein: _numberOrZero(j['protein'], field: 'protein', productId: id),
      fat: _numberOrZero(j['fat'], field: 'fat', productId: id),
      fiber: _numberOrZero(j['fiber'], field: 'fiber', productId: id),
      calories: _numberOrZero(j['calories'], field: 'calories', productId: id),
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
  }

  factory Product.fromCustomDb(Map<String, dynamic> j) {
    final id = '${j['id']}';
    return Product(
      id: id,
      name: _decodeHtmlEntities('${j['name']}'),
      category: _decodeHtmlEntities('${j['category']}'),
      carbs: _requiredNumber(j['carbs'], field: 'carbs', productId: id),
      protein: _numberOrZero(j['protein'], field: 'protein', productId: id),
      fat: _numberOrZero(j['fat'], field: 'fat', productId: id),
      fiber: _numberOrZero(j['fiber'], field: 'fiber', productId: id),
      calories: _numberOrZero(j['calories'], field: 'calories', productId: id),
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
  }

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
    final normalized = value.toString().trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  static double _requiredNumber(dynamic value, {required String field, required String productId}) {
    final parsed = _numberOrNull(value);
    if (parsed == null) {
      throw FormatException('Invalid or missing $field for product $productId: $value');
    }
    return parsed;
  }

  static double _numberOrZero(dynamic value, {required String field, required String productId}) {
    if (value == null || value.toString().trim().isEmpty) return 0;
    final parsed = _numberOrNull(value);
    if (parsed == null) {
      throw FormatException('Invalid $field for product $productId: $value');
    }
    return parsed;
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
