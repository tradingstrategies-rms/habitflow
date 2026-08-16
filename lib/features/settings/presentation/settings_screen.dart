import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/sync/models/sync_status.dart';
import 'package:habitflow/core/sync/providers/sync_providers.dart';
import 'package:habitflow/core/sync/services/gamification_sync_service.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import '../application/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final settings = ref.watch(settingsProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final session = ref.watch(activeProfileSessionProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final isChild = activeProfile?.profileType == ProfileType.child;

    return Scaffold(
      appBar: const HFTopAppBar(title: 'Settings'),
      body: ListView(
        children: [
          const HFSectionHeader(title: 'Appearance'),
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(themeMode.name.toUpperCase()),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              _showThemePicker(context, ref);
            },
          ),
          ListTile(
            title: const Text('Country'),
            subtitle: Text('${settings.selectedCountry.flag} ${settings.selectedCountry.name}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              context.pushNamed(RouteNames.countrySelection);
            },
          ),
          const HFSectionHeader(title: 'Cloud Sync'),
          ListTile(
            title: const Text('Status'),
            subtitle: Text(_getSyncStatusText(syncStatus)),
            leading: _getSyncStatusIcon(syncStatus, context),
            trailing: (syncStatus == SyncStatus.failed || syncStatus == SyncStatus.idle)
                ? IconButton(
                    icon: const Icon(Icons.sync_rounded),
                    onPressed: () {
                      if (session != null) {
                        ref.read(gamificationSyncServiceProvider).syncAll(session.profileId);
                      }
                    },
                  )
                : null,
          ),
          const HFSectionHeader(title: 'Account'),
          ListTile(
            title: const Text('Subscription'),
            subtitle: Text(ref.watch(premiumServiceProvider).isPremium ? 'Premium Active' : 'Free Plan'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed(RouteNames.subscription),
          ),
          ListTile(
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              context.pushNamed(RouteNames.editProfile);
            },
          ),
          ListTile(
            title: const Text('Logout'),
            textColor: Theme.of(context).colorScheme.error,
            leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
          if (!isChild) ...[
            const HFSectionHeader(title: 'Developer Tools'),
            ListTile(
              title: const Text('Simulate Premium'),
              subtitle: const Text('Toggle local mock subscription for testing'),
              trailing: Switch(
                value: ref.watch(premiumServiceProvider).isPremium,
                onChanged: (value) {
                  final repository = ref.read(subscriptionRepositoryProvider);
                  if (value) {
                    repository.setSubscription(Subscription(
                      id: 'premium_mock',
                      status: SubscriptionStatus.premium,
                      expiresAt: DateTime.now().add(const Duration(days: 30)),
                      entitlements: EntitlementType.values.map((e) => e.name).toList(),
                    ));
                  } else {
                    repository.resetSubscription();
                  }
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ref.watch(premiumConversionMetricsProvider).when(
                data: (metrics) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREMIUM TELEMETRY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMetricRow('Subscription Views', metrics.subscriptionViews.toString()),
                    _buildMetricRow('Upgrade Attempts', metrics.upgradeAttempts.toString()),
                    _buildMetricRow('Successful Purchases', metrics.successfulPurchases.toString()),
                    _buildMetricRow('Conversion Rate', '${(metrics.conversionRate * 100).toStringAsFixed(1)}%'),
                    const SizedBox(height: 12),
                    HFButton(
                      label: 'Clear Telemetry',
                      variant: HFButtonVariant.text,
                      onPressed: () => ref.read(premiumTelemetryServiceProvider).clear().then(
                        (_) => ref.invalidate(premiumConversionMetricsProvider),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: HFLoadingIndicator()),
                error: (e, _) => Text('Telemetry error: $e'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Ready';
      case SyncStatus.syncing:
        return 'Synchronizing...';
      case SyncStatus.synced:
        return 'Everything up to date';
      case SyncStatus.offline:
        return 'Offline - Changes will sync when connected';
      case SyncStatus.failed:
        return 'Last sync failed';
    }
  }

  Widget _getSyncStatusIcon(SyncStatus status, BuildContext context) {
    final theme = Theme.of(context);
    switch (status) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.synced:
        return Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.primary);
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off_rounded);
      case SyncStatus.failed:
        return Icon(Icons.error_outline_rounded, color: theme.colorScheme.error);
      case SyncStatus.idle:
        return const Icon(Icons.cloud_done_outlined);
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: HFThemeMode.values.map((mode) {
            return ListTile(
              title: Text(mode.name.toUpperCase()),
              onTap: () {
                ref.read(themeControllerProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
              },
              trailing: ref.read(themeControllerProvider) == mode 
                  ? const Icon(Icons.check_rounded, color: Colors.green) 
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}
