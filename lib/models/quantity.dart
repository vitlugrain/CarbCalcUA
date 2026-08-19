enum QuantityUnit { grams, milliliters, pieces, portion }

extension QuantityUnitLabel on QuantityUnit {
  String get label {
    switch (this) {
      case QuantityUnit.grams: return 'г';
      case QuantityUnit.milliliters: return 'мл';
      case QuantityUnit.pieces: return 'шт';
      case QuantityUnit.portion: return 'порція';
    }
  }
}

class Quantity {
  final double value;
  final QuantityUnit unit;
  const Quantity(this.value, this.unit);

  String get display => '${_fmt(value)} ${unit.label}';
  static String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
