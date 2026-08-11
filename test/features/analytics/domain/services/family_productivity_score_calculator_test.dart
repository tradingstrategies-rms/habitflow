import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:habitflow/features/analytics/domain/entities/family_productivity_score.dart';
import 'package:habitflow/features/analytics/domain/services/analytics_metrics_calculator.dart';
import 'package:habitflow/features/analytics/domain/services/family_productivity_score_calculator.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/entities/shared_habit.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/enums/shared_habit_completion_mode.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_priority.dart';

void main() {
  late FamilyProductivityScoreCalculator calculator;
  late AnalyticsMetricsCalculator metricsCalculator;

  setUp(() {
    metricsCalculator = const AnalyticsMetricsCalculator();
    calculator = FamilyProductivityScoreCalculator(metricsCalculator);
  });

  Habit createHabit(String id, String userId) {
    return Habit(
      id: id,
      userId: userId,
      title: 'Habit $id',
      category: HabitCategory.health,
      icon: HabitIcon.exercise,
      color: HabitColor.emerald,
      priority: HabitPriority.medium,
      frequency: HabitFrequency.daily,
      targetValue: 1.0,
      unit: 'times',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  FamilyProfile createProfile(String id, ProfileType type) {
    return FamilyProfile(
      id: id,
      familyId: 'f1',
      displayName: 'Profile $id',
      profileType: type,
      role: type == ProfileType.adult ? FamilyRole.owner : FamilyRole.child,
      requiresPin: false,
      createdAt: DateTime.now(),
    );
  }

  group('FamilyProductivityScoreCalculator', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 6));
    final endDate = today;

    test('returns zero score for empty family', () {
      final score = calculator.calculate(
        familyId: 'f1',
        profiles: [],
        allHabits: [],
        sharedHabits: [],
        allCompletions: [],
        startDate: startDate,
        endDate: endDate,
      );

      expect(score.score, 0.0);
      expect(score.participatingProfileCount, 0);
    });

    test('calculates score for one active profile with perfect activity', () {
      final profile = createProfile('p1', ProfileType.adult);
      final habit = createHabit('h1', 'p1');
      
      final completions = List.generate(7, (i) => HabitCompletion(
        id: 'c$i',
        habitId: 'h1',
        completionDate: startDate.add(Duration(days: i)),
        completed: true,
        completedAt: startDate.add(Duration(days: i)),
        createdAt: startDate.add(Duration(days: i)),
      ));

      final score = calculator.calculate(
        familyId: 'f1',
        profiles: [profile],
        allHabits: [habit],
        sharedHabits: [],
        allCompletions: completions,
        startDate: startDate,
        endDate: endDate,
      );

      expect(score.score, 100.0);
      expect(score.participatingProfileCount, 1);
    });

    test('calculates score for one active profile with partial activity', () {
      final profile = createProfile('p1', ProfileType.adult);
      final habit = createHabit('h1', 'p1');
      
      // 4 out of 7 days completed
      final completions = List.generate(4, (i) => HabitCompletion(
        id: 'c$i',
        habitId: 'h1',
        completionDate: startDate.add(Duration(days: i)),
        completed: true,
        completedAt: startDate.add(Duration(days: i)),
        createdAt: startDate.add(Duration(days: i)),
      ));

      final score = calculator.calculate(
        familyId: 'f1',
        profiles: [profile],
        allHabits: [habit],
        sharedHabits: [],
        allCompletions: completions,
        startDate: startDate,
        endDate: endDate,
      );

      // (4/7) * 100 = 57.14... -> 57.1 due to toStringAsFixed(1)
      expect(score.score, 57.1);
    });

    test('fairly aggregates scores across multiple profiles', () {
      final p1 = createProfile('p1', ProfileType.adult);
      final p2 = createProfile('p2', ProfileType.child);
      
      final h1 = createHabit('h1', 'p1');
      final h2 = createHabit('h2', 'p2');
      
      // P1: perfect (100)
      final c1 = List.generate(7, (i) => HabitCompletion(
        id: 'c1_$i', habitId: 'h1', completionDate: startDate.add(Duration(days: i)),
        completed: true, completedAt: now, createdAt: now,
      ));
      
      // P2: zero (0)
      final c2 = <HabitCompletion>[];

      final score = calculator.calculate(
        familyId: 'f1',
        profiles: [p1, p2],
        allHabits: [h1, h2],
        sharedHabits: [],
        allCompletions: [...c1, ...c2],
        startDate: startDate,
        endDate: endDate,
      );

      // Average of 100 and 0 = 50
      expect(score.score, 50.0);
      expect(score.participatingProfileCount, 2);
    });

    test('handles shared habits correctly', () {
      final p1 = createProfile('p1', ProfileType.adult);
      final p2 = createProfile('p2', ProfileType.child);
      
      // Shared habit assigned to both
      final h1 = createHabit('h1', 'p1'); // Owner is p1, but assigned to both
      final sh1 = SharedHabit(
        id: 'sh1',
        habitId: 'h1',
        assignedMemberIds: const ['p1', 'p2'],
        completionMode: SharedHabitCompletionMode.anyOne,
        createdBy: 'p1',
        createdAt: now,
      );

      // Completions by P1 count for P1 and P2 if we look at the same habit?
      // Wait, in my calculator logic:
      // final profileHabits = allHabits.where((h) {
      //   if (h.userId == profile.id) return true;
      //   try {
      //     final shared = sharedHabits.firstWhere((sh) => sh.habitId == h.id);
      //     return shared.assignedMemberIds.contains(profile.id);
      //   } catch (_) { return false; }
      // }).toList();
      
      // If P1 completes H1, and H1 is assigned to P2 via SH1, then P2 also has H1 as a profileHabit.
      // And metrics for H1 use allCompletions for H1.
      
      final c1 = List.generate(7, (i) => HabitCompletion(
        id: 'c1_$i', habitId: 'h1', completionDate: startDate.add(Duration(days: i)),
        completed: true, completedAt: now, createdAt: now,
      ));

      final score = calculator.calculate(
        familyId: 'f1',
        profiles: [p1, p2],
        allHabits: [h1],
        sharedHabits: [sh1],
        allCompletions: c1,
        startDate: startDate,
        endDate: endDate,
      );

      // Both have H1 as their only habit, H1 is 100% active.
      // So both profiles are 100%. Family score = 100%.
      expect(score.score, 100.0);
    });

    test('calculates trend correctly', () {
      final p1 = createProfile('p1', ProfileType.adult);
      final h1 = createHabit('h1', 'p1');

      final baselineScore = FamilyProductivityScore(
        familyId: 'f1',
        score: 40.0,
        startDate: startDate.subtract(const Duration(days: 7)),
        endDate: startDate.subtract(const Duration(days: 1)),
        participatingProfileCount: 1,
        averageActivityRate: 0.4,
        trend: AnalyticsTrendDirection.stable,
        trendDelta: 0.0,
      );

      // Current score 100
      final completions = List.generate(7, (i) => HabitCompletion(
        id: 'c$i', habitId: 'h1', completionDate: startDate.add(Duration(days: i)),
        completed: true, completedAt: now, createdAt: now,
      ));

      final score = calculator.calculate(
        familyId: 'f1',
        profiles: [p1],
        allHabits: [h1],
        sharedHabits: [],
        allCompletions: completions,
        startDate: startDate,
        endDate: endDate,
        baselineScore: baselineScore,
      );

      expect(score.trend, AnalyticsTrendDirection.improving);
      expect(score.trendDelta, 60.0);
    });
  });
}
