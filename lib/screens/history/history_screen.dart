import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/result.dart';
import '../../models/scan_history_entry.dart';
import '../../providers.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/state_message.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  Future<Result<List<ScanHistoryEntry>>>? _future;
  String? _uid;

  void _load(String uid) {
    _uid = uid;
    _future = ref.read(scanHistoryRepositoryProvider).list(uid);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final user = auth.value;
    if (user != null && user.uid != _uid) _load(user.uid);

    final Widget body;
    if (user == null) {
      body = auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : const StateMessage(
              icon: Icons.history, message: 'Sign in to keep a scan history.');
    } else {
      body = FutureBuilder<Result<List<ScanHistoryEntry>>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return switch (snap.data!) {
            Success(value: final items) when items.isEmpty => const StateMessage(
                icon: Icons.history, message: 'Products you scan will appear here.'),
            Success(value: final items) => ListView(
                children: [
                  for (final entry in items)
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: Text('Product ${entry.productId}'),
                      subtitle: Text('Scanned ${formatAgo(entry.scannedAt)}'),
                    ),
                ],
              ),
            final r => StateMessage(icon: Icons.history, message: resultMessage(r)),
          };
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: body,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
