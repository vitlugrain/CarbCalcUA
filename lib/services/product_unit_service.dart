import '../models/product.dart';
import '../models/quantity.dart';

/// Maps product metadata to the units that should be offered in the UI.
/// Explicit `quantityUnits` wins; legacy weight metadata remains supported.
class ProductUnitService {
  static List<QuantityUnit> unitsFor(Product product) {
    final explicit = product.quantityUnits
        .map(_fromToken)
        .whereType<QuantityUnit>()
        .toSet();

    if (explicit.isNotEmpty) {
      final ordered = <QuantityUnit>[];
      for (final unit in const [
        QuantityUnit.grams,
        QuantityUnit.milliliters,
        QuantityUnit.pieces,
        QuantityUnit.portion,
      ]) {
        if (explicit.contains(unit)) ordered.add(unit);
      }
      return ordered;
    }

    final units = <QuantityUnit>[
      product.nutritionPer100Ml
          ? QuantityUnit.milliliters
          : QuantityUnit.grams,
    ];

    // Backward compatibility for old catalog rows that predate quantityUnits.
    if (!product.nutritionPer100Ml && product.gramsPerMl != null) {
      units.add(QuantityUnit.milliliters);
    }
    if (product.gramsPerPiece != null) units.add(QuantityUnit.pieces);
    if (product.servingGrams != null) units.add(QuantityUnit.portion);
    return units.toSet().toList(growable: false);
  }

  static String nutritionBasisLabel(Product product) =>
      product.nutritionPer100Ml ? '100 мл' : '100 г';

  static QuantityUnit? _fromToken(String raw) {
    final token = raw.toLowerCase().trim().replaceAll('.', '');
    switch (token) {
      case 'g':
      case 'г':
      case 'gram':
      case 'grams':
      case 'грам':
      case 'грами':
        return QuantityUnit.grams;
      case 'ml':
      case 'мл':
      case 'milliliter':
      case 'milliliters':
        return QuantityUnit.milliliters;
      case 'piece':
      case 'pieces':
      case 'pcs':
      case 'шт':
      case 'штука':
      case 'штуки':
        return QuantityUnit.pieces;
      case 'portion':
      case 'serving':
      case 'порція':
      case 'порц':
        return QuantityUnit.portion;
      default:
        return null;
    }
  }
}
