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
}) {
  final buffer = StringBuffer();
  final franchise =
      AppConstants.franchiseNames[mainItem.franchise] ?? mainItem.franchise;
  final emoji =
      AppConstants.franchiseEmojis[mainItem.franchise] ?? '';
  final totalPrice = mainItem.price +
      (sideItem?.price ?? 0) +
      (drinkItem?.price ?? 0) +
      (dessertItem?.price ?? 0);

  buffer.writeln('$emoji $franchise 추천 조합');
  buffer.writeln();
  buffer.writeln('🍔 메인: ${mainItem.name} - ${formatKRW(mainItem.price)}');
  if (sideItem != null) {
    buffer.writeln(
      '🍟 사이드: ${sideItem.name} - ${formatKRW(sideItem.price)}',
    );
  }
  if (drinkItem != null) {
    buffer.writeln(
      '🥤 음료: ${drinkItem.name} - ${formatKRW(drinkItem.price)}',
    );
  }
  if (dessertItem != null) {
    buffer.writeln(
      '🍦 디저트: ${dessertItem.name} - ${formatKRW(dessertItem.price)}',
    );
  }
  buffer.writeln();
  buffer.writeln('💰 총 가격: ${formatKRW(totalPrice)}');

  final totalCalories = _calcTotalCalories(
    mainItem,
    sideItem,
    drinkItem,
    dessertItem,
  );
  if (totalCalories != null) {
    buffer.writeln('🔥 총 칼로리: $totalCalories kcal');
  }

  buffer.write('\n#버짓');
  return buffer.toString();
}

/// 전체 추천 결과를 공유용 텍스트로 변환
String formatResultsForShare({
  required int budget,
  required List<Recommendation> recommendations,
}) {
  final buffer = StringBuffer();

  buffer.writeln('🍔 버짓 추천 결과');
  buffer.writeln('💰 예산: ${formatKRW(budget)}');
  buffer.writeln();

  for (var i = 0; i < recommendations.length; i++) {
    final r = recommendations[i];
    final parts = <String>[r.mainItem.name];
    if (r.sideItem != null) parts.add(r.sideItem!.name);
    if (r.drinkItem != null) parts.add(r.drinkItem!.name);
    if (r.dessertItem != null) parts.add(r.dessertItem!.name);

    final franchise =
        AppConstants.franchiseNames[r.mainItem.franchise] ??
        r.mainItem.franchise;

    buffer.writeln(
      '${i + 1}. [$franchise] ${parts.join(' + ')} '
      '(${formatKRW(r.totalPrice)})',
    );
  }

  buffer.write('\n#버짓');
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
