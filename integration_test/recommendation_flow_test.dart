import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('추천 전체 플로우', () {
    testWidgets('예산 입력 → 프랜차이즈 선택 → 추천 → 결과 표시', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 1. HomeScreen 표시 확인
      expect(find.text('buzit'), findsOneWidget);
      expect(
        find.text('예산을 입력하고\n프랜차이즈를 선택하세요'),
        findsOneWidget,
      );

      // 2. 예산 입력
      await tester.enterText(find.byType(TextField), '15000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // 3. 프랜차이즈 선택
      await tester.tap(find.text("McDonald's"));
      await tester.pump();

      // 4. 추천받기 버튼 활성화 확인 및 탭
      final recommendButton = find.text('추천받기');
      expect(recommendButton, findsOneWidget);
      await tester.tap(recommendButton);
      await tester.pumpAndSettle();

      // 5. ResultsScreen 표시 확인
      expect(find.text('추천 결과 (15,000원)'), findsOneWidget);

      // 6. 추천 결과 카드 존재 확인
      expect(find.text('빅맥'), findsOneWidget);
    });

    testWidgets('추천 결과 없음 시 빈 상태 표시', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 예산을 매우 낮게 설정
      await tester.enterText(find.byType(TextField), '1000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.text("McDonald's"));
      await tester.pump();

      await tester.tap(find.text('추천받기'));
      await tester.pumpAndSettle();

      // 빈 상태 메시지 확인
      expect(find.text('추천 가능한 메뉴가 없습니다'), findsOneWidget);
    });

    testWidgets('뒤로가기로 HomeScreen 복귀', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '15000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.text("McDonald's"));
      await tester.pump();

      await tester.tap(find.text('추천받기'));
      await tester.pumpAndSettle();

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

      // HomeScreen 복귀 확인
      expect(find.text('buzit'), findsOneWidget);
    });
  });
}
