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
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import '../application/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final settings = ref.watch(settingsProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final session = ref.watch(activeProfileSessionProvider);

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
