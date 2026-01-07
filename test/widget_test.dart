// test/widget_test.dart - FIXED
import 'package:flutter_test/flutter_test.dart';
import 'package:watch_store/main.dart';

void main() {
  testWidgets('Watch app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(WatchApp());

    // Wait for splash screen animation to complete (2 seconds)
    // We use pumpAndSettle to ensure all timers and animations are done.
    // Use a try-catch block or just pump adequately to avoid pending timer exception.
    await tester.pump(Duration(seconds: 3));

    // Verify that we start with splash screen content
    expect(find.text('Watch Store'), findsOneWidget);
  });
}
