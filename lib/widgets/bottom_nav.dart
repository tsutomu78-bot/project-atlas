import 'package:flutter/material.dart';
import '../routing/app_router.dart';

/// Shared bottom nav for Home / Shopping List / Favorites / History.
/// See NAVIGATION-MAP.md — always available once past Login.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  static const _routes = [
    AppRoutes.home,
    AppRoutes.shoppingList,
    AppRoutes.favorites,
    AppRoutes.history,
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        if (i == currentIndex) return;
        Navigator.of(context).pushReplacementNamed(_routes[i]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'List'),
        NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Saved'),
        NavigationDestination(icon: Icon(Icons.history), label: 'History'),
      ],
    );
  }
}
