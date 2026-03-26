import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Users page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UsersApp());

    expect(find.text('Daftar User (REST API)'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
