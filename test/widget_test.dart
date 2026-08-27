// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chronos/main.dart';
import 'package:chronos/services/tutorial_service.dart';
import 'package:chronos/views/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chronos app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChronosApp()));

    expect(find.text('CHRONOS'), findsOneWidget);
  });

  testWidgets('tutorial is shown for first-time users only', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue sur Chronos !'), findsOneWidget);

    await tester.tap(find.text('Passer le tutoriel'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue sur Chronos !'), findsNothing);
  });

  test('tutorial preference is false after it has been seen', () async {
    SharedPreferences.setMockInitialValues({chronosTutorialSeenKey: true});

    expect(await TutorialService.shouldShowTutorial(), isFalse);
  });
}
