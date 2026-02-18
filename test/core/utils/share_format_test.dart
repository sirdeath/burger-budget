import 'package:burger_budget/core/utils/share_format.dart';
import 'package:burger_budget/features/menu/domain/entities/menu_item.dart';
import 'package:burger_budget/features/recommendation/domain/entities/recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bigMac = MenuItem(
    id: 'mcd_1',
    franchise: 'mcd',
    name: '빅맥',
    type: MenuType.burger,
    price: 5500,
    calories: 550,
    tags: ['인기'],
  );

  const fries = MenuItem(
    id: 'mcd_2',
    franchise: 'mcd',
    name: '감자튀김 (M)',
    type: MenuType.side,
    price: 2000,
    calories: 330,
  );

  const coke = MenuItem(
    id: 'mcd_3',
    franchise: 'mcd',
    name: '코카콜라 (M)',
    type: MenuType.drink,
    price: 1500,
    calories: 150,
  );

  const whopper = MenuItem(
    id: 'bk_1',
    franchise: 'bk',
    name: '와퍼',
    type: MenuType.burger,
    price: 6500,
    calories: 620,
    tags: ['시그니처'],
  );

  group('formatComboForShare', () {
    test('메인+사이드+음료 전체 조합을 포맷한다', () {
      final result = formatComboForShare(
        mainItem: bigMac,
        sideItem: fries,
        drinkItem: coke,
      );

      expect(result, contains("McDonald's 추천 조합"));
      expect(result, contains('🍔 메인: 빅맥 - 5,500원'));
      expect(result, contains('🍟 사이드: 감자튀김 (M) - 2,000원'));
      expect(result, contains('🥤 음료: 코카콜라 (M) - 1,500원'));
      expect(result, contains('💰 총 가격: 9,000원'));
      expect(result, contains('🔥 총 칼로리: 1030 kcal'));
      expect(result, contains('#버짓'));
    });

    test('메인만 있는 경우 사이드/음료를 생략한다', () {
      final result = formatComboForShare(mainItem: bigMac);

      expect(result, contains('🍔 메인: 빅맥'));
      expect(result, isNot(contains('🍟 사이드')));
      expect(result, isNot(contains('🥤 음료')));
      expect(result, contains('💰 총 가격: 5,500원'));
    });

    test('칼로리가 null이면 칼로리 줄을 생략한다', () {
      const noCal = MenuItem(
        id: 'x',
        franchise: 'mcd',
        name: '테스트',
        type: MenuType.burger,
        price: 3000,
      );

      final result = formatComboForShare(mainItem: noCal);

      expect(result, isNot(contains('칼로리')));
    });
  });

  group('formatResultsForShare', () {
    test('전체 추천 결과를 포맷한다', () {
      final recommendations = [
        const Recommendation(
          mainItem: bigMac,
          sideItem: fries,
          drinkItem: coke,
        ),
        const Recommendation(mainItem: whopper),
      ];

      final result = formatResultsForShare(
        budget: 10000,
        recommendations: recommendations,
      );

      expect(result, contains('🍔 버짓 추천 결과'));
      expect(result, contains('💰 예산: 10,000원'));
      expect(
        result,
        contains(
          "1. [McDonald's] 빅맥 + 감자튀김 (M) + 코카콜라 (M) (9,000원)",
        ),
      );
      expect(
        result,
        contains('2. [Burger King] 와퍼 (6,500원)'),
      );
      expect(result, contains('#버짓'));
    });

    test('빈 추천 결과도 헤더를 포함한다', () {
      final result = formatResultsForShare(
        budget: 5000,
        recommendations: [],
      );

      expect(result, contains('🍔 버짓 추천 결과'));
      expect(result, contains('💰 예산: 5,000원'));
      expect(result, contains('#버짓'));
    });
  });
}
