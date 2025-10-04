// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:appcounter/main.dart';

void main() {
  testWidgets('Watch app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(WatchApp());

    // Wait for splash screen animation
    await tester.pump(Duration(seconds: 1));

    // Verify that we start with splash screen
    expect(find.text('Watch Store'), findsOneWidget);
    expect(find.text('Premium Timepieces'), findsOneWidget);

    // Wait for splash to finish
    await tester.pump(Duration(seconds: 3));

    // Should now be on login screen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
