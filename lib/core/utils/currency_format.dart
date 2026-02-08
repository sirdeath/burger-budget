import 'package:intl/intl.dart';

final _krwFormat = NumberFormat('#,###', 'ko_KR');

String formatKRW(int price) {
  return '${_krwFormat.format(price)}원';
}
