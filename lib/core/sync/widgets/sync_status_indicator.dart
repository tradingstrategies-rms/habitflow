import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_status.dart';
import '../providers/sync_providers.dart';
import '../services/gamification_sync_service.dart';
import '../../../features/family/presentation/providers/active_profile_session_provider.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    if (status == SyncStatus.idle || status == SyncStatus.synced) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: status == SyncStatus.failed ? () => _handleRetry(ref) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(status, theme),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getIcon(status, theme),
            const SizedBox(width: 8),
            Text(
              _getStatusText(status),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getTextColor(status, theme),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (status == SyncStatus.failed) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.refresh_rounded,
                size: 14,
                color: theme.colorScheme.error,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleRetry(WidgetRef ref) {
    final session = ref.read(activeProfileSessionProvider);
    if (session != null) {
      ref.read(gamificationSyncServiceProvider).processQueue();
    }
  }

  Color _getBackgroundColor(SyncStatus status, ThemeData theme) {
    switch (status) {
      case SyncStatus.syncing:
        return theme.colorScheme.primaryContainer.withAlpha(150);
      case SyncStatus.offline:
        return theme.colorScheme.surfaceContainerHighest.withAlpha(150);
      case SyncStatus.failed:
        return theme.colorScheme.errorContainer.withAlpha(150);
      default:
        return Colors.transparent;
    }
  }

  Color _getTextColor(SyncStatus status, ThemeData theme) {
    switch (status) {
      case SyncStatus.syncing:
        return theme.colorScheme.onPrimaryContainer;
      case SyncStatus.offline:
        return theme.colorScheme.onSurfaceVariant;
      case SyncStatus.failed:
        return theme.colorScheme.onErrorContainer;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  Widget _getIcon(SyncStatus status, ThemeData theme) {
    switch (status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        );
      case SyncStatus.offline:
        return Icon(Icons.cloud_off_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant);
      case SyncStatus.failed:
        return Icon(Icons.error_outline_rounded, size: 14, color: theme.colorScheme.error);
      default:
        return const SizedBox.shrink();
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.failed:
        return 'Sync Failed';
      case SyncStatus.synced:
        return 'Synced';
      default:
        return '';
    }
  }
}
