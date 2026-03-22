/// 추천 알고리즘에서 사용하는 사용자 선호 신호
class UserPreference {
  const UserPreference({
    this.favoriteItemIds = const {},
    this.recent30dItemIds = const {},
    this.recent90dItemIds = const {},
    this.franchiseOrderCounts = const {},
  });

  /// 즐겨찾기에 포함된 모든 아이템 ID
  final Set<String> favoriteItemIds;

  /// 최근 30일 주문 이력의 아이템 ID
  final Set<String> recent30dItemIds;

  /// 최근 90일 주문 이력의 아이템 ID (30일 포함)
  final Set<String> recent90dItemIds;

  /// 프랜차이즈별 누적 주문 횟수
  final Map<String, int> franchiseOrderCounts;

  /// 가장 많이 주문한 프랜차이즈 코드
  String? get topFranchise {
    if (franchiseOrderCounts.isEmpty) return null;
    return franchiseOrderCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// 선호 데이터가 비어있는지 (신규 사용자)
  bool get isEmpty =>
      favoriteItemIds.isEmpty &&
      recent30dItemIds.isEmpty &&
      recent90dItemIds.isEmpty;
}
