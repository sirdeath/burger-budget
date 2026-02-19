import 'package:burger_budget/core/constants/app_constants.dart';
import 'package:burger_budget/features/recommendation/presentation/screens/home_screen.dart';
import 'package:burger_budget/features/recommendation/presentation/widgets/budget_input.dart';
import 'package:burger_budget/features/recommendation/presentation/widgets/franchise_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// FilledButton.icon creates a subtype (_FilledButtonWithIcon),
// so find.byType(FilledButton) won't match. Use predicate instead.
final _filledButtonFinder =
    find.byWidgetPredicate((w) => w is FilledButton);

Widget _filledButtonWidget(WidgetTester tester) =>
    tester.widget(_filledButtonFinder);

final _mcFinder = find.text("McDonald's");

/// Scroll to McDonald's chip before tapping (budget presets push it off-screen).
Future<void> _scrollToMcDonalds(WidgetTester tester) async {
  await tester.ensureVisible(_mcFinder);
  await tester.pumpAndSettle();
}

void main() {
  Widget createWidget() {
    return ProviderScope(
      child: MaterialApp(
        // Avoid ink_sparkle.frag shader loading in test environment
        theme: ThemeData(splashFactory: InkSplash.splashFactory),
        home: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('should display app title and guidance text', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('buzit'), findsOneWidget);
      expect(
        find.text('예산을 입력하고\n프랜차이즈를 선택하세요'),
        findsOneWidget,
      );
      expect(find.text('프랜차이즈'), findsOneWidget);
    });

    testWidgets('should contain BudgetInputWidget and FranchiseChips',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(BudgetInputWidget), findsOneWidget);
      expect(find.byType(FranchiseChips), findsOneWidget);
    });

    testWidgets('should have search icon button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should have recommend button with correct label',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('추천받기'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('recommend button should be disabled initially',
        (tester) async {
      await tester.pumpWidget(createWidget());

      final button = _filledButtonWidget(tester) as FilledButton;
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'recommend button should be disabled with only franchise selected',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await _scrollToMcDonalds(tester);
      await tester.tap(_mcFinder);
      await tester.pump();

      final button = _filledButtonWidget(tester) as FilledButton;
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'recommend button should be disabled with only budget entered',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextField), '10000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final button = _filledButtonWidget(tester) as FilledButton;
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'recommend button should be enabled with budget and franchise',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextField), '10000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await _scrollToMcDonalds(tester);
      await tester.tap(_mcFinder);
      await tester.pump();

      final button = _filledButtonWidget(tester) as FilledButton;
      expect(button.onPressed, isNotNull);
    });

    testWidgets(
        'recommend button should become disabled when franchise is deselected',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextField), '10000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await _scrollToMcDonalds(tester);
      await tester.tap(_mcFinder);
      await tester.pump();
      await tester.tap(_mcFinder);
      await tester.pump();

      final button = _filledButtonWidget(tester) as FilledButton;
      expect(button.onPressed, isNull);
    });

    testWidgets('should display budget preset chips', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('5천'), findsOneWidget);
      expect(find.text('8천'), findsOneWidget);
      expect(find.text('1만'), findsOneWidget);
      expect(find.text('1.5만'), findsOneWidget);
      expect(find.text('2만'), findsOneWidget);
      expect(
        find.byType(ChoiceChip),
        findsNWidgets(AppConstants.budgetPresets.length),
      );
    });

    testWidgets('should display budget slider', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets(
        'preset tap then franchise select should enable recommend button',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('1만'));
      await tester.pump();

      await _scrollToMcDonalds(tester);
      await tester.tap(_mcFinder);
      await tester.pump();

      final button = _filledButtonWidget(tester) as FilledButton;
      expect(button.onPressed, isNotNull);
    });
  });
}
