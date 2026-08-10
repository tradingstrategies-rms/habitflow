import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';

import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';

class FamilySettingsScreen extends ConsumerWidget {
  const FamilySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final familyState = ref.watch(familyProvider);
    final session = ref.watch(activeProfileSessionProvider);
    
    final activeProfile = familyState.profiles.firstWhere(
      (p) => p.id == session?.profileId,
      orElse: () => familyState.profiles.first,
    );
    
    final isOwner = activeProfile.role == FamilyRole.owner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(HFSpacing.m),
        children: [
          _buildSectionHeader(context, 'MEMBERS'),
          _buildSettingsCard(
            context,
            title: 'Manage Members',
            subtitle: 'Add, edit or remove family profiles',
            icon: Icons.people_outline,
            onTap: () => context.pushNamed(RouteNames.familyMembers),
          ),
          const SizedBox(height: HFSpacing.l),
          
          _buildSectionHeader(context, 'NOTIFICATIONS'),
          _buildSettingsCard(
            context,
            title: 'Alerts & Activity',
            subtitle: 'Configure approval and member notifications',
            icon: Icons.notifications_none_rounded,
            onTap: () => _showComingSoon(context, 'Notifications'),
          ),
          const SizedBox(height: HFSpacing.l),
          
          _buildSectionHeader(context, 'SECURITY'),
          _buildSettingsCard(
            context,
            title: 'Parent PIN',
            subtitle: 'Protect parent profiles with a PIN.',
            icon: Icons.lock_outline,
            onTap: () => context.pushNamed(RouteNames.familyPinSetup),
          ),
          
          if (isOwner) ...[
            const SizedBox(height: HFSpacing.l),
            _buildSectionHeader(context, 'DANGER ZONE'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.error.withAlpha(40)),
              ),
              color: theme.colorScheme.errorContainer.withAlpha(20),
              child: ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
                title: Text('Delete Family Circle', 
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold)
                ),
                subtitle: const Text('Permanently remove all family data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDeleteConfirmation(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon'),
        content: Text('$feature will be available in an upcoming update.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family?'),
        content: const Text('This action cannot be undone. All profiles and shared data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
