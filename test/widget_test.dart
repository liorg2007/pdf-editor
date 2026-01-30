import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_generator/main.dart';

void main() {
  testWidgets('Invoice form smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the invoice form screen is shown.
    expect(find.text('יצירת חשבונית'), findsOneWidget);
  });
}
