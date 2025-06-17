// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mvk_app/main.dart';

void main() {
  testWidgets('MVK App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MVKApp());

    // Verify that the splash screen appears
    await tester.pump();

    // Wait for splash animation to complete
    await tester.pump(const Duration(seconds: 3));

    // The app should be running without errors
    expect(find.byType(MVKApp), findsOneWidget);
  });
}
