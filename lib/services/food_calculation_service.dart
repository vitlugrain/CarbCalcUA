import '../models/product.dart';
import '../models/quantity.dart';

class FoodCalculationResult {
  final double grams;
  final double carbs;
  final double xe;
  const FoodCalculationResult({required this.grams, required this.carbs, required this.xe});
}

/// Єдина математична точка для перетворення введеної кількості у грами
/// та розрахунку вуглеводів/ХО. Тут немає жодних рекомендацій щодо інсуліну.
class FoodCalculationService {
  static double? toGrams(Product product, Quantity quantity) {
    switch (quantity.unit) {
      case QuantityUnit.grams:
        return quantity.value;
      case QuantityUnit.milliliters:
        final k = product.gramsPerMl;
        return k == null ? null : quantity.value * k;
      case QuantityUnit.pieces:
        final k = product.gramsPerPiece;
        return k == null ? null : quantity.value * k;
      case QuantityUnit.portion:
        final k = product.servingGrams;
        return k == null ? null : quantity.value * k;
    }
  }

  static double? _nutritionBaseAmount(Product product, Quantity quantity, double grams) {
    if (!product.nutritionPer100Ml) return grams;

    switch (quantity.unit) {
      case QuantityUnit.milliliters:
        return quantity.value;
      case QuantityUnit.grams:
        final density = product.gramsPerMl;
        return density == null || density <= 0 ? null : grams / density;
      case QuantityUnit.pieces:
      case QuantityUnit.portion:
        final density = product.gramsPerMl;
        return density == null || density <= 0 ? null : grams / density;
    }
  }

  static FoodCalculationResult? calculate({
    required Product product,
    required Quantity quantity,
    required double xeGrams,
  }) {
    final grams = toGrams(product, quantity);
    if (grams == null || grams < 0) return null;
    final baseAmount = _nutritionBaseAmount(product, quantity, grams);
    if (baseAmount == null || baseAmount < 0) return null;
    final carbs = (baseAmount * product.carbs / 100).toDouble();
    final xe = xeGrams > 0 ? (carbs / xeGrams).toDouble() : 0.0;
    return FoodCalculationResult(grams: grams, carbs: carbs, xe: xe);
  }
}
