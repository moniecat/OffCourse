import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:offcourse/app.dart';

void main() {
  testWidgets('onboarding intro unlocks and advances to first reel',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Tap to continue →'), findsNothing);
    expect(find.text('Welcome to OffCourse'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Tap to continue →'), findsOneWidget);

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.text('Free for all'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
  });

  testWidgets('logout route resolves to sign in screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final navigator = Navigator.of(tester.element(find.byType(PageView)));
    navigator.pushNamed('/login');
    await tester.pumpAndSettle();

    expect(find.text('Welcome back!'), findsOneWidget);
  });
}
