import 'package:burger_budget/core/di/providers.dart';
import 'package:burger_budget/core/errors/result.dart';
import 'package:burger_budget/core/theme/app_theme.dart';
import 'package:burger_budget/features/app_shell/presentation/screens/app_shell.dart';
import 'package:burger_budget/features/data_update/domain/repositories/data_update_repository.dart';
import 'package:burger_budget/features/favorite/domain/entities/favorite.dart';
import 'package:burger_budget/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:burger_budget/features/history/domain/entities/order_history.dart';
import 'package:burger_budget/features/history/domain/repositories/history_repository.dart';
import 'package:burger_budget/features/menu/domain/entities/menu_item.dart';
import 'package:burger_budget/features/menu/domain/repositories/menu_repository.dart';
import 'package:burger_budget/features/recommendation/domain/entities/recommendation.dart';
import 'package:burger_budget/features/recommendation/domain/repositories/recommendation_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Test data ---

const testBurger = MenuItem(
  id: 'mcd_bigmac',
  franchise: 'mcd',
  name: '빅맥',
  type: MenuType.burger,
  price: 5900,
  calories: 583,
);

const testSide = MenuItem(
  id: 'mcd_fries_m',
  franchise: 'mcd',
  name: '후렌치 후라이 (M)',
  type: MenuType.side,
  price: 2600,
  calories: 332,
);

const testDrink = MenuItem(
  id: 'mcd_coke_m',
  franchise: 'mcd',
  name: '코카콜라 (M)',
  type: MenuType.drink,
  price: 2200,
  calories: 140,
);

const testBurger2 = MenuItem(
  id: 'bk_whopper',
  franchise: 'bk',
  name: '와퍼',
  type: MenuType.burger,
  price: 7900,
  calories: 660,
);

final testRecommendation = Recommendation(
  mainItem: testBurger,
  sideItem: testSide,
  drinkItem: testDrink,
);

final testRecommendation2 = Recommendation(
  mainItem: testBurger2,
);

// --- Mock repositories ---

class FakeMenuRepository implements MenuRepository {
  @override
  Future<Result<List<MenuItem>>> getMenusByFranchise(
    List<String> franchises,
  ) async {
    final all = [testBurger, testSide, testDrink, testBurger2];
    return Success(
      all.where((m) => franchises.contains(m.franchise)).toList(),
    );
  }

  @override
  Future<Result<List<MenuItem>>> getMenusWithinBudget(
    int budget,
    List<String> franchises,
  ) async {
    final all = [testBurger, testSide, testDrink, testBurger2];
    return Success(
      all
          .where(
            (m) => m.price <= budget && franchises.contains(m.franchise),
          )
          .toList(),
    );
  }

  @override
  Future<Result<MenuItem>> getMenuById(String id) async {
    final all = [testBurger, testSide, testDrink, testBurger2];
    final item = all.where((m) => m.id == id).firstOrNull;
    if (item != null) return Success(item);
    return const Failure('Menu not found');
  }

  @override
  Future<Result<List<MenuItem>>> searchMenus(String query) async {
    final all = [testBurger, testSide, testDrink, testBurger2];
    return Success(
      all.where((m) => m.name.contains(query)).toList(),
    );
  }
}

class FakeRecommendationRepository implements RecommendationRepository {
  @override
  Future<Result<List<Recommendation>>> getRecommendations({
    required int budget,
    required List<String> franchises,
    SortMode sort = SortMode.bestValue,
    int personCount = 1,
  }) async {
    final results = <Recommendation>[];
    if (franchises.contains('mcd') && budget >= 10700) {
      results.add(testRecommendation);
    }
    if (franchises.contains('bk') && budget >= 7900) {
      results.add(testRecommendation2);
    }
    return Success(results);
  }
}

class FakeDataUpdateRepository implements DataUpdateRepository {
  @override
  Future<Result<bool>> checkForUpdate() async => const Success(false);

  @override
  Future<Result<void>> downloadAndApply() async => const Success(null);

  @override
  Future<int> getLocalVersion() async => 2;
}

class FakeFavoriteRepository implements FavoriteRepository {
  @override
  Future<Result<List<Favorite>>> getFavorites() async =>
      const Success([]);

  @override
  Future<Result<Favorite>> addFavorite({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  }) async =>
      Success(Favorite(
        id: 1,
        mainItemId: mainItemId,
        sideItemId: sideItemId,
        drinkItemId: drinkItemId,
        createdAt: DateTime.now(),
      ));

  @override
  Future<Result<void>> removeFavorite(int id) async =>
      const Success(null);

  @override
  Future<Result<bool>> isFavorite({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
  }) async =>
      const Success(false);
}

class FakeHistoryRepository implements HistoryRepository {
  @override
  Future<Result<List<OrderHistory>>> getHistory() async =>
      const Success([]);

  @override
  Future<Result<OrderHistory>> addHistory({
    required String mainItemId,
    String? sideItemId,
    String? drinkItemId,
    required int totalPrice,
  }) async =>
      Success(OrderHistory(
        id: 1,
        mainItemId: mainItemId,
        sideItemId: sideItemId,
        drinkItemId: drinkItemId,
        totalPrice: totalPrice,
        createdAt: DateTime.now(),
      ));

  @override
  Future<Result<void>> removeHistory(int id) async =>
      const Success(null);

  @override
  Future<Result<void>> clearHistory() async =>
      const Success(null);
}

// --- App builder with overrides ---

Widget createTestApp() {
  return ProviderScope(
    overrides: [
      menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
      recommendationRepositoryProvider
          .overrideWithValue(FakeRecommendationRepository()),
      dataUpdateRepositoryProvider
          .overrideWithValue(FakeDataUpdateRepository()),
      favoriteRepositoryProvider
          .overrideWithValue(FakeFavoriteRepository()),
      historyRepositoryProvider
          .overrideWithValue(FakeHistoryRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme.copyWith(
        splashFactory: InkSplash.splashFactory,
      ),
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
