import 'package:burger_budget/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget({
    required String message,
    VoidCallback? onRetry,
  }) {
    return MaterialApp(
      theme: ThemeData(splashFactory: InkSplash.splashFactory),
      home: Scaffold(
        body: ErrorView(
          message: message,
          onRetry: onRetry,
        ),
      ),
    );
  }

  group('ErrorView', () {
    testWidgets('should display error icon', (tester) async {
      await tester.pumpWidget(
        createWidget(message: '테스트 오류 메시지'),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display error title', (tester) async {
      await tester.pumpWidget(
        createWidget(message: '테스트 오류 메시지'),
      );

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
    });

    testWidgets('should display error message', (tester) async {
      const message = '네트워크 연결을 확인해주세요';
      await tester.pumpWidget(
        createWidget(message: message),
      );

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          message: '테스트 오류',
          onRetry: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should not display retry button when onRetry is null',
        (tester) async {
      await tester.pumpWidget(
        createWidget(message: '테스트 오류'),
      );
      await tester.pumpAndSettle();

      expect(find.text('다시 시도'), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('should call onRetry when retry button is tapped',
        (tester) async {
      var retryTapped = false;

      await tester.pumpWidget(
        createWidget(
          message: '테스트 오류',
          onRetry: () => retryTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('다시 시도'));
      expect(retryTapped, isTrue);
    });

    testWidgets('should display all elements in correct order',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          message: '오류 메시지',
          onRetry: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Find all key elements
      final errorIcon = find.byIcon(Icons.error_outline);
      final errorTitle = find.text('오류가 발생했습니다');
      final errorMessage = find.text('오류 메시지');
      final retryButton = find.text('다시 시도');

      expect(errorIcon, findsOneWidget);
      expect(errorTitle, findsOneWidget);
      expect(errorMessage, findsOneWidget);
      expect(retryButton, findsOneWidget);

      // Verify vertical order (icon -> title -> message -> button)
      final iconY = tester.getCenter(errorIcon).dy;
      final titleY = tester.getCenter(errorTitle).dy;
      final messageY = tester.getCenter(errorMessage).dy;
      final buttonY = tester.getCenter(retryButton).dy;

      expect(iconY < titleY, isTrue);
      expect(titleY < messageY, isTrue);
      expect(messageY < buttonY, isTrue);
    });
  });
}
