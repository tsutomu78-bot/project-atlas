import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/favorite.dart';
import '../../models/price_info.dart';
import '../../models/result.dart';
import '../../providers.dart';
import '../scan/scan_screen.dart';

/// The core value screen. Reads prices through PriceRepository so the UI is
/// already built against the real architecture: per-connector loading,
/// confidence display, and graceful failure per ARCHITECTURE.md §5–6b.
/// Until the camera exists (ATLAS-005) the product shown is the simulated
/// scan's UPC.
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  static const _productId = ScanScreen.simulatedUpc;

  late final Future<List<Result<PriceInfo>>> _pricesFuture =
      ref.read(priceRepositoryProvider).pricesForUpc(_productId);
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final favorites = await ref.read(favoritesRepositoryProvider).list(uid);
    if (favorites case Success(value: final List<Favorite> items)) {
      if (mounted) {
        setState(() => _isFavorite = items.any((f) => f.productId == _productId));
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return _requireSignIn();
    final repo = ref.read(favoritesRepositoryProvider);
    final result = _isFavorite
        ? await repo.remove(uid, _productId)
        : await repo.add(uid, _productId);
    if (!mounted) return;
    if (result is Success) {
      setState(() => _isFavorite = !_isFavorite);
    } else {
      _showSnack('Could not update favorites. Try again.');
    }
  }

  Future<void> _addToList() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return _requireSignIn();
    final result =
        await ref.read(shoppingListRepositoryProvider).add(uid, _productId);
    if (!mounted) return;
    _showSnack(result is Success
        ? 'Added to your shopping list.'
        : 'Could not add to the list. Try again.');
  }

  void _requireSignIn() => _showSnack('Sign in to save products.');

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // On a deep link the first auth emission can arrive after initState —
    // re-run the favorite lookup once the uid actually exists.
    ref.listen(currentUserIdProvider, (previous, next) {
      if (previous == null && next != null) _loadFavoriteState();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline),
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              Icon(Icons.image_outlined, size: 56),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product name', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('Brand · size', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Compare across stores', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          FutureBuilder<List<Result<PriceInfo>>>(
            future: _pricesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: [for (final r in snapshot.data!) _PriceCard(result: r)],
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _addToList,
            icon: const Icon(Icons.add),
            label: const Text('Add to list'),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final Result<PriceInfo> result;
  const _PriceCard({required this.result});

  @override
  Widget build(BuildContext context) {
    // Each Result case maps to a specific honest message — never a blank
    // field, never a crash (Engineering Value #1: truth over completeness).
    switch (result) {
      case Success(value: final price):
        return Card(
          child: ListTile(
            title: Text(price.source),
            subtitle: Text(
              '${price.availability == Availability.inStock ? "In stock" : "Out of stock"}'
              ' · Verified ${_ago(price.verifiedAt)}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${price.price!.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('${price.confidence}%', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        );
      case ConnectorUnavailable():
        return const Card(
          child: ListTile(
            title: Text('Store'),
            subtitle: Text('Price unavailable · No current data · Last checked today'),
          ),
        );
      case Offline():
        return const Card(
          child: ListTile(
            title: Text('Store'),
            subtitle: Text('Offline · Showing nothing rather than guessing'),
          ),
        );
      case NotFound() || PermissionDenied() || Failure():
        return const Card(
          child: ListTile(
            title: Text('Store'),
            subtitle: Text('Price unavailable'),
          ),
        );
    }
  }

  String _ago(DateTime? t) {
    if (t == null) return 'recently';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} hr ago';
    return '${d.inDays} day(s) ago';
  }
}
