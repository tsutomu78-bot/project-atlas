import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/favorite.dart';
import '../../models/result.dart';
import '../../providers.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/state_message.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  Future<Result<List<Favorite>>>? _future;
  String? _uid;

  void _load(String uid) {
    _uid = uid;
    _future = ref.read(favoritesRepositoryProvider).list(uid);
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
              icon: Icons.favorite_outline, message: 'Sign in to save favorites.');
    } else {
      body = FutureBuilder<Result<List<Favorite>>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return switch (snap.data!) {
            Success(value: final items) when items.isEmpty => const StateMessage(
                icon: Icons.favorite_outline,
                message: 'Favorite products to check prices faster.'),
            Success(value: final items) => ListView(
                children: [
                  for (final f in items)
                    ListTile(
                      leading: const Icon(Icons.image_outlined),
                      title: Text('Product ${f.productId}'),
                      subtitle: Text('Added ${formatAgo(f.addedAt)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite),
                        tooltip: 'Remove from favorites',
                        onPressed: () async {
                          await ref
                              .read(favoritesRepositoryProvider)
                              .remove(user.uid, f.productId);
                          if (mounted) setState(() => _load(user.uid));
                        },
                      ),
                    ),
                ],
              ),
            final r => StateMessage(icon: Icons.favorite_outline, message: resultMessage(r)),
          };
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: body,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
