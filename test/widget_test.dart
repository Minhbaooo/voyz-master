import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyz/data/saved_trips_provider.dart';
import 'package:voyz/screens/splash_screen.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      SavedTripsProvider(child: MaterialApp(home: const SplashScreen())),
    );

    // Verify splash screen shows the app name
    expect(find.text('AIVIVU'), findsOneWidget);

    // Cleanly let all timers and animations finish
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
