import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/shared/widgets/business/business.dart';

void main() {
  group('HFHabitTile', () {
    testWidgets('renders title and streak', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HFHabitTile(
              title: 'Water',
              isCompleted: false,
              streakCount: 3,
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.text('Water'), findsOneWidget);
      expect(find.text('3 day streak'), findsOneWidget);
    });

    testWidgets('calls onToggle when checkbox tapped', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      bool toggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HFHabitTile(
              title: 'Water',
              isCompleted: false,
              streakCount: 3,
              onToggle: () => toggled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('habit_tile_toggle')));
      expect(toggled, isTrue);
      handle.dispose();
    });
  });

  group('HFGoalCard', () {
    testWidgets('renders title and progress percentage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HFGoalCard(
              title: 'Savings',
              currentValue: 50,
              targetValue: 100,
              unit: 'USD',
            ),
          ),
        ),
      );

      expect(find.text('Savings'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('50 / 100 USD'), findsOneWidget);
    });
  });
}
