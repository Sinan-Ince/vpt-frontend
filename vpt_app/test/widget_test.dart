import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vpt_app/main.dart';

void main() {
  testWidgets('App shows a loading indicator on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const VptApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
