import 'package:burger_budget/core/utils/currency_format.dart';
import 'package:burger_budget/features/menu/domain/entities/menu_item.dart';
import 'package:burger_budget/features/recommendation/domain/entities/recommendation.dart';
import 'package:burger_budget/features/recommendation/presentation/widgets/recommendation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mainItem = MenuItem(
    id: 'mcd_001',
    franchise: 'mcd',
    name: '빅맥',
    type: MenuType.burger,
    price: 5500,
    calories: 583,
  );

  const sideItem = MenuItem(
    id: 'mcd_010',
    franchise: 'mcd',
    name: '맥너겟 6조각',
    type: MenuType.side,
    price: 3500,
    calories: 420,
  );

  const drinkItem = MenuItem(
    id: 'mcd_020',
    franchise: 'mcd',
    name: '콜라 M',
    type: MenuType.drink,
    price: 2000,
    calories: 150,
  );

  Widget createWidget(Recommendation recommendation, {int rank = 1}) {
    return MaterialApp(
      // Avoid ink_sparkle.frag shader loading in test environment
      theme: ThemeData(splashFactory: InkSplash.splashFactory),
      home: Scaffold(
        body: RecommendationCard(
          recommendation: recommendation,
          rank: rank,
        ),
      ),
    );
  }

  group('RecommendationCard', () {
    testWidgets('should display main item name and franchise name',
        (tester) async {
      const rec = Recommendation(mainItem: mainItem);
      await tester.pumpWidget(createWidget(rec));

      expect(find.text('빅맥'), findsOneWidget);
      expect(find.text("McDonald's"), findsOneWidget);
    });

    testWidgets('should display rank number', (tester) async {
      const rec = Recommendation(mainItem: mainItem);
      await tester.pumpWidget(createWidget(rec, rank: 3));

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should display total price in KRW format', (tester) async {
      const rec = Recommendation(mainItem: mainItem);
      await tester.pumpWidget(createWidget(rec));

      expect(find.text(formatKRW(5500)), findsOneWidget);
    });

    testWidgets('should display calories when available', (tester) async {
      const rec = Recommendation(mainItem: mainItem);
      await tester.pumpWidget(createWidget(rec));

      expect(find.text('583 kcal'), findsOneWidget);
    });

    testWidgets('should not display calories when null', (tester) async {
      const noCalItem = MenuItem(
        id: 'x',
        franchise: 'mcd',
        name: '테스트 버거',
        type: MenuType.burger,
        price: 5000,
      );
      const rec = Recommendation(mainItem: noCalItem);
      await tester.pumpWidget(createWidget(rec));

      expect(find.textContaining('kcal'), findsNothing);
    });

    testWidgets('should display side and drink sub-items', (tester) async {
      const rec = Recommendation(
        mainItem: mainItem,
        sideItem: sideItem,
        drinkItem: drinkItem,
      );
      await tester.pumpWidget(createWidget(rec));

      expect(find.textContaining('맥너겟 6조각'), findsOneWidget);
      expect(find.textContaining('콜라 M'), findsOneWidget);
    });

    testWidgets('should display correct total price with sub-items',
        (tester) async {
      const rec = Recommendation(
        mainItem: mainItem,
        sideItem: sideItem,
        drinkItem: drinkItem,
      );
      await tester.pumpWidget(createWidget(rec));

      // 5500 + 3500 + 2000 = 11000
      expect(find.text(formatKRW(11000)), findsOneWidget);
    });

    testWidgets('should not display sub-items when absent', (tester) async {
      const rec = Recommendation(mainItem: mainItem);
      await tester.pumpWidget(createWidget(rec));

      expect(find.textContaining('맥너겟'), findsNothing);
      expect(find.textContaining('콜라'), findsNothing);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      var tapped = false;
      const rec = Recommendation(mainItem: mainItem);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkSplash.splashFactory),
          home: Scaffold(
            body: RecommendationCard(
              recommendation: rec,
              rank: 1,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RecommendationCard));
      expect(tapped, isTrue);
    });
  });
}
