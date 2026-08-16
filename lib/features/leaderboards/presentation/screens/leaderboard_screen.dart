import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums/leaderboard_type.dart';
import '../../domain/enums/leaderboard_period.dart';
import '../providers/leaderboard_providers.dart';
import '../widgets/leaderboard_entry_tile.dart';
import '../widgets/current_user_rank_card.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';

import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_feature_locked_view.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumServiceProvider).hasEntitlement(EntitlementType.premiumRewards);
    
    if (!isPremium) {
      return const Scaffold(
        appBar: HFTopAppBar(title: 'Leaderboard'),
        body: PremiumFeatureLockedView(
          title: 'Family Leaderboards',
          message: 'Compare your progress with family members and climb the ranks.',
          icon: Icons.leaderboard_rounded,
        ),
      );
    }

    final session = ref.watch(activeProfileSessionProvider);
    final familyState = ref.watch(familyProvider);
    final familyId = familyState.circle?.id;

    if (session == null) {
      return const Scaffold(body: Center(child: Text('Please select a profile')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'All-Time'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardList(
            type: LeaderboardType.family,
            period: LeaderboardPeriod.weekly,
            profileId: session.profileId,
            familyId: familyId,
          ),
          _LeaderboardList(
            type: LeaderboardType.family,
            period: LeaderboardPeriod.monthly,
            profileId: session.profileId,
            familyId: familyId,
          ),
          _LeaderboardList(
            type: LeaderboardType.family,
            period: LeaderboardPeriod.allTime,
            profileId: session.profileId,
            familyId: familyId,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends ConsumerWidget {
  final LeaderboardType type;
  final LeaderboardPeriod period;
  final String profileId;
  final String? familyId;

  const _LeaderboardList({
    required this.type,
    required this.period,
    required this.profileId,
    this.familyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(currentLeaderboardProvider((type, period, familyId)));

    return leaderboardAsync.when(
      data: (leaderboard) {
        if (leaderboard == null || leaderboard.entries.isEmpty) {
          return const Center(child: Text('No entries found for this period.'));
        }

        final currentUserEntry = leaderboard.entries.cast<dynamic>().firstWhere(
          (e) => e.profileId == profileId,
          orElse: () => null,
        );

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
              itemCount: leaderboard.entries.length,
              itemBuilder: (context, index) {
                final entry = leaderboard.entries[index];
                return LeaderboardEntryTile(
                  entry: entry,
                  isCurrentUser: entry.profileId == profileId,
                );
              },
            ),
            if (currentUserEntry != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CurrentUserRankCard(entry: currentUserEntry),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
