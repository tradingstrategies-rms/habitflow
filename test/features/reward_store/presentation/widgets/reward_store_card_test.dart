import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:habitflow/features/reward_store/presentation/widgets/reward_store_card.dart';

void main() {
  const item = RewardItem(
    id: '1',
    title: 'Movie Night',
    description: 'A family movie night with popcorn.',
    pointsCost: 500,
    category: RewardCategory.experience,
  );

  testWidgets('RewardStoreCard displays info correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RewardStoreCard(item: item),
        ),
      ),
    );

    expect(find.text('Movie Night'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('A family movie night with popcorn.'), findsOneWidget);
  });

  testWidgets('RewardStoreCard shows unavailable state', (tester) async {
    const unavailableItem = RewardItem(
      id: '1',
      title: 'Movie Night',
      description: 'D',
      pointsCost: 500,
      category: RewardCategory.experience,
      isAvailable: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RewardStoreCard(item: unavailableItem),
        ),
      ),
    );

    expect(find.text('UNAVAILABLE'), findsOneWidget);
  });
}
