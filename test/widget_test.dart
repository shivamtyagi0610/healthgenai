import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthgenai/app/app.dart';

void main() {
  testWidgets('App root widget smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthGenApp());

    // Basic assertion to ensure app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
