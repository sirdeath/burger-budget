import '../../../../core/errors/result.dart';
import '../entities/recommendation.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendations {
  const GetRecommendations(this._repository);

  final RecommendationRepository _repository;

  Future<Result<List<Recommendation>>> call({
    required int budget,
    required List<String> franchises,
    SortMode sort = SortMode.bestValue,
  }) {
    return _repository.getRecommendations(
      budget: budget,
      franchises: franchises,
      sort: sort,
    );
  }
}
