// Pure helpers between the camera and the product pipeline — no Flutter or
// plugin imports so they stay trivially unit-testable (ATLAS-005 DoD).

/// Normalizes a raw scanner detection into the 13-digit zero-padded id used
/// as products/{id} everywhere downstream (Firestore, Kroger lookups).
///
/// UPC-A yields 12 digits and EAN-13 yields 13 — anything else is not a code
/// this app understands, so return null and let the UI show its honest
/// not-found state rather than inventing a product id.
String? normalizeScannedCode(String? raw) {
  final code = raw?.trim();
  if (code == null) return null;
  if (code.length != 12 && code.length != 13) return null;
  if (!RegExp(r'^\d+$').hasMatch(code)) return null;
  return code.padLeft(13, '0');
}

/// Suppresses repeat detections of the same code: cameras emit several
/// frames per second, so one physical scan arrives as a burst.
class ScanDeduper {
  ScanDeduper({this.window = const Duration(seconds: 3)});

  final Duration window;
  String? _lastCode;
  DateTime? _lastAt;

  /// True if [code] should be processed now. The window slides on every
  /// rejected repeat, so holding the camera on one item never re-triggers —
  /// moving away for [window] (or scanning a different code) resets it.
  bool accept(String code, DateTime now) {
    final isRepeat = code == _lastCode &&
        _lastAt != null &&
        now.difference(_lastAt!) < window;
    _lastCode = code;
    _lastAt = now;
    return !isRepeat;
  }
}
