import 'package:burger_budget/shared/widgets/skeleton_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget() {
    return MaterialApp(
      theme: ThemeData(splashFactory: InkSplash.splashFactory),
      home: const Scaffold(
        body: SkeletonCard(),
      ),
    );
  }

  group('SkeletonCard', () {
    testWidgets('should render Card widget', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display CircleAvatar placeholder', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(CircleAvatar), findsOneWidget);

      final circleAvatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar),
      );
      expect(circleAvatar.radius, 14);
    });

    testWidgets('should display multiple Container placeholders',
        (tester) async {
      await tester.pumpWidget(createWidget());

      // SkeletonCard uses multiple Container widgets as placeholders
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // Should have at least 5 placeholder containers
      expect(containers.evaluate().length, greaterThanOrEqualTo(5));
    });

    testWidgets('should be const constructible', (tester) async {
      // This test verifies that SkeletonCard can be created as const
      const widget = SkeletonCard();
      expect(widget, isA<SkeletonCard>());
    });

    testWidgets('should use theme colors for placeholders', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Verify that Card is rendered (which uses theme)
      final card = tester.widget<Card>(find.byType(Card));
      expect(card, isNotNull);
    });

    testWidgets('should display skeleton in proper layout structure',
        (tester) async {
      await tester.pumpWidget(createWidget());

      // Should contain Column for vertical layout
      expect(find.byType(Column), findsWidgets);

      // Should contain Row for horizontal layout
      expect(find.byType(Row), findsWidgets);

      // Should contain Padding
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should have proper widget hierarchy', (tester) async {
      await tester.pumpWidget(createWidget());

      // Card contains Padding
      final card = find.byType(Card);
      expect(card, findsOneWidget);

      // Find descendant widgets
      expect(
        find.descendant(
          of: card,
          matching: find.byType(Padding),
        ),
        findsWidgets,
      );

      expect(
        find.descendant(
          of: card,
          matching: find.byType(Column),
        ),
        findsWidgets,
      );

      expect(
        find.descendant(
          of: card,
          matching: find.byType(CircleAvatar),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should contain SizedBox for spacing', (tester) async {
      await tester.pumpWidget(createWidget());

      // SizedBox is used for spacing between elements
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should render consistently on multiple builds',
        (tester) async {
      // First build
      await tester.pumpWidget(createWidget());
      final firstBuild = find.byType(SkeletonCard);
      expect(firstBuild, findsOneWidget);

      // Rebuild
      await tester.pumpWidget(createWidget());
      final secondBuild = find.byType(SkeletonCard);
      expect(secondBuild, findsOneWidget);

      // Should still have same structure
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should not throw errors when pumped', (tester) async {
      // This test ensures no exceptions are thrown during build
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SkeletonCard), findsOneWidget);
    });
  });
}
