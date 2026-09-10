import '../models/product.dart';
import '../models/quantity.dart';

class FoodCalculationResult {
  /// Physical mass when it is known. For a liquid entered directly in ml,
  /// this can legitimately be null when no measured density is available.
  final double? grams;

  /// Amount used against the nutrition label basis: grams for a 100g product,
  /// milliliters for a 100ml product.
  final double nutritionAmount;
  final QuantityUnit nutritionUnit;
  final double carbs;
  final double xe;

  const FoodCalculationResult({
    required this.grams,
    required this.nutritionAmount,
    required this.nutritionUnit,
    required this.carbs,
    required this.xe,
  });
}

/// Єдина математична точка для перетворення введеної кількості та розрахунку
/// вуглеводів/ХО. Тут немає жодних рекомендацій щодо інсуліну.
class FoodCalculationService {
  static double? toGrams(Product product, Quantity quantity) {
    switch (quantity.unit) {
      case QuantityUnit.grams:
        return quantity.value;
      case QuantityUnit.milliliters:
        final k = product.gramsPerMl;
        return k == null || k <= 0 ? null : quantity.value * k;
      case QuantityUnit.pieces:
        final k = product.gramsPerPiece;
        return k == null || k <= 0 ? null : quantity.value * k;
      case QuantityUnit.portion:
        final k = product.servingGrams;
        return k == null || k <= 0 ? null : quantity.value * k;
    }
  }

  static FoodCalculationResult? calculate({
    required Product product,
    required Quantity quantity,
    required double xeGrams,
  }) {
    if (quantity.value < 0) return null;

    double? grams;
    double nutritionAmount;
    QuantityUnit nutritionUnit;

    if (product.nutritionPer100Ml) {
      nutritionUnit = QuantityUnit.milliliters;

      if (quantity.unit == QuantityUnit.milliliters) {
        // A label expressed per 100 ml can be calculated directly from the
        // entered volume. Do not invent a 1 g/ml density just to fill `grams`.
        nutritionAmount = quantity.value;
        grams = toGrams(product, quantity);
      } else {
        grams = toGrams(product, quantity);
        if (grams == null) return null;
        final density = product.gramsPerMl;
        if (density == null || density <= 0) return null;
        nutritionAmount = grams / density;
      }
    } else {
      nutritionUnit = QuantityUnit.grams;
      grams = toGrams(product, quantity);
      if (grams == null) return null;
      nutritionAmount = grams;
    }

    final carbs = (nutritionAmount * product.carbs / 100).toDouble();
    final xe = xeGrams > 0 ? (carbs / xeGrams).toDouble() : 0.0;

    return FoodCalculationResult(
      grams: grams,
      nutritionAmount: nutritionAmount,
      nutritionUnit: nutritionUnit,
      carbs: carbs,
      xe: xe,
    );
  }
}
