import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_redemption.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:habitflow/features/reward_store/domain/enums/redemption_status.dart';
import 'package:habitflow/features/reward_store/presentation/providers/reward_store_providers.dart';
import 'package:habitflow/features/reward_store/presentation/screens/redemption_history_screen.dart';

void main() {
  const item = RewardItem(
    id: 'i1', title: 'T1', description: 'D1', pointsCost: 10, category: RewardCategory.digital
  );

  final redemption = RewardRedemption(
    id: 'r1',
    profileId: 'p1',
    rewardItemId: 'i1',
    pointsSpent: 10,
    status: RedemptionStatus.fulfilled,
    createdAt: DateTime.now(),
  );

  testWidgets('RedemptionHistoryScreen shows list', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          redemptionHistoryProvider('p1').overrideWith((ref) => Future.value([redemption])),
          rewardItemByIdProvider('i1').overrideWith((ref) => Future.value(item)),
        ],
        child: const MaterialApp(
          home: RedemptionHistoryScreen(profileId: 'p1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('T1'), findsOneWidget);
    expect(find.text('FULFILLED'), findsOneWidget);
  });
}
