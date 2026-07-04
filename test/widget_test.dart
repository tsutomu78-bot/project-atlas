import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_atlas/main.dart';
import 'package:project_atlas/providers.dart';
import 'package:project_atlas/repositories/auth_repository.dart';
import 'package:project_atlas/screens/launch/launch_screen.dart';
import 'package:project_atlas/screens/login/login_screen.dart';
import 'package:project_atlas/screens/home/home_screen.dart';

import 'fake_auth_repository.dart';

void main() {
  testWidgets('App launches and routes signed-out users to Login', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(FakeAuthRepository())],
      child: const ProjectAtlasApp(),
    ));
    expect(find.byType(LaunchScreen), findsOneWidget);
    expect(find.text('Project Atlas'), findsOneWidget);
    // Launch auto-routes after a delay; flush the pending timer so the
    // test ends with no outstanding async work.
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('App routes already-signed-in users straight to Home', (tester) async {
    final auth = FakeAuthRepository(const AppUser(uid: 'anon-uid', isAnonymous: true));
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
      child: const ProjectAtlasApp(),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
