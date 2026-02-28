import 'package:flutter_test/flutter_test.dart';

import 'package:voyz/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const VoyzApp());

    // Verify splash screen shows the app name
    expect(find.text('AIVIVU'), findsOneWidget);
  });
}
