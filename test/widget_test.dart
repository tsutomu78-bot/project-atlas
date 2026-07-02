import 'package:flutter_test/flutter_test.dart';

import 'package:project_atlas/main.dart';
import 'package:project_atlas/screens/launch/launch_screen.dart';

void main() {
  testWidgets('App launches and shows the Launch screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProjectAtlasApp());
    expect(find.byType(LaunchScreen), findsOneWidget);
    expect(find.text('Project Atlas'), findsOneWidget);
  });
}
