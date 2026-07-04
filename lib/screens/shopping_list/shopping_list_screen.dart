import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/result.dart';
import '../../models/shopping_list_item.dart';
import '../../providers.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/state_message.dart';

/// v1.0: no quantity, coupons, budget tracking, route optimization,
/// auto-retailer-switching, or multi-store checkout (see MVP-FREEZE-v1.0.md).
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  Future<Result<List<ShoppingListItem>>>? _future;
  String? _uid;

  void _load(String uid) {
    _uid = uid;
    _future = ref.read(shoppingListRepositoryProvider).list(uid);
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
              icon: Icons.list_alt_outlined, message: 'Sign in to build a shopping list.');
    } else {
      body = FutureBuilder<Result<List<ShoppingListItem>>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return switch (snap.data!) {
            Success(value: final items) when items.isEmpty => const StateMessage(
                icon: Icons.list_alt_outlined,
                message: 'Scan products to build your shopping list.'),
            Success(value: final items) => ListView(
                children: [
                  for (final item in items)
                    ListTile(
                      leading: const Icon(Icons.image_outlined),
                      title: Text('Product ${item.productId}'),
                      subtitle: Text('Added ${formatAgo(item.addedAt)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        tooltip: 'Remove from list',
                        onPressed: () async {
                          await ref
                              .read(shoppingListRepositoryProvider)
                              .remove(user.uid, item.productId);
                          if (mounted) setState(() => _load(user.uid));
                        },
                      ),
                    ),
                ],
              ),
            final r =>
              StateMessage(icon: Icons.list_alt_outlined, message: resultMessage(r)),
          };
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping list')),
      body: body,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
