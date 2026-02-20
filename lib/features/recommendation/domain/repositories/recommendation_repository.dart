import '../../../../core/errors/result.dart';
import '../entities/recommendation.dart';

abstract class RecommendationRepository {
  Future<Result<List<Recommendation>>> getRecommendations({
    required int budget,
    required List<String> franchises,
    SortMode sort = SortMode.bestValue,
    int personCount = 1,
  });
}
