import '../models/product.dart';

/// Helpers for deciding whether two catalog records describe the same product.
/// Kept separate from UI so barcode/dedup rules can be tested safely.
class ProductIdentityService {
  static String normalizeText(String value) {
    var s = value.toLowerCase();
    const replacements = <String, String>{
      'пепсі': 'pepsi',
      'кока кола': 'coca cola',
      'кока-кола': 'coca cola',
      'зеро': 'zero',
      'без цукру': 'zero',
      'sugar free': 'zero',
      'no sugar': 'zero',
    };
    replacements.forEach((from, to) { s = s.replaceAll(from, to); });
    s = s
        .replaceAll(RegExp(r'\b(напій|напиток|drink|beverage|газований|carbonated)\b'), ' ')
        .replaceAll(RegExp(r'[^a-zа-яіїєґ0-9]+', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return s;
  }

  static String normalizeBrand(String? value) {
    if (value == null) return '';
    return normalizeText(value)
        .replaceAll(RegExp(r'\b(company|co|inc|llc|ltd|тов|прАТ|пат)\b', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool exactBarcodeMatch(Product a, Product b) {
    final codesA = a.allBarcodes.map(_barcode).where((x) => x.isNotEmpty).toSet();
    final codesB = b.allBarcodes.map(_barcode).where((x) => x.isNotEmpty).toSet();
    return codesA.intersection(codesB).isNotEmpty;
  }

  /// Conservative analogue check: intended for barcode scans where the same
  /// drink/product can have several EANs for different package sizes.
  static bool isLikelySameProduct(Product a, Product b) {
    if (exactBarcodeMatch(a, b)) return true;

    final an = normalizeText(a.name);
    final bn = normalizeText(b.name);
    if (an.isEmpty || bn.isEmpty) return false;

    final aZero = _isZeroLike(an);
    final bZero = _isZeroLike(bn);
    if (aZero != bZero) return false;

    final brandA = normalizeBrand(a.manufacturer);
    final brandB = normalizeBrand(b.manufacturer);
    if (brandA.isNotEmpty && brandB.isNotEmpty && brandA != brandB) return false;

    final nameSimilar = an == bn || _tokenSimilarity(an, bn) >= 0.82;
    if (!nameSimilar) return false;

    // Nutrient tolerance prevents e.g. regular Pepsi and a materially different
    // formulation from being silently merged.
    if ((a.carbs - b.carbs).abs() > 1.5) return false;
    if ((a.calories - b.calories).abs() > 12 && a.calories > 0 && b.calories > 0) return false;
    return true;
  }

  static Product? findAnalogue(Product scanned, Iterable<Product> candidates) {
    Product? best;
    double bestScore = -1;
    for (final candidate in candidates) {
      if (candidate.id == scanned.id) continue;
      if (!isLikelySameProduct(scanned, candidate)) continue;
      final score = _tokenSimilarity(normalizeText(scanned.name), normalizeText(candidate.name))
          + (normalizeBrand(scanned.manufacturer).isNotEmpty &&
                  normalizeBrand(scanned.manufacturer) == normalizeBrand(candidate.manufacturer)
              ? 0.25
              : 0)
          - (scanned.carbs - candidate.carbs).abs() / 100;
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }
    return best;
  }

  static Product mergeBarcode(Product existing, String rawBarcode) {
    final code = _barcode(rawBarcode);
    final merged = <String>{...existing.allBarcodes.map(_barcode).where((x) => x.isNotEmpty)};
    if (code.isNotEmpty) merged.add(code);
    final list = merged.toList(growable: false);
    return Product(
      id: existing.id,
      name: existing.name,
      category: existing.category,
      state: existing.state,
      carbs: existing.carbs,
      protein: existing.protein,
      fat: existing.fat,
      fiber: existing.fiber,
      calories: existing.calories,
      barcode: list.isEmpty ? existing.barcode : list.first,
      barcodes: list,
      manufacturer: existing.manufacturer,
      source: existing.source,
      updatedAt: existing.updatedAt,
      gramsPerPiece: existing.gramsPerPiece,
      gramsPerMl: existing.gramsPerMl,
      servingGrams: existing.servingGrams,
      aliases: existing.aliases,
      nutritionBasis: existing.nutritionBasis,
      quantityUnits: existing.quantityUnits,
    );
  }

  static bool _isZeroLike(String normalizedName) =>
      RegExp(r'(^| )(zero|diet)( |$)').hasMatch(normalizedName);

  static String _barcode(String value) => value.replaceAll(RegExp(r'\D'), '');

  static double _tokenSimilarity(String a, String b) {
    final aa = a.split(' ').where((x) => x.isNotEmpty).toSet();
    final bb = b.split(' ').where((x) => x.isNotEmpty).toSet();
    if (aa.isEmpty || bb.isEmpty) return 0;
    final common = aa.intersection(bb).length.toDouble();
    return (2 * common) / (aa.length + bb.length);
  }
}
