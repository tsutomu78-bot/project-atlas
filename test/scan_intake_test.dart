import 'package:flutter_test/flutter_test.dart';

import 'package:project_atlas/scanning/scan_intake.dart';

void main() {
  group('normalizeScannedCode', () {
    test('pads 12-digit UPC-A to the 13-digit pipeline id', () {
      expect(normalizeScannedCode('111042850016'), '0111042850016');
    });

    test('keeps 13-digit EAN-13 as-is', () {
      expect(normalizeScannedCode('0001111042850'), '0001111042850');
    });

    test('trims surrounding whitespace', () {
      expect(normalizeScannedCode(' 0001111042850 '), '0001111042850');
    });

    test('rejects null, wrong lengths, and non-digits', () {
      expect(normalizeScannedCode(null), isNull);
      expect(normalizeScannedCode(''), isNull);
      expect(normalizeScannedCode('12345'), isNull); // too short
      expect(normalizeScannedCode('12345678901234'), isNull); // too long
      expect(normalizeScannedCode('000111104285x'), isNull); // non-digit
    });
  });

  group('ScanDeduper', () {
    final t0 = DateTime(2026, 7, 12, 12, 0, 0);

    test('accepts a first detection', () {
      expect(ScanDeduper().accept('0001111042850', t0), isTrue);
    });

    test('rejects the same code within the window', () {
      final deduper = ScanDeduper();
      deduper.accept('0001111042850', t0);
      expect(
          deduper.accept(
              '0001111042850', t0.add(const Duration(seconds: 1))),
          isFalse);
    });

    test('window slides while the camera stays on the same code', () {
      final deduper = ScanDeduper();
      deduper.accept('0001111042850', t0);
      // Frames every 2s: each is within 3s of the previous, so all rejected
      // even though the last is >3s after the first accept.
      expect(deduper.accept('0001111042850', t0.add(const Duration(seconds: 2))), isFalse);
      expect(deduper.accept('0001111042850', t0.add(const Duration(seconds: 4))), isFalse);
    });

    test('accepts the same code again after the window passes', () {
      final deduper = ScanDeduper();
      deduper.accept('0001111042850', t0);
      expect(
          deduper.accept(
              '0001111042850', t0.add(const Duration(seconds: 4))),
          isTrue);
    });

    test('accepts a different code immediately', () {
      final deduper = ScanDeduper();
      deduper.accept('0001111042850', t0);
      expect(deduper.accept('0111042850016', t0), isTrue);
    });
  });
}
