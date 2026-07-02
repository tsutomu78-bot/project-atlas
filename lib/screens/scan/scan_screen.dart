import 'package:flutter/material.dart';
import '../../routing/app_router.dart';

/// Placeholder for the camera-based scanner. States per WIREFRAME-SPEC.md:
/// scanning / found / not-found / no-permission. Camera integration is a
/// separate ticket (ATLAS-005) — this establishes the screen + navigation only.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.product),
              child: const Text('Simulate scan (dev only)'),
            ),
          ],
        ),
      ),
    );
  }
}
