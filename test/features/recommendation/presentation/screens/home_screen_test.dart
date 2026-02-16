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

      expect(find.text('Burger Budget'), findsOneWidget);
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

      await tester.tap(find.text("McDonald's"));
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

      await tester.tap(find.text("McDonald's"));
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

      await tester.tap(find.text("McDonald's"));
      await tester.pump();
      await tester.tap(find.text("McDonald's"));
      await tester.pump();

      final button = _filledButtonWidget(tester) as FilledButton;
      expect(button.onPressed, isNull);
    });
  });
}
