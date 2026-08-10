import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_redemption.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:habitflow/features/reward_store/domain/enums/redemption_status.dart';

void main() {
  group('Reward Store Domain', () {
    test('RewardItem equality works correctly', () {
      const item1 = RewardItem(
        id: '1',
        title: 'T1',
        description: 'D1',
        pointsCost: 10,
        category: RewardCategory.digital,
      );
      const item2 = RewardItem(
        id: '1',
        title: 'T2',
        description: 'D2',
        pointsCost: 20,
        category: RewardCategory.physical,
      );
      const item3 = RewardItem(
        id: '2',
        title: 'T1',
        description: 'D1',
        pointsCost: 10,
        category: RewardCategory.digital,
      );

      expect(item1, item2);
      expect(item1, isNot(item3));
    });

    test('RewardRedemption copyWith works correctly', () {
      final redemption = RewardRedemption(
        id: 'r1',
        profileId: 'p1',
        rewardItemId: 'i1',
        pointsSpent: 100,
        status: RedemptionStatus.pending,
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = redemption.copyWith(status: RedemptionStatus.approved);
      expect(updated.status, RedemptionStatus.approved);
      expect(updated.id, redemption.id);
    });
  });
}
