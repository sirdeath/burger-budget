import 'package:flutter/material.dart';

import '../../features/menu/domain/entities/menu_item.dart';

class MenuTypeDisplay {
  const MenuTypeDisplay._();

  static IconData icon(MenuType type) {
    return switch (type) {
      MenuType.burger => Icons.lunch_dining,
      MenuType.side => Icons.fastfood,
      MenuType.drink => Icons.local_cafe,
      MenuType.set_ => Icons.restaurant_menu,
      MenuType.dessert => Icons.icecream,
    };
  }

  static String label(MenuType type) {
    return switch (type) {
      MenuType.burger => '버거',
      MenuType.side => '사이드',
      MenuType.drink => '음료',
      MenuType.set_ => '세트',
      MenuType.dessert => '디저트',
    };
  }

  static String emoji(MenuType type) {
    return switch (type) {
      MenuType.burger => '🍔',
      MenuType.side => '🍟',
      MenuType.drink => '🥤',
      MenuType.set_ => '🍱',
      MenuType.dessert => '🍦',
    };
  }
}
