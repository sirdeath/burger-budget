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

    final mains = sets.isNotEmpty ? sets : burgers;
    if (mains.isEmpty) return [];

    final results = <Recommendation>[];

    for (final main in mains.take(AppConstants.maxRecommendations)) {
      var remaining = budget - main.price;

      final bestSide = _pickBest(sides, remaining);
      if (bestSide != null) {
        remaining -= bestSide.price;
      }

      final bestDrink = _pickBest(drinks, remaining);

      results.add(Recommendation(
        mainItem: main,
        sideItem: bestSide,
        drinkItem: bestDrink,
      ));
    }

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
          final aCal = a.totalCalories ?? double.maxFinite.toInt();
          final bCal = b.totalCalories ?? double.maxFinite.toInt();
          return aCal.compareTo(bCal);
        });
    }
    return sorted.take(AppConstants.maxRecommendations).toList();
  }
}
