import '../models/product.dart';
import 'barcode_service.dart';
import 'dart:math' as math;

enum ParsedQuantityUnit { grams, milliliters, pieces, portion }

class ParsedFoodQuery {
  final String original;
  final String productQuery;
  final double? amount;
  final ParsedQuantityUnit? unit;
  const ParsedFoodQuery({required this.original, required this.productQuery, this.amount, this.unit});
}

class FoodSearchResult {
  final Product product;
  final double score;
  const FoodSearchResult(this.product, this.score);
}

/// Український пошук продуктів для Smart Food Search.
///
/// Принцип: пошук може бути нечітким, але харчовий стан/спосіб приготування
/// має отримувати додаткову вагу. Якщо запит "гречка" — показуємо варіанти.
/// Якщо "гречка варена на воді" — відповідний запис повинен бути першим.
class FoodSearchService {
  static ParsedFoodQuery parseQuery(String input) {
    final original = input.trim();
    if (original.isEmpty) {
      return const ParsedFoodQuery(original: '', productQuery: '');
    }

    final normalized = original
        .replaceAll(RegExp(r'(?<=\d),(?=\d)'), '.')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Основний сценарій: "150 г гречки" / "2 шт печива".
    final leading = RegExp(
      r'^\s*(\d+(?:\.\d+)?)\s*(г|гр|грам(?:а|ів)?|мл|мл\.?|шт|штук(?:а|и)?|порц(?:ія|ії|ію)?)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (leading != null) {
      return ParsedFoodQuery(
        original: original,
        productQuery: leading.group(3)!.trim(),
        amount: double.tryParse(leading.group(1)!),
        unit: _unitFromText(leading.group(2)!),
      );
    }

    // Дозволяємо природний порядок: "печиво Марія 2 шт".
    final trailing = RegExp(
      r'^(.+?)\s+(\d+(?:\.\d+)?)\s*(г|гр|грам(?:а|ів)?|мл|мл\.?|шт|штук(?:а|и)?|порц(?:ія|ії|ію)?)\s*$',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (trailing != null) {
      return ParsedFoodQuery(
        original: original,
        productQuery: trailing.group(1)!.trim(),
        amount: double.tryParse(trailing.group(2)!),
        unit: _unitFromText(trailing.group(3)!),
      );
    }

    return ParsedFoodQuery(original: original, productQuery: original);
  }

  static ParsedQuantityUnit? _unitFromText(String text) {
    final t = normalize(text);
    if (t == 'г' || t.startsWith('грам')) return ParsedQuantityUnit.grams;
    if (t == 'мл') return ParsedQuantityUnit.milliliters;
    if (t == 'шт' || t.startsWith('штук')) return ParsedQuantityUnit.pieces;
    if (t.startsWith('порц')) return ParsedQuantityUnit.portion;
    return null;
  }

  static String normalize(String text) {
    var s = text.toLowerCase().trim();
    const replacements = {
      'ґ': 'г',
      'ё': 'е',
      '’': '',
      "'": '',
      '`': '',
      '–': ' ',
      '—': ' ',
    };
    replacements.forEach((a, b) => s = s.replaceAll(a, b));
    s = s.replaceAll(RegExp(r'[^a-zа-яіїє0-9]+'), ' ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Перетворює українські словоформи на пошукову основу.
  /// Це не повний морфологічний аналізатор: він навмисно консервативний,
  /// щоб не "склеювати" різні продукти.
  static String stem(String token) {
    var t = normalize(token);
    if (t.isEmpty) return t;

    const aliases = <String, String>{
      'гречки': 'гречк',
      'гречку': 'гречк',
      'гречкою': 'гречк',
      'гречці': 'гречк',
      'варена': 'варен',
      'варене': 'варен',
      'варені': 'варен',
      'варену': 'варен',
      'вареної': 'варен',
      'вареній': 'варен',
      'вареним': 'варен',
      'варених': 'варен',
      'суха': 'сух',
      'сухе': 'сух',
      'сухі': 'сух',
      'суху': 'сух',
      'сухої': 'сух',
      'сирий': 'сир',
      'сира': 'сир',
      'сире': 'сир',
      'сирі': 'сир',
      'сиру': 'сир',
      'свіже': 'свіж',
      'свіжа': 'свіж',
      'свіжий': 'свіж',
      'свіжі': 'свіж',
      'печива': 'печив',
      'печиво': 'печив',
      'печивом': 'печив',
      'молоці': 'молок',
      'молоком': 'молок',
      'молочний': 'молоч',
      'молочна': 'молоч',
      'молочне': 'молоч',
      'воді': 'вод',
      'водою': 'вод',
      'водний': 'вод',
      'рису': 'рис',
      'рисом': 'рис',
      'картоплі': 'картопл',
      'картоплю': 'картопл',
      'картоплею': 'картопл',
      'моркви': 'моркв',
      'моркву': 'моркв',
      'банана': 'банан',
      'банану': 'банан',
      'яблука': 'яблук',
      'яблуко': 'яблук',
      'яблуці': 'яблук',
    };
    final alias = aliases[t];
    if (alias != null) return alias;

    // Консервативні закінчення для найтиповіших родів/відмінків.
    const suffixes = [
      'ами', 'ями', 'ого', 'ому', 'ими', 'ими', 'ій', 'ою', 'ею', 'ам',
      'ям', 'ах', 'ях', 'ів', 'їв', 'ом', 'ем', 'ові', 'еві', 'і', 'и', 'у', 'а', 'я', 'ою', 'ою'
    ];
    for (final suffix in suffixes) {
      if (t.length > suffix.length + 3 && t.endsWith(suffix)) {
        return t.substring(0, t.length - suffix.length);
      }
    }
    return t;
  }

  /// Базовий українсько-англійський словник для пошуку в USDA.
  /// Українські локальні продукти залишаються пріоритетними, а ці терміни
  /// лише розширюють запит для англомовних записів USDA.
  static const Map<String, List<String>> _ukToUsda = {
    'хліб': ['bread'],
    'батон': ['bread', 'loaf'],
    'булк': ['bread', 'roll'],
    'яйц': ['egg'],
    'рис': ['rice'],
    'гречк': ['buckwheat'],
    'вівсянк': ['oatmeal', 'oats'],
    'вівсян': ['oat', 'oats'],
    'пластівц': ['flakes'],
    'макарон': ['pasta', 'macaroni', 'noodles'],
    'локшин': ['noodles'],
    'картопл': ['potato'],
    'моркв': ['carrot'],
    'буряк': ['beet'],
    'капуст': ['cabbage'],
    'помідор': ['tomato'],
    'томат': ['tomato'],
    'огірок': ['cucumber'],
    'цибул': ['onion'],
    'часник': ['garlic'],
    'гарбуз': ['pumpkin'],
    'кабачок': ['squash', 'zucchini'],
    'баклажан': ['eggplant'],
    'кукурудз': ['corn'],
    'горох': ['peas'],
    'квасол': ['beans'],
    'сочевиц': ['lentils'],
    'нут': ['chickpeas', 'garbanzo'],
    'яблук': ['apple'],
    'груш': ['pear'],
    'банан': ['banana'],
    'апельсин': ['orange'],
    'мандарин': ['tangerine', 'mandarin'],
    'лимон': ['lemon'],
    'виноград': ['grapes'],
    'полуниц': ['strawberry'],
    'малин': ['raspberry'],
    'чорниц': ['blueberry'],
    'слив': ['plum'],
    'персик': ['peach'],
    'абрикос': ['apricot'],
    'кавун': ['watermelon'],
    'дин': ['melon'],
    'авокадо': ['avocado'],
    'молок': ['milk'],
    'кефір': ['kefir'],
    'йогурт': ['yogurt'],
    'сметан': ['sour cream'],
    'вершк': ['cream'],
    'масл': ['butter'],
    'сир': ['cheese'],
    'творог': ['cottage cheese'],
    'кисломолоч': ['cottage cheese'],
    'курк': ['chicken'],
    'індич': ['turkey'],
    'ялович': ['beef'],
    'свинин': ['pork'],
    'риб': ['fish'],
    'лосос': ['salmon'],
    'тунец': ['tuna'],
    'оселед': ['herring'],
    'кревет': ['shrimp'],
    'печив': ['cookie', 'cookies'],
    'шоколад': ['chocolate'],
    'цукер': ['candy'],
    'цукор': ['sugar'],
    'мед': ['honey'],
    'борошн': ['flour'],
    'манк': ['semolina'],
    'пшон': ['millet'],
    'перлов': ['barley'],
    'ячн': ['barley'],
    'булгур': ['bulgur'],
    'кускус': ['couscous'],
    'кіноа': ['quinoa'],
    'мигдал': ['almond'],
    'арахіс': ['peanut'],
    'горіх': ['nut', 'nuts'],
    'насін': ['seed', 'seeds'],
  };

  static List<String> _translatedTokens(List<String> queryTokens) {
    final out = <String>[];
    for (final token in queryTokens) {
      for (final entry in _ukToUsda.entries) {
        if (token == entry.key || token.startsWith(entry.key) || entry.key.startsWith(token)) {
          for (final phrase in entry.value) {
            out.addAll(normalize(phrase).split(' ').where((x) => x.isNotEmpty));
          }
        }
      }
    }
    return out.toSet().toList();
  }

  static List<String> _tokens(String text) {
    const stop = {
      'і', 'й', 'та', 'на', 'з', 'зі', 'із', 'у', 'в', 'для', 'по', 'до',
      'або', 'шт', 'г', 'гр', 'мл', 'порція', 'порції', 'порцію'
    };
    return normalize(text)
        .split(' ')
        .where((x) => x.length >= 2 && !stop.contains(x))
        .map(stem)
        .where((x) => x.length >= 2)
        .toList();
  }

  static List<FoodSearchResult> search(String query, List<Product> products, {int limit = 10}) {
    final parsed = parseQuery(query);
    final q = normalize(parsed.productQuery);
    if (q.isEmpty) return [];
    final qTokens = _tokens(q);
    final translatedTokens = _translatedTokens(qTokens);

    final results = <FoodSearchResult>[];
    for (final p in products) {
      final name = normalize(p.name);
      final nameTokens = _tokens(p.name);
      var score = 0.0;

      // Точна назва має максимальний пріоритет.
      if (name == q) score += 160;
      if (name.contains(q)) score += 70;

      // Кожен токен запиту має бути корисним. За повний збіг — більше балів.
      var matched = 0;
      for (final token in qTokens) {
        if (nameTokens.contains(token)) {
          score += 34;
          matched++;
          continue;
        }
        if (nameTokens.any((n) => n.startsWith(token) || token.startsWith(n))) {
          score += 18;
          matched++;
          continue;
        }
        if (_similar(token, nameTokens) >= 0.78) {
          score += 8;
          matched++;
        }
      }

      if (qTokens.isNotEmpty) {
        score += 45 * matched / qTokens.length;
        // Якщо в запиті є уточнення, пропущені токени суттєво знижують результат.
        if (matched < qTokens.length) score -= 20 * (qTokens.length - matched);
      }

      // Для USDA дозволяємо українському запиту збігатися з англійською назвою.
      // Локальні українські назви отримують вищі бали через звичайний точний пошук вище.
      if (translatedTokens.isNotEmpty) {
        var translatedMatched = 0;
        for (final token in translatedTokens) {
          if (nameTokens.contains(token)) {
            score += 24;
            translatedMatched++;
          } else if (nameTokens.any((n) => n.startsWith(token) || token.startsWith(n))) {
            score += 12;
            translatedMatched++;
          }
        }
        if (translatedMatched > 0) score += 18;
      }

      // Додатково ранжуємо харчовий стан і спосіб приготування.
      score += _contextScore(qTokens, nameTokens);

      if (score > 20) results.add(FoodSearchResult(p, score));
    }

    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.product.name.compareTo(b.product.name);
    });
    return results.take(limit).toList();
  }


  /// Єдина точка пошуку за штрихкодом. Спочатку локальні дані, потім зовнішнє джерело.
  static Future<Product?> findByBarcode(String barcode, {CustomProductLookup? customProductLookup}) async {
    return BarcodeService.find(barcode, customProductLookup: customProductLookup);
  }

  static double _contextScore(List<String> query, List<String> name) {
    double score = 0;
    bool has(String s) => query.contains(s);
    bool productHas(String s) => name.contains(s);

    // Якщо користувач явно сказав "варена", не даємо сухому продукту бути першим.
    if (has('варен')) score += productHas('варен') ? 42 : -35;
    if (has('сух')) score += productHas('сух') ? 42 : -35;
    if (has('сир')) score += productHas('сир') ? 38 : -30;
    if (has('свіж')) score += productHas('свіж') ? 32 : -22;
    if (has('вод')) score += productHas('вод') ? 36 : -12;
    if (has('молок')) score += productHas('молок') ? 36 : -12;
    return score;
  }

  static double _similar(String a, List<String> candidates) {
    var best = 0.0;
    for (final b in candidates) {
      final maxLen = math.max(a.length, b.length);
      if (maxLen == 0) continue;
      final d = _levenshtein(a, b);
      best = math.max(best, 1 - d / maxLen);
    }
    return best;
  }

  static int _levenshtein(String a, String b) {
    final prev = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      var left = i + 1;
      var diag = i;
      for (var j = 0; j < b.length; j++) {
        final up = prev[j + 1];
        final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        prev[j + 1] = math.min(math.min(up + 1, left + 1), diag + cost);
        diag = up;
        left = prev[j + 1];
      }
      prev[0] = i + 1;
    }
    return prev[b.length];
  }
}
