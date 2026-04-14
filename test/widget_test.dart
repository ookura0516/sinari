import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sinari/main.dart';

void main() {
  testWidgets('Title screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SinariApp());
    await tester.pump();

    expect(find.text('深淵の図書館'), findsWidgets);
    expect(find.text('ゲームを始める'), findsOneWidget);
  });
}
