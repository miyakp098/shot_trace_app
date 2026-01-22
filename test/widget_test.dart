// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shot_trace_app/main.dart';

void main() {
  testWidgets('App builds and shows home title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // AppBar タイトルが表示されることを確認
    expect(find.text('Shot Trace App'), findsOneWidget);

    // カウント用の+ボタンが存在しないことを確認
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
