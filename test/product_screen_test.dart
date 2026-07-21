import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_atlas/models/price_info.dart';
import 'package:project_atlas/models/result.dart';
import 'package:project_atlas/providers.dart';
import 'package:project_atlas/repositories/auth_repository.dart';
import 'package:project_atlas/screens/product/product_screen.dart';

import 'fake_auth_repository.dart';
import 'fake_kroger_connector.dart';
import 'fake_price_repository.dart';
import 'fake_user_data_repositories.dart';

const _user = AppUser(uid: 'u1', isAnonymous: true);
const _upc = '0001111042850';

Widget harness({
  required FakePriceRepository prices,
  FakeKrogerConnector? kroger,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository(_user)),
      priceRepositoryProvider.overrideWithValue(prices),
      krogerConnectorProvider.overrideWithValue(kroger ?? FakeKrogerConnector()),
      favoritesRepositoryProvider.overrideWithValue(FakeFavoritesRepository()),
    ],
    child: const MaterialApp(home: ProductScreen(productId: _upc)),
  );
}

void main() {
  group('ProductScreen', () {
    testWidgets('triggers a Kroger refresh before reading prices, then shows the result',
        (tester) async {
      final kroger = FakeKrogerConnector();
      final prices = FakePriceRepository([
        Success(PriceInfo(
          connectorId: 'kroger',
          source: 'Kroger',
          price: 4.69,
          availability: Availability.inStock,
          verifiedAt: DateTime.now(),
          confidence: 95,
        )),
      ]);
      await tester.pumpWidget(harness(prices: prices, kroger: kroger));
      await tester.pumpAndSettle();

      expect(kroger.calls, hasLength(1));
      expect(kroger.calls.single.productId, _upc);
      expect(kroger.calls.single.upc, _upc);
      expect(find.text('\$4.69'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('Kroger-unavailable price doc renders honestly, not a crash',
        (tester) async {
      // Mirrors what the Cloud Function writes when Kroger's cert-env 403s:
      // a price doc with no price/confidence, availability "unknown".
      final prices = FakePriceRepository([
        Success(PriceInfo(
          connectorId: 'kroger',
          source: 'Kroger',
          availability: Availability.unknown,
          verifiedAt: DateTime.now(),
        )),
      ]);
      await tester.pumpWidget(harness(prices: prices));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('No price'), findsOneWidget);
      expect(find.textContaining('Availability unknown'), findsOneWidget);
    });
  });
}
