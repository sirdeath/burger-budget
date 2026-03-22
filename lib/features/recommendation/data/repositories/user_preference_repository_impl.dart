import '../../../../core/database/user_database_helper.dart';
import '../../domain/entities/user_preference.dart';
import '../../domain/repositories/user_preference_repository.dart';

class UserPreferenceRepositoryImpl
    implements UserPreferenceRepository {
  const UserPreferenceRepositoryImpl(this._dbHelper);

  final UserDatabaseHelper _dbHelper;

  @override
  Future<UserPreference> getUserPreference() async {
    final db = await _dbHelper.database;

    // 1. 즐겨찾기 아이템 ID 수집
    final favRows = await db.query(
      'favorites',
      columns: [
        'main_item_id',
        'side_item_id',
        'drink_item_id',
      ],
    );
    final favoriteIds = <String>{};
    for (final row in favRows) {
      favoriteIds.add(row['main_item_id']! as String);
      final side = row['side_item_id'] as String?;
      if (side != null) favoriteIds.add(side);
      final drink = row['drink_item_id'] as String?;
      if (drink != null) favoriteIds.add(drink);
    }

    // 2. 전체 주문 이력 1회 조회 → 30일/90일 + 프랜차이즈 횟수 동시 추출
    final now = DateTime.now();
    final d30 =
        now.subtract(const Duration(days: 30)).toIso8601String();
    final d90 =
        now.subtract(const Duration(days: 90)).toIso8601String();

    final historyRows = await db.query(
      'order_history',
      columns: [
        'main_item_id',
        'side_item_id',
        'drink_item_id',
        'created_at',
      ],
    );

    final recent30Ids = <String>{};
    final recent90Ids = <String>{};
    final franchiseCounts = <String, int>{};

    for (final row in historyRows) {
      final createdAt = row['created_at'] as String;
      final mainId = row['main_item_id']! as String;
      final sideId = row['side_item_id'] as String?;
      final drinkId = row['drink_item_id'] as String?;

      // 프랜차이즈 횟수 집계
      final franchise = _extractFranchise(mainId);
      if (franchise != null) {
        franchiseCounts[franchise] =
            (franchiseCounts[franchise] ?? 0) + 1;
      }

      // 날짜별 분류
      if (createdAt.compareTo(d90) >= 0) {
        final ids = <String>[mainId];
        if (sideId != null) ids.add(sideId);
        if (drinkId != null) ids.add(drinkId);

        recent90Ids.addAll(ids);
        if (createdAt.compareTo(d30) >= 0) {
          recent30Ids.addAll(ids);
        }
      }
    }

    return UserPreference(
      favoriteItemIds: favoriteIds,
      recent30dItemIds: recent30Ids,
      recent90dItemIds: recent90Ids,
      franchiseOrderCounts: franchiseCounts,
    );
  }

  /// 아이템 ID에서 프랜차이즈 코드 추출 (예: 'mcd_1' → 'mcd')
  static String? _extractFranchise(String itemId) {
    final idx = itemId.lastIndexOf('_');
    if (idx <= 0) return null;
    return itemId.substring(0, idx);
  }
}
