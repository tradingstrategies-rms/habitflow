import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/family/domain/entities/family_circle.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/presentation/screens/family_dashboard_screen.dart';
import 'package:habitflow/features/analytics/application/providers/analytics_providers.dart';
import 'package:habitflow/features/analytics/domain/entities/family_productivity_score.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:mocktail/mocktail.dart';

class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  final testCircle = FamilyCircle(
    id: 'f1',
    name: 'Test Family',
    ownerProfileId: 'owner-1',
    createdAt: DateTime.now(),
  );

  final testProfile = FamilyProfile(
    id: 'owner-1',
    familyId: 'f1',
    displayName: 'Owner',
    profileType: ProfileType.adult,
    role: FamilyRole.owner,
    requiresPin: true,
    createdAt: DateTime.now(),
  );

  testWidgets('FamilyDashboardScreen renders all cards when family exists', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getFamilyCircle()).thenAnswer((_) async => testCircle);
    when(() => mockRepo.getProfiles(any())).thenAnswer((_) async => [testProfile]);
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => null);
    when(() => mockRepo.getAchievements()).thenAnswer((_) async => []);
    when(() => mockRepo.watchActivities(any())).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familyRepositoryProvider.overrideWithValue(mockRepo),
          familyProductivityScoreProvider(const Duration(days: 30)).overrideWithValue(
            AsyncValue.data(FamilyProductivityScore(
              familyId: 'f1',
              score: 80.0,
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              participatingProfileCount: 1,
              averageActivityRate: 0.8,
              trend: AnalyticsTrendDirection.stable,
              trendDelta: 0.0,
            )),
          ),
        ],
        child: const MaterialApp(
          home: FamilyDashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Pending Approvals'), findsOneWidget);
    expect(find.text('Shared Habits'), findsOneWidget);
    expect(find.text('Activity Feed'), findsOneWidget);
    expect(find.text('Family Settings'), findsOneWidget);
    expect(find.text('Family Achievements'), findsOneWidget);
  });
}
