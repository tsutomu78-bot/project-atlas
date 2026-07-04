import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_atlas/models/result.dart';
import 'package:project_atlas/providers.dart';
import 'package:project_atlas/routing/app_router.dart';
import 'package:project_atlas/screens/login/login_screen.dart';

import 'fake_auth_repository.dart';

Widget _loginHarness(FakeAuthRepository auth) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(auth)],
    child: MaterialApp(
      home: const LoginScreen(),
      routes: {AppRoutes.home: (_) => const Text('HOME')},
    ),
  );
}

void main() {
  testWidgets('anonymous sign-in navigates to Home', (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(_loginHarness(auth));

    await tester.tap(find.text('Continue without an account'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(auth.user, isNotNull);
    expect(auth.user!.isAnonymous, isTrue);
  });

  testWidgets('Google sign-in navigates to Home', (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(_loginHarness(auth));

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(auth.user!.isAnonymous, isFalse);
  });

  testWidgets('failed sign-in stays on Login and shows the message', (tester) async {
    final auth = FakeAuthRepository()
      ..nextSignInResult = const Failure('This sign-in method is not enabled yet.');
    await tester.pumpWidget(_loginHarness(auth));

    await tester.tap(find.text('Continue without an account'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsNothing);
    expect(find.text('This sign-in method is not enabled yet.'), findsOneWidget);
  });

  testWidgets('offline sign-in shows the offline message', (tester) async {
    final auth = FakeAuthRepository()..nextSignInResult = const Offline();
    await tester.pumpWidget(_loginHarness(auth));

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsNothing);
    expect(find.textContaining('offline'), findsOneWidget);
  });

  testWidgets('Apple button is honest about being unavailable', (tester) async {
    await tester.pumpWidget(_loginHarness(FakeAuthRepository()));

    await tester.tap(find.text('Continue with Apple'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsNothing);
    expect(find.text('Apple sign-in is not available yet.'), findsOneWidget);
  });
}
