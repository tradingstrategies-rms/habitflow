import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/reward_store/data/models/reward_item_model.dart';
import 'package:habitflow/features/reward_store/data/models/reward_redemption_model.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_redemption.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:habitflow/features/reward_store/domain/enums/redemption_status.dart';

void main() {
  group('RewardStore Models', () {
    const item = RewardItem(
      id: '1',
      title: 'Item',
      description: 'Desc',
      pointsCost: 50,
      category: RewardCategory.experience,
      imageUrl: 'img',
      eligibleProfileIds: ['p1'],
    );

    test('RewardItemModel serialization', () {
      final model = RewardItemModel.fromEntity(item);
      final json = model.toJson();
      final fromJson = RewardItemModel.fromJson(json);
      expect(fromJson.id, item.id);
      expect(fromJson.pointsCost, item.pointsCost);
      expect(fromJson.eligibleProfileIds, item.eligibleProfileIds);
    });

    test('RewardRedemptionModel serialization', () {
      final redemption = RewardRedemption(
        id: 'r1',
        profileId: 'p1',
        rewardItemId: '1',
        pointsSpent: 50,
        status: RedemptionStatus.fulfilled,
        createdAt: DateTime(2026, 8, 4),
      );
      final model = RewardRedemptionModel.fromEntity(redemption);
      final json = model.toJson();
      final fromJson = RewardRedemptionModel.fromJson(json);
      expect(fromJson.id, redemption.id);
      expect(fromJson.status, redemption.status);
    });
  });
}
