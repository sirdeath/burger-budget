import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('검색 플로우', () {
    testWidgets('검색어 입력 → 결과 표시', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 검색 화면 진입
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('메뉴 검색'), findsOneWidget);

      // '빅맥' 입력
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '빅맥');
      await tester.pumpAndSettle();

      // 검색 결과 표시 확인
      expect(find.text('빅맥'), findsWidgets); // 검색 입력 + 결과 카드
    });

    testWidgets('검색 결과 없을 때 안내 메시지', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 존재하지 않는 메뉴 검색
      await tester.enterText(find.byType(TextField), '없는메뉴');
      await tester.pumpAndSettle();

      expect(find.text('검색 결과가 없습니다'), findsOneWidget);
    });

    testWidgets('검색어 클리어 → 초기 상태 복귀', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 검색어 입력
      await tester.enterText(find.byType(TextField), '빅맥');
      await tester.pumpAndSettle();

      // 클리어 버튼 탭
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // 초기 상태 복귀
      expect(find.text('메뉴를 검색해보세요'), findsOneWidget);
    });
  });
}
