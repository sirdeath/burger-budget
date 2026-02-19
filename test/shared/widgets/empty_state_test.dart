import 'package:burger_budget/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget({
    required IconData icon,
    required String title,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return MaterialApp(
      theme: ThemeData(splashFactory: InkSplash.splashFactory),
      home: Scaffold(
        body: EmptyState(
          icon: icon,
          title: title,
          description: description,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  group('EmptyState', () {
    testWidgets('should display icon', (tester) async {
      await tester.pumpWidget(
        createWidget(
          icon: Icons.search_off,
          title: '검색 결과 없음',
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('should display title', (tester) async {
      const title = '데이터가 없습니다';
      await tester.pumpWidget(
        createWidget(
          icon: Icons.inbox,
          title: title,
        ),
      );

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('should display description when provided', (tester) async {
      const description = '새로운 항목을 추가해보세요';
      await tester.pumpWidget(
        createWidget(
          icon: Icons.inbox,
          title: '비어있음',
          description: description,
        ),
      );

      expect(find.text(description), findsOneWidget);
    });

    testWidgets('should not display description when null', (tester) async {
      await tester.pumpWidget(
        createWidget(
          icon: Icons.inbox,
          title: '비어있음',
        ),
      );

      // Only the title should exist, no extra text
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should display action button when both label and callback provided',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          icon: Icons.error,
          title: '오류',
          actionLabel: '돌아가기',
          onAction: () {},
        ),
      );

      expect(find.text('돌아가기'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is FilledButton), findsOneWidget);
    });

    testWidgets('should not display action button when label is null',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          icon: Icons.inbox,
          title: '비어있음',
          onAction: () {},
        ),
      );

      expect(find.byWidgetPredicate((w) => w is FilledButton), findsNothing);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('should not display action button when callback is null',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          icon: Icons.inbox,
          title: '비어있음',
          actionLabel: '돌아가기',
        ),
      );

      expect(find.byWidgetPredicate((w) => w is FilledButton), findsNothing);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('should call onAction when action button is tapped',
        (tester) async {
      var actionTapped = false;

      await tester.pumpWidget(
        createWidget(
          icon: Icons.error,
          title: '오류',
          actionLabel: '돌아가기',
          onAction: () => actionTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('돌아가기'));
      expect(actionTapped, isTrue);
    });

    testWidgets('should display all elements when fully configured',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          icon: Icons.inbox,
          title: '비어있음',
          description: '항목이 하나도 없습니다',
          actionLabel: '추가하기',
          onAction: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('비어있음'), findsOneWidget);
      expect(find.text('항목이 하나도 없습니다'), findsOneWidget);
      expect(find.text('추가하기'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('should display elements in correct vertical order',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          icon: Icons.inbox,
          title: '비어있음',
          description: '설명 텍스트',
          actionLabel: '버튼',
          onAction: () {},
        ),
      );
      await tester.pumpAndSettle();

      final iconY = tester.getCenter(find.byIcon(Icons.inbox)).dy;
      final titleY = tester.getCenter(find.text('비어있음')).dy;
      final descY = tester.getCenter(find.text('설명 텍스트')).dy;
      final buttonY = tester.getCenter(find.text('버튼')).dy;

      expect(iconY < titleY, isTrue);
      expect(titleY < descY, isTrue);
      expect(descY < buttonY, isTrue);
    });

    testWidgets('should work with different icon types', (tester) async {
      final icons = [
        Icons.search_off,
        Icons.inbox,
        Icons.error_outline,
        Icons.favorite_border,
      ];

      for (final icon in icons) {
        await tester.pumpWidget(
          createWidget(
            icon: icon,
            title: 'Test',
          ),
        );

        expect(find.byIcon(icon), findsOneWidget);
      }
    });
  });
}
