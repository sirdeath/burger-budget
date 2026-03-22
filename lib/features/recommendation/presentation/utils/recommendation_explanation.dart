import '../../domain/entities/recommendation.dart';

/// 추천 이유를 사용자 문장으로 변환 (presentation layer)
List<String> getExplanations(Recommendation rec) {
  if (rec.scoreBreakdown.isEmpty) return [];
  final reasons = <String>[];

  final pref = rec.scoreBreakdown['pref'] ?? 0;
  final meal = rec.scoreBreakdown['meal'] ?? 0;
  final util = rec.scoreBreakdown['util'] ?? 0;
  final utilPct = rec.scoreBreakdown['utilPct'] ?? 0;
  final set_ = rec.scoreBreakdown['set'] ?? 0;
  final sig = rec.scoreBreakdown['sig'] ?? 0;

  if (pref > 0.25) {
    reasons.add('즐겨찾기 메뉴가 포함돼 있어요');
  } else if (pref > 0.10) {
    reasons.add('자주 고른 브랜드를 반영했어요');
  }

  if (meal >= 1.0) {
    reasons.add('메인 + 사이드 + 음료가 갖춰진 조합이에요');
  }

  if (util > 0.8 && utilPct > 0) {
    final pct = (utilPct * 100).round();
    reasons.add('예산의 $pct%를 효율적으로 사용했어요');
  }

  if (set_ > 0) {
    reasons.add('세트 메뉴 — 개별 주문보다 가성비 좋아요');
  }

  if (sig > 0 && reasons.length < 2) {
    reasons.add('인기 시그니처 메뉴에요');
  }

  return reasons.take(2).toList();
}
