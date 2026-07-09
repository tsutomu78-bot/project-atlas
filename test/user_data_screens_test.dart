import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_atlas/models/favorite.dart';
import 'package:project_atlas/models/result.dart';
import 'package:project_atlas/models/scan_history_entry.dart';
import 'package:project_atlas/models/shopping_list_item.dart';
import 'package:project_atlas/providers.dart';
import 'package:project_atlas/repositories/auth_repository.dart';
import 'package:project_atlas/routing/app_router.dart';
import 'package:project_atlas/screens/favorites/favorites_screen.dart';
import 'package:project_atlas/screens/history/history_screen.dart';
import 'package:project_atlas/screens/scan/scan_screen.dart';
import 'package:project_atlas/screens/shopping_list/shopping_list_screen.dart';

import 'fake_auth_repository.dart';
import 'fake_kroger_connector.dart';
import 'fake_user_data_repositories.dart';

const _user = AppUser(uid: 'u1', isAnonymous: true);

Widget harness({
  required Widget home,
  AppUser? user = _user,
  FakeFavoritesRepository? favorites,
  FakeShoppingListRepository? shoppingList,
  FakeScanHistoryRepository? history,
  FakeKrogerConnector? kroger,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository(user)),
      favoritesRepositoryProvider
          .overrideWithValue(favorites ?? FakeFavoritesRepository()),
      shoppingListRepositoryProvider
          .overrideWithValue(shoppingList ?? FakeShoppingListRepository()),
      scanHistoryRepositoryProvider
          .overrideWithValue(history ?? FakeScanHistoryRepository()),
      krogerConnectorProvider.overrideWithValue(kroger ?? FakeKrogerConnector()),
    ],
    child: MaterialApp(
      home: home,
      // Stub target for ScanScreen's navigation so tests never construct the
      // real ProductScreen (whose price repository is Firestore-backed).
      routes: {AppRoutes.product: (_) => const Scaffold(body: Text('PRODUCT_STUB'))},
    ),
  );
}

void main() {
  final when = DateTime.now().subtract(const Duration(minutes: 5));

  group('FavoritesScreen', () {
    testWidgets('shows items and removes on tap', (tester) async {
      final repo = FakeFavoritesRepository(
          [Favorite(productId: '000000000000', addedAt: when)]);
      await tester.pumpWidget(harness(home: const FavoritesScreen(), favorites: repo));
      await tester.pumpAndSettle();

      expect(find.text('Product 000000000000'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove from favorites'));
      await tester.pumpAndSettle();

      expect(repo.items, isEmpty);
      expect(find.text('Favorite products to check prices faster.'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(harness(home: const FavoritesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Favorite products to check prices faster.'), findsOneWidget);
    });

    testWidgets('signed out shows sign-in message', (tester) async {
      await tester.pumpWidget(harness(home: const FavoritesScreen(), user: null));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to save favorites.'), findsOneWidget);
    });

    testWidgets('offline shows honest message', (tester) async {
      final repo = FakeFavoritesRepository()..failWith = const Offline<Never>();
      await tester.pumpWidget(harness(home: const FavoritesScreen(), favorites: repo));
      await tester.pumpAndSettle();
      expect(find.textContaining('Offline'), findsOneWidget);
    });
  });

  group('ShoppingListScreen', () {
    testWidgets('shows items and removes on tap', (tester) async {
      final repo = FakeShoppingListRepository(
          [ShoppingListItem(productId: '000000000000', addedAt: when)]);
      await tester
          .pumpWidget(harness(home: const ShoppingListScreen(), shoppingList: repo));
      await tester.pumpAndSettle();

      expect(find.text('Product 000000000000'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove from list'));
      await tester.pumpAndSettle();

      expect(repo.items, isEmpty);
      expect(find.text('Scan products to build your shopping list.'), findsOneWidget);
    });
  });

  group('HistoryScreen', () {
    testWidgets('shows scan entries', (tester) async {
      final repo = FakeScanHistoryRepository(
          [ScanHistoryEntry(productId: '000000000000', scannedAt: when)]);
      await tester.pumpWidget(harness(home: const HistoryScreen(), history: repo));
      await tester.pumpAndSettle();
      expect(find.text('Product 000000000000'), findsOneWidget);
      expect(find.textContaining('Scanned'), findsOneWidget);
    });
  });

  group('ScanScreen', () {
    testWidgets('simulate scan records history and refreshes price', (tester) async {
      final repo = FakeScanHistoryRepository();
      final kroger = FakeKrogerConnector();
      await tester.pumpWidget(harness(
        home: const ScanScreen(),
        history: repo,
        kroger: kroger,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simulate scan (dev only)'));
      await tester.pump();

      expect(repo.entries, hasLength(1));
      expect(repo.entries.single.productId, ScanScreen.simulatedUpc);

      expect(kroger.calls, hasLength(1));
      expect(kroger.calls.single.productId, ScanScreen.simulatedUpc);
      expect(kroger.calls.single.upc, ScanScreen.simulatedUpc);
    });
  });
}
