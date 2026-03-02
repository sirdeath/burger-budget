import 'package:burger_budget/core/utils/menu_type_display.dart';
import 'package:burger_budget/features/menu/domain/entities/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuTypeDisplay', () {
    group('icon', () {
      test('should return correct icon for each MenuType', () {
        expect(MenuTypeDisplay.icon(MenuType.burger), Icons.lunch_dining);
        expect(MenuTypeDisplay.icon(MenuType.side), Icons.takeout_dining);
        expect(MenuTypeDisplay.icon(MenuType.drink), Icons.local_cafe);
        expect(MenuTypeDisplay.icon(MenuType.set_), Icons.fastfood);
        expect(MenuTypeDisplay.icon(MenuType.dessert), Icons.icecream);
      });

      test('should cover all MenuType values', () {
        for (final type in MenuType.values) {
          expect(
            () => MenuTypeDisplay.icon(type),
            returnsNormally,
          );
        }
      });
    });

    group('label', () {
      test('should return correct label for each MenuType', () {
        expect(MenuTypeDisplay.label(MenuType.burger), '버거');
        expect(MenuTypeDisplay.label(MenuType.side), '사이드');
        expect(MenuTypeDisplay.label(MenuType.drink), '음료');
        expect(MenuTypeDisplay.label(MenuType.set_), '세트');
        expect(MenuTypeDisplay.label(MenuType.dessert), '디저트');
      });

      test('should cover all MenuType values', () {
        for (final type in MenuType.values) {
          expect(MenuTypeDisplay.label(type), isNotEmpty);
        }
      });
    });

    group('emoji', () {
      test('should return correct emoji for each MenuType', () {
        expect(MenuTypeDisplay.emoji(MenuType.burger), '🍔');
        expect(MenuTypeDisplay.emoji(MenuType.side), '🍟');
        expect(MenuTypeDisplay.emoji(MenuType.drink), '🥤');
        expect(MenuTypeDisplay.emoji(MenuType.set_), '🍱');
        expect(MenuTypeDisplay.emoji(MenuType.dessert), '🍦');
      });

      test('should cover all MenuType values', () {
        for (final type in MenuType.values) {
          expect(MenuTypeDisplay.emoji(type), isNotEmpty);
        }
      });
    });
  });
}
