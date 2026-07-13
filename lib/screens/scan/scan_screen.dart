import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';
import '../../scanning/scan_intake.dart';

/// Camera barcode scanner (ATLAS-005). States per WIREFRAME-SPEC.md:
/// scanning (live camera + guide box) · found (brief checkmark) ·
/// not-found (honest retry, not an error) · no-permission (explain + retry).
///
/// A long-press anywhere simulates a scan of [simulatedUpc] — the dev
/// fallback for camera-less machines; it's also offered as a button whenever
/// the camera itself is unavailable.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  /// Dev-fallback UPC (real cert-env product, Simple Truth Organic Whole
  /// Milk) so simulated scans exercise the whole pipeline with one
  /// consistent id that Kroger actually recognizes.
  static const simulatedUpc = '0001111042850';

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

enum _Phase { scanning, found, notFound }

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _deduper = ScanDeduper();
  MobileScannerController? _controller;
  _Phase _phase = _Phase.scanning;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    // Widget tests disable the camera — MobileScanner needs platform
    // channels that don't exist under flutter_test.
    if (ref.read(scannerCameraEnabledProvider)) {
      _controller = MobileScannerController(
        // The pipeline's product ids are UPC/EAN digits; other symbologies
        // (QR etc.) are out of scope, so don't even detect them.
        formats: const [BarcodeFormat.upcA, BarcodeFormat.ean13],
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_navigating || _phase != _Phase.scanning) return;
    final raw =
        capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    final upc = normalizeScannedCode(raw);
    if (upc == null) {
      // Detected something we can't turn into a product id. Per
      // ENGINEERING-VALUES this is a normal outcome, not an error.
      setState(() => _phase = _Phase.notFound);
      return;
    }
    if (!_deduper.accept(upc, DateTime.now())) return;
    _goToProduct(upc);
  }

  Future<void> _goToProduct(String upc) async {
    if (_navigating) return;
    _navigating = true;
    // Record history and trigger a fresh price lookup best-effort — a
    // failed write must never block the scan → product flow.
    final uid = ref.read(currentUserIdProvider);
    if (uid != null) {
      ref.read(scanHistoryRepositoryProvider).record(uid, upc);
    }
    unawaited(
        ref.read(krogerConnectorProvider).refreshPrice(productId: upc, upc: upc));
    setState(() => _phase = _Phase.found);
    // Brief confirmation per the wireframe's "found" state, and no camera
    // running underneath the product screen.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    unawaited(_controller?.stop());
    await Navigator.of(context)
        .pushNamed(AppRoutes.product, arguments: upc);
    if (!mounted) return;
    unawaited(_controller?.start());
    setState(() {
      _phase = _Phase.scanning;
      _navigating = false;
    });
  }

  void _simulateScan() => _goToProduct(ScanScreen.simulatedUpc);

  @override
  Widget build(BuildContext context) {
    // Watched (not read) so the lazy auth stream is live before a scan
    // lands — a read at detect-time could see null before the first emission.
    ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop()),
        title: const Text('Scan'),
      ),
      body: GestureDetector(
        onLongPress: _simulateScan,
        behavior: HitTestBehavior.opaque,
        child: _controller == null ? _simulateFallback() : _cameraView(),
      ),
    );
  }

  Widget _cameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          placeholderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error) => _cameraUnavailable(error),
        ),
        if (_phase == _Phase.scanning) _scanningOverlay(),
        if (_phase == _Phase.found) _foundOverlay(),
        if (_phase == _Phase.notFound) _notFoundOverlay(),
      ],
    );
  }

  Widget _scanningOverlay() {
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 260,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Point at a barcode',
              style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _foundOverlay() {
    return const ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 72),
      ),
    );
  }

  Widget _notFoundOverlay() {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            const Text('Product not recognized',
                style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _phase = _Phase.scanning),
              child: const Text('Scan again'),
            ),
          ],
        ),
      ),
    );
  }

  /// no-permission / camera-error state. On web and desktop there's no
  /// deep link into system settings, so explain + offer retry instead.
  Widget _cameraUnavailable(MobileScannerException error) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(denied ? Icons.no_photography_outlined : Icons.videocam_off_outlined,
                size: 48),
            const SizedBox(height: 12),
            Text(denied ? 'Camera permission needed' : 'Camera unavailable',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              denied
                  ? 'Scanning needs the camera. Allow camera access in your '
                      'browser or system settings, then try again.'
                  : 'No camera could be started on this device.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => unawaited(_controller?.start()),
              child: const Text('Try again'),
            ),
            TextButton(
              onPressed: _simulateScan,
              child: const Text('Simulate scan (dev only)'),
            ),
          ],
        ),
      ),
    );
  }

  /// Camera disabled entirely (tests) — the pre-ATLAS-005 simulate UI.
  Widget _simulateFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 64),
          const SizedBox(height: 12),
          const Text('Point at a barcode'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _simulateScan,
            child: const Text('Simulate scan (dev only)'),
          ),
        ],
      ),
    );
  }
}
