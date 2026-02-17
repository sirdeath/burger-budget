import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('하단 네비게이션', () {
    testWidgets('4탭 전환 시 올바른 화면 표시', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 1. 홈 탭 (기본)
      expect(find.text('Burger Budget'), findsOneWidget);

      // 2. 즐겨찾기 탭
      await tester.tap(find.text('즐겨찾기'));
      await tester.pumpAndSettle();
      expect(find.text('즐겨찾기'), findsWidgets); // AppBar + NavBar label

      // 3. 이력 탭
      await tester.tap(find.text('이력'));
      await tester.pumpAndSettle();
      expect(find.text('주문 이력'), findsOneWidget);

      // 4. 설정 탭
      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();
      expect(find.text('설정'), findsWidgets); // AppBar + NavBar label

      // 5. 홈으로 복귀
      await tester.tap(find.text('홈'));
      await tester.pumpAndSettle();
      expect(find.text('Burger Budget'), findsOneWidget);
    });

    testWidgets('검색 아이콘으로 검색 화면 진입/복귀', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 검색 아이콘 탭
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // MenuSearchScreen 진입 확인
      expect(find.text('메뉴 검색'), findsOneWidget);
      expect(find.text('메뉴를 검색해보세요'), findsOneWidget);

      // 뒤로가기
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
      } else {
        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator).last,
        );
        navigator.pop();
      }
      await tester.pumpAndSettle();

      // HomeScreen 복귀
      expect(find.text('Burger Budget'), findsOneWidget);
    });
  });
}
