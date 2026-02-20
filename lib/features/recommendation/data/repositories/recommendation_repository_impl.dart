import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  const RecommendationRepositoryImpl(this._datasource);

  final RecommendationDatasource _datasource;

  @override
  Future<Result<List<Recommendation>>> getRecommendations({
    required int budget,
    required List<String> franchises,
    SortMode sort = SortMode.bestValue,
  }) async {
    try {
      final candidates = await _datasource.getCandidates(budget, franchises);
      final recommendations = _buildRecommendations(candidates, budget);
      final sorted = _sortRecommendations(recommendations, sort);
      return Success(sorted);
    } on Exception catch (e) {
      return Failure('추천 생성 실패', e);
    }
  }

  List<Recommendation> _buildRecommendations(
    List<MenuItem> candidates,
    int budget,
  ) {
    final sets = candidates
        .where((item) => item.type == MenuType.set_)
        .toList();
    final burgers = candidates
        .where((item) => item.type == MenuType.burger)
        .toList();
    final sides = candidates
        .where((item) => item.type == MenuType.side)
        .toList();
    final drinks = candidates
        .where((item) => item.type == MenuType.drink)
        .toList();
    final desserts = candidates
        .where((item) => item.type == MenuType.dessert)
        .toList();

    final results = <Recommendation>[];

    // 1) 세트 기반 추천: 세트가 포함하는 사이드/음료는 중복 추천 안 함
    for (final setItem in sets) {
      if (setItem.price > budget) continue;
      var remaining = budget - setItem.price;

      // 세트가 사이드 미포함이면 사이드 추천
      MenuItem? sideItem;
      if (!setItem.includesSide) {
        sideItem = _pickBest(sides, remaining);
        if (sideItem != null) remaining -= sideItem.price;
      }

      // 세트가 음료 미포함이면 음료 추천
      MenuItem? drinkItem;
      if (!setItem.includesDrink) {
        drinkItem = _pickBest(drinks, remaining);
        if (drinkItem != null) remaining -= drinkItem.price;
      }

      // 남은 예산으로 디저트 추천
      final dessertItem = _pickBest(desserts, remaining);

      results.add(Recommendation(
        mainItem: setItem,
        sideItem: sideItem,
        drinkItem: drinkItem,
        dessertItem: dessertItem,
      ));
    }

    // 2) 단품 버거 기반 추천
    for (final burger in burgers) {
      if (burger.price > budget) continue;
      var remaining = budget - burger.price;

      final bestSide = _pickBest(sides, remaining);
      if (bestSide != null) remaining -= bestSide.price;

      final bestDrink = _pickBest(drinks, remaining);
      if (bestDrink != null) remaining -= bestDrink.price;

      final dessertItem = _pickBest(desserts, remaining);

      results.add(Recommendation(
        mainItem: burger,
        sideItem: bestSide,
        drinkItem: bestDrink,
        dessertItem: dessertItem,
      ));
    }

    if (results.isEmpty && burgers.isEmpty && sets.isEmpty) return [];

    return results;
  }

  MenuItem? _pickBest(List<MenuItem> items, int maxPrice) {
    for (final item in items) {
      if (item.price <= maxPrice) return item;
    }
    return null;
  }

  List<Recommendation> _sortRecommendations(
    List<Recommendation> recommendations,
    SortMode sort,
  ) {
    final sorted = List<Recommendation>.from(recommendations);
    switch (sort) {
      case SortMode.bestValue:
        sorted.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
      case SortMode.lowestCalories:
        sorted.sort((a, b) {
          final aCal = a.totalCalories ?? 0x7FFFFFFF;
          final bCal = b.totalCalories ?? 0x7FFFFFFF;
          return aCal.compareTo(bCal);
        });
    }
    return sorted.take(AppConstants.maxRecommendations).toList();
  }
}
