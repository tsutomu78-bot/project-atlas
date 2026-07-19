import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_atlas/providers.dart';
import 'package:project_atlas/repositories/auth_repository.dart';
import 'package:project_atlas/screens/settings/settings_screen.dart';
import 'package:project_atlas/settings/kroger_stores.dart';

import 'fake_auth_repository.dart';

const _user = AppUser(uid: 'u1', isAnonymous: true);

Widget harness() {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository(_user)),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

/// The label of the (single) store tile currently showing the check mark.
String checkedStoreLabel(WidgetTester tester) {
  final check = find.byIcon(Icons.check);
  expect(check, findsOneWidget);
  final tile = tester.widget<ListTile>(
      find.ancestor(of: check, matching: find.byType(ListTile)).first);
  return (tile.title! as Text).data!;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Settings store picker', () {
    testWidgets('lists all cert-env stores with the default selected',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      for (final store in krogerStores) {
        expect(find.text(store.label), findsOneWidget);
      }
      expect(checkedStoreLabel(tester), 'Fred Meyer — Bellevue');
    });

    testWidgets('tapping a store selects and persists it', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('QFC — Redmond'));
      await tester.pumpAndSettle();

      expect(checkedStoreLabel(tester), 'QFC — Redmond');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('krogerLocationId'), '70500820');
    });

    testWidgets('a saved store is restored on startup', (tester) async {
      SharedPreferences.setMockInitialValues({'krogerLocationId': '70500860'});
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(checkedStoreLabel(tester), 'QFC — Redmond Ridge');
    });
  });

  group('Kroger connector wiring', () {
    test('connector uses the selected store and rebuilds on change', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(krogerConnectorProvider).defaultLocationId,
          defaultKrogerLocationId);

      await container
          .read(krogerLocationIdProvider.notifier)
          .select('70500820');

      expect(container.read(krogerConnectorProvider).defaultLocationId,
          '70500820');
    });
  });
}
