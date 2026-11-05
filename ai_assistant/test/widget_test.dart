import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/main.dart';
import 'package:ai_assistant/screens/splash_screen.dart';

void main() {
  testWidgets('Ujjain Live app starts and renders splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AIAssistantApp());

    // Verify that the Splash Screen loads
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('SIMHASTHA 2028'), findsOneWidget);
    expect(find.text('सिंहस्थ उज्जैन'), findsOneWidget);

    // Dispose widgets to clean up active timers and animations
    await tester.pumpWidget(const SizedBox());
  });
}
