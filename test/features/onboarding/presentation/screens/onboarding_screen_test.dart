import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:burger_budget/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp({bool isReplay = false}) {
    return ProviderScope(
      child: MaterialApp(
        home: OnboardingScreen(isReplay: isReplay),
      ),
    );
  }

  group('OnboardingScreen', () {
    testWidgets('shows first page on launch', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('예산을 설정하세요'), findsOneWidget);
      expect(find.text('건너뛰기'), findsOneWidget);
      expect(find.text('다음'), findsOneWidget);
    });

    testWidgets('advances to second page on next tap', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('프랜차이즈를 선택하세요'), findsOneWidget);
    });

    testWidgets('shows start button on last page', (tester) async {
      await tester.pumpWidget(buildApp());

      // Go to page 2
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      // Go to page 3
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('최적 조합을 추천받으세요'), findsOneWidget);
      expect(find.text('시작하기'), findsOneWidget);
    });

    testWidgets('skip button saves preference', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('건너뛰기'));
      // pump once to trigger async SharedPreferences write
      await tester.pump(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    testWidgets('start button saves preference on last page',
        (tester) async {
      await tester.pumpWidget(buildApp());

      // Navigate to last page
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('시작하기'));
      await tester.pump(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    testWidgets('replay mode does not save preference', (tester) async {
      await tester.pumpWidget(buildApp(isReplay: true));

      await tester.tap(find.text('건너뛰기'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isNull);
    });

    testWidgets('swipe navigates between pages', (tester) async {
      await tester.pumpWidget(buildApp());

      // Swipe left to go to page 2
      await tester.drag(
        find.byType(PageView),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('프랜차이즈를 선택하세요'), findsOneWidget);
    });

    testWidgets('page indicator shows correct count', (tester) async {
      await tester.pumpWidget(buildApp());

      // 3 indicator dots (AnimatedContainer)
      final indicators = find.descendant(
        of: find.byType(Row),
        matching: find.byType(AnimatedContainer),
      );
      expect(indicators, findsNWidgets(3));
    });
  });
}
