import '../../features/menu/domain/entities/menu_item.dart';
import '../../features/recommendation/domain/entities/recommendation.dart';
import '../constants/app_constants.dart';
import 'currency_format.dart';

/// 단일 조합을 공유용 텍스트로 변환
String formatComboForShare({
  required MenuItem mainItem,
  MenuItem? sideItem,
  MenuItem? drinkItem,
  MenuItem? dessertItem,
  int? budget,
}) {
  final buffer = StringBuffer();
  final franchise =
      AppConstants.franchiseNames[mainItem.franchise] ?? mainItem.franchise;
  final emoji = AppConstants.franchiseEmojis[mainItem.franchise] ?? '';
  final totalPrice = mainItem.price +
      (sideItem?.price ?? 0) +
      (drinkItem?.price ?? 0) +
      (dessertItem?.price ?? 0);

  final items = <String>[mainItem.name];
  if (sideItem != null) items.add(sideItem.name);
  if (drinkItem != null) items.add(drinkItem.name);
  if (dessertItem != null) items.add(dessertItem.name);

  buffer.writeln('$emoji $franchise ${items.join(' + ')}');
  buffer.writeln('💰 ${formatKRW(totalPrice)}');

  if (budget != null && budget > totalPrice) {
    buffer.writeln(
      '   예산 ${formatKRW(budget)}에서 ${formatKRW(budget - totalPrice)} 남음',
    );
  }

  final totalCalories = _calcTotalCalories(
    mainItem,
    sideItem,
    drinkItem,
    dessertItem,
  );
  if (totalCalories != null) {
    buffer.writeln('🔥 $totalCalories kcal');
  }

  buffer.write('\n#버짓 으로 추천받았어요');
  return buffer.toString();
}

/// 전체 추천 결과를 공유용 텍스트로 변환 (최대 5개)
String formatResultsForShare({
  required int budget,
  required List<Recommendation> recommendations,
  int personCount = 1,
}) {
  final buffer = StringBuffer();

  buffer.writeln('🍔 버짓 추천 결과');
  if (personCount > 1) {
    buffer.writeln(
      '💰 예산: ${formatKRW(budget)} '
      '($personCount인, 1인당 ${formatKRW(budget ~/ personCount)})',
    );
  } else {
    buffer.writeln('💰 예산: ${formatKRW(budget)}');
  }
  buffer.writeln();

  const maxShare = 5;
  final showCount =
      recommendations.length > maxShare ? maxShare : recommendations.length;

  for (var i = 0; i < showCount; i++) {
    final r = recommendations[i];
    final parts = <String>[r.mainItem.name];
    if (r.sideItem != null) parts.add(r.sideItem!.name);
    if (r.drinkItem != null) parts.add(r.drinkItem!.name);
    if (r.dessertItem != null) parts.add(r.dessertItem!.name);

    final franchise = AppConstants.franchiseNames[r.mainItem.franchise] ??
        r.mainItem.franchise;
    final saving = budget - r.totalPrice;

    buffer.write(
      '${i + 1}. [$franchise] ${parts.join(' + ')} '
      '→ ${formatKRW(r.totalPrice)}',
    );
    if (saving > 0) {
      buffer.write(' (${formatKRW(saving)} 절약)');
    }
    buffer.writeln();
  }

  if (recommendations.length > maxShare) {
    buffer.writeln('외 ${recommendations.length - maxShare}개 더 보기');
  }

  buffer.write('\n#버짓 으로 추천받았어요');
  return buffer.toString();
}

int? _calcTotalCalories(
  MenuItem main,
  MenuItem? side,
  MenuItem? drink, [
  MenuItem? dessert,
]) {
  if (main.calories == null) return null;
  return main.calories! +
      (side?.calories ?? 0) +
      (drink?.calories ?? 0) +
      (dessert?.calories ?? 0);
}
