import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tianchang_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('您好，我是天城。'), findsOneWidget);
  });
}
