import 'package:flutter/material.dart';
import '../screens/launch/launch_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/product/product_screen.dart';
import '../screens/shopping_list/shopping_list_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Named routes matching NAVIGATION-MAP.md in the vault.
/// This file IS the routing contract in code form — every route here
/// must correspond to an arrow in that document.
class AppRoutes {
  static const launch = '/';
  static const login = '/login';
  static const home = '/home';
  static const scan = '/scan';
  static const product = '/product';
  static const shoppingList = '/shopping-list';
  static const history = '/history';
  static const favorites = '/favorites';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    launch: (_) => const LaunchScreen(),
    login: (_) => const LoginScreen(),
    home: (_) => const HomeScreen(),
    scan: (_) => const ScanScreen(),
    product: (_) => const ProductScreen(),
    shoppingList: (_) => const ShoppingListScreen(),
    history: (_) => const HistoryScreen(),
    favorites: (_) => const FavoritesScreen(),
    settings: (_) => const SettingsScreen(),
  };
}
