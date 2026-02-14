import 'package:burger_budget/core/constants/app_constants.dart';
import 'package:burger_budget/features/recommendation/presentation/widgets/franchise_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget() {
    return ProviderScope(
      child: MaterialApp(
        // Avoid ink_sparkle.frag shader loading in test environment
        theme: ThemeData(splashFactory: InkSplash.splashFactory),
        home: const Scaffold(body: FranchiseChips()),
      ),
    );
  }

  group('FranchiseChips', () {
    testWidgets('should display "전체" chip and all franchise chips',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('전체'), findsOneWidget);
      for (final name in AppConstants.franchiseNames.values) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('all chips should be unselected initially', (tester) async {
      await tester.pumpWidget(createWidget());

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      for (final chip in chips) {
        expect(chip.selected, isFalse);
      }
    });

    testWidgets('should select individual franchise chip on tap',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text("McDonald's"));
      await tester.pump();

      final chip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text("McDonald's"),
          matching: find.byType(FilterChip),
        ),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('should deselect franchise chip on second tap',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text("McDonald's"));
      await tester.pump();
      await tester.tap(find.text("McDonald's"));
      await tester.pump();

      final chip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text("McDonald's"),
          matching: find.byType(FilterChip),
        ),
      );
      expect(chip.selected, isFalse);
    });

    testWidgets('should select all franchises when "전체" is tapped',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('전체'));
      await tester.pump();

      for (final name in AppConstants.franchiseNames.values) {
        final chip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text(name),
            matching: find.byType(FilterChip),
          ),
        );
        expect(chip.selected, isTrue);
      }
    });

    testWidgets('should deselect all when "전체" is tapped twice',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('전체'));
      await tester.pump();
      await tester.tap(find.text('전체'));
      await tester.pump();

      for (final name in AppConstants.franchiseNames.values) {
        final chip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text(name),
            matching: find.byType(FilterChip),
          ),
        );
        expect(chip.selected, isFalse);
      }
    });

    testWidgets(
        'should auto-uncheck "전체" when individual chip is deselected',
        (tester) async {
      await tester.pumpWidget(createWidget());

      // Select all
      await tester.tap(find.text('전체'));
      await tester.pump();

      // Deselect one
      await tester.tap(find.text("McDonald's"));
      await tester.pump();

      final allChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('전체'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(allChip.selected, isFalse);
    });
  });
}
