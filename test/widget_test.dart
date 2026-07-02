import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_atlas/main.dart';
import 'package:project_atlas/screens/launch/launch_screen.dart';

void main() {
  testWidgets('App launches and shows the Launch screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ProjectAtlasApp()));
    expect(find.byType(LaunchScreen), findsOneWidget);
    expect(find.text('Project Atlas'), findsOneWidget);
    // Launch auto-routes after a delay; flush the pending timer so the
    // test ends with no outstanding async work.
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
