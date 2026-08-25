import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class GlucoseReading {
  final DateTime timestamp;
  final double valueMmol;
  final String? source;
  final String? originalUnit;
  const GlucoseReading({required this.timestamp, required this.valueMmol, this.source, this.originalUnit});
}

class GlucoseImportResult {
  final List<GlucoseReading> readings;
  final List<String> warnings;
  const GlucoseImportResult(this.readings, this.warnings);
}

/// Універсальний імпорт даних глюкози.
/// CSV є основним форматом; PDF підтримується як best-effort розбір тексту.
class GlucoseImportService {
  static GlucoseImportResult fromCsv(String text, {String? source}) {
    final trimmed = text.replaceFirst('\ufeff', '').trim();
    if (trimmed.isEmpty) return const GlucoseImportResult([], ['CSV-файл порожній.']);

    final lines = trimmed.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const GlucoseImportResult([], ['У CSV не знайдено рядків.']);

    final delimiter = _detectDelimiter(lines.first);
    final rows = <List<String>>[];
    for (final line in lines) {
      rows.add(_splitCsvLine(line, delimiter));
    }
    if (rows.isEmpty) return const GlucoseImportResult([], ['У CSV не знайдено рядків.']);

    final header = rows.first.map(_norm).toList();
    final dateIdx = _findHeader(header, ['date', 'дата', 'datetime', 'timestamp', 'date time']);
    final timeIdx = _findHeader(header, ['time', 'час']);
    final glucoseIdx = _findHeader(header, ['glucose', 'глюкоза', 'blood glucose', 'blood glucose level', 'value', 'result', 'результат', 'measurement']);
    final unitIdx = _findHeader(header, ['unit', 'units', 'одиниця', 'единица']);

    final warnings = <String>[];
    if (dateIdx < 0 && timeIdx < 0) warnings.add('Не знайдено колонку з датою/часом.');
    if (glucoseIdx < 0) warnings.add('Не знайдено колонку з показником глюкози.');
    if (glucoseIdx < 0) return GlucoseImportResult([], warnings);

    final out = <GlucoseReading>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      final rawDate = dateIdx >= 0 && dateIdx < row.length ? row[dateIdx] : '';
      final rawTime = timeIdx >= 0 && timeIdx < row.length ? row[timeIdx] : '';
      final dt = _parseDateTime(rawDate, rawTime);
      final rawValue = glucoseIdx < row.length ? row[glucoseIdx] : '';
      final unit = unitIdx >= 0 && unitIdx < row.length ? row[unitIdx] : null;
      final value = _parseNumber(rawValue);
      if (dt == null || value == null || value <= 0) {
        warnings.add('Пропущено рядок ${i + 1}: не вдалося розпізнати дату/глюкозу.');
        continue;
      }
      final mmol = _toMmol(value, unit ?? _guessUnit(value));
      if (mmol == null || mmol < 1 || mmol > 50) {
        warnings.add('Пропущено рядок ${i + 1}: значення поза очікуваним діапазоном.');
        continue;
      }
      out.add(GlucoseReading(timestamp: dt, valueMmol: mmol, source: source, originalUnit: unit));
    }
    return GlucoseImportResult(out, warnings);
  }

  static List<String> _splitCsvLine(String line, String delimiter) {
    final result = <String>[];
    final buffer = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (quoted && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (ch == delimiter && !quoted) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }

  static GlucoseImportResult fromPdf(Uint8List bytes, {String? source}) {
    final doc = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(doc).extractText();
    doc.dispose();
    return fromPdfText(text, source: source);
  }

  static GlucoseImportResult fromPdfText(String text, {String? source}) {
    final warnings = <String>[];
    final out = <GlucoseReading>[];
    final dateRe = RegExp(r'(\d{1,4}[./-]\d{1,2}[./-]\d{1,4})(?:\s+|[,;|]\s*)(\d{1,2}:\d{2}(?::\d{2})?)?');
    final valueRe = RegExp(r'(?<!\d)(\d{1,3}(?:[.,]\d{1,2})?)(?:\s*)(mmol\s*/?\s*l|mmol/l|mg\s*/?\s*dl|mg/dl)?', caseSensitive: false);
    for (final line in text.split(RegExp(r'\r?\n'))) {
      final dm = dateRe.firstMatch(line);
      if (dm == null) continue;
      final vm = valueRe.allMatches(line).toList();
      if (vm.isEmpty) continue;
      Match? chosen;
      for (final m in vm.reversed) {
        final v = _parseNumber(m.group(1)!);
        if (v != null && v >= 1 && v <= 700) {
          chosen = m;
          break;
        }
      }
      if (chosen == null) continue;
      final dt = _parseDateTime(dm.group(1)!, dm.group(2) ?? '');
      final value = _parseNumber(chosen.group(1)!);
      if (dt == null || value == null) continue;
      final unit = chosen.group(2);
      final mmol = _toMmol(value, unit ?? _guessUnit(value));
      if (mmol == null || mmol < 1 || mmol > 50) continue;
      out.add(GlucoseReading(timestamp: dt, valueMmol: mmol, source: source, originalUnit: unit));
    }
    if (out.isEmpty) warnings.add('У PDF не знайдено однозначних рядків з датою та глюкозою. Спробуйте CSV, якщо він доступний.');
    return GlucoseImportResult(out, warnings);
  }

  static String _detectDelimiter(String line) {
    final commas = ','.allMatches(line).length;
    final semis = ';'.allMatches(line).length;
    final tabs = '\t'.allMatches(line).length;
    if (tabs >= commas && tabs >= semis) return '\t';
    return semis > commas ? ';' : ',';
  }

  static int _findHeader(List<String> header, List<String> names) {
    for (final name in names) {
      final normalized = _norm(name);
      for (var i = 0; i < header.length; i++) {
        if (header[i] == normalized || header[i].contains(normalized)) return i;
      }
    }
    return -1;
  }

  static String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[_\-]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  static double? _parseNumber(String s) {
    final m = RegExp(r'-?\d+(?:[.,]\d+)?').firstMatch(s.replaceAll('\u00a0', ' '));
    return m == null ? null : double.tryParse(m.group(0)!.replaceAll(',', '.'));
  }

  static DateTime? _parseDateTime(String date, String time) {
    final d = date.trim();
    final t = time.trim();
    if (d.isEmpty && t.isEmpty) return null;
    final m = RegExp(r'^(\d{1,4})[./-](\d{1,2})[./-](\d{1,4})').firstMatch(d);
    if (m == null) return DateTime.tryParse(d);
    final a = int.parse(m.group(1)!);
    final b = int.parse(m.group(2)!);
    final c = int.parse(m.group(3)!);
    final int y, mo, day;
    if (a >= 1900) {
      y = a;
      mo = b;
      day = c;
    } else {
      day = a;
      mo = b;
      y = c < 100 ? 2000 + c : c;
    }
    final tm = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?').firstMatch(t);
    return DateTime(y, mo, day, tm == null ? 0 : int.parse(tm.group(1)!), tm == null ? 0 : int.parse(tm.group(2)!), tm == null ? 0 : int.parse(tm.group(3) ?? '0'));
  }

  static String _guessUnit(double value) => value > 35 ? 'mg/dL' : 'mmol/L';

  static double? _toMmol(double value, String unit) {
    final u = _norm(unit);
    if (u.contains('mg')) return value / 18.0;
    if (u.contains('mmol')) return value;
    return _guessUnit(value).contains('mg') ? value / 18.0 : value;
  }
}
