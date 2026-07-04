import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';

/// Placeholder for the camera-based scanner. States per WIREFRAME-SPEC.md:
/// scanning / found / not-found / no-permission. Camera integration is a
/// separate ticket (ATLAS-005) — this establishes the screen + navigation only.
class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  /// Until the camera exists (ATLAS-005), simulated scans use this UPC so the
  /// whole pipeline (history, product, prices) exercises one consistent id.
  static const simulatedUpc = '000000000000';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched (not read) so the lazy auth stream is live before the user
    // taps — a read at tap-time could see null before the first emission.
    final uid = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Scan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 64),
            const SizedBox(height: 12),
            const Text('Point at a barcode'),
            const SizedBox(height: 24),
            // Temporary: simulate a successful scan until camera is wired up.
            ElevatedButton(
              onPressed: () {
                // Record history best-effort — a failed write must never
                // block the scan → product flow (fail gracefully).
                if (uid != null) {
                  ref.read(scanHistoryRepositoryProvider).record(uid, simulatedUpc);
                }
                Navigator.of(context).pushNamed(AppRoutes.product);
              },
              child: const Text('Simulate scan (dev only)'),
            ),
          ],
        ),
      ),
    );
  }
}
