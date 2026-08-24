import 'package:flutter_test/flutter_test.dart';
import '../lib/services/glucose_import_service.dart';

void main(){
  test('imports semicolon CSV with mmol/L',(){
    final r=GlucoseImportService.fromCsv('Date;Time;Glucose;Unit\n24.08.2026;08:10;5,4;mmol/L\n24.08.2026;10:10;7.2;mmol/L',source:'test');
    expect(r.readings.length,2);
    expect(r.readings.first.valueMmol,closeTo(5.4,0.001));
  });
  test('imports mg/dL and converts to mmol/L',(){
    final r=GlucoseImportService.fromCsv('date,time,glucose,unit\n2026-08-24,08:10,108,mg/dL',source:'test');
    expect(r.readings.length,1);
    expect(r.readings.first.valueMmol,closeTo(6.0,0.01));
  });
  test('parses PDF-like text',(){
    final r=GlucoseImportService.fromPdfText('24.08.2026 08:10 5.4 mmol/L\n24.08.2026 10:10 126 mg/dL',source:'test');
    expect(r.readings.length,2);
    expect(r.readings.last.valueMmol,closeTo(7.0,0.01));
  });
}
