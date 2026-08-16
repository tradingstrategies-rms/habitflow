import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/features/family/domain/entities/family_invitation.dart';
import 'package:habitflow/features/family/domain/enums/invitation_status.dart';
import 'package:habitflow/features/family/presentation/providers/family_invitation_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/domain/enums/permission_type.dart';
import 'package:habitflow/features/family/application/providers/family_permission_providers.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class FamilyInvitationDetailsScreen extends ConsumerWidget {
  final String token;

  const FamilyInvitationDetailsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationAsync = ref.watch(familyInvitationByTokenProvider(token));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Invitation'),
      ),
      body: invitationAsync.when(
        data: (invitation) {
          if (invitation == null) {
            return HFEmptyState(
              title: 'Invitation Not Found',
              message: 'This invitation link seems to be invalid or has been deleted.',
              icon: Icons.error_outline,
              actionLabel: 'Go to Dashboard',
              onActionPressed: () => context.go('/'),
            );
          }

          final familyState = ref.watch(familyProvider);
          final session = ref.watch(activeProfileSessionProvider);
          final permissionService = ref.watch(familyPermissionServiceProvider);

          // Determine if the current user is an authorized adult of this family
          bool isAuthorizedAdult = false;
          if (familyState.circle?.id == invitation.familyId && session != null) {
            final activeProfile = familyState.profiles.firstWhere(
              (p) => p.id == session.profileId,
              orElse: () => familyState.profiles.first,
            );
            isAuthorizedAdult = permissionService.hasPermission(
              activeProfile,
              PermissionType.inviteMember,
            );
          }

          if (isAuthorizedAdult) {
            return _buildManagementUI(context, ref, invitation);
          } else {
            return _buildAcceptanceUI(context, ref, invitation);
          }
        },
        loading: () => const HFLoadingIndicator(),
        error: (e, _) => HFEmptyState(
          title: 'Error Loading Invitation',
          message: e.toString(),
          icon: Icons.error_outline,
          actionLabel: 'Retry',
          onActionPressed: () => ref.invalidate(familyInvitationByTokenProvider(token)),
        ),
      ),
    );
  }

  Widget _buildManagementUI(BuildContext context, WidgetRef ref, FamilyInvitation invitation) {
    final theme = Theme.of(context);
    final inviteLink = 'habitflow://family/invite/${invitation.token}';

    return ListView(
      padding: const EdgeInsets.all(HFSpacing.l),
      children: [
        HFCard(
          elevation: 0,
          border: BorderSide(color: theme.colorScheme.outlineVariant),
          child: Column(
            children: [
              Text(
                'Invitation for',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                invitation.invitedEmail,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: inviteLink,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: theme.colorScheme.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                invitation.status == InvitationStatus.pending
                    ? 'Scan this code to join the family'
                    : 'Status: ${invitation.status.name.toUpperCase()}',
                style: theme.textTheme.bodyMedium,
              ),
              if (invitation.isExpired)
                Text(
                  'This invitation has expired',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: HFSpacing.l),
        Row(
          children: [
            Expanded(
              child: HFButton(
                label: 'Copy Link',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: inviteLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
                variant: HFButtonVariant.secondary,
                icon: Icons.copy,
              ),
            ),
            const SizedBox(width: HFSpacing.m),
            Expanded(
              child: HFButton(
                label: 'Share',
                onPressed: () => SharePlus.instance.share(
                  ShareParams(text: 'Join my family on HabitFlow: $inviteLink'),
                ),
                icon: Icons.share,
              ),
            ),
          ],
        ),
        if (invitation.status == InvitationStatus.pending && !invitation.isExpired) ...[
          const SizedBox(height: HFSpacing.l),
          HFButton(
            label: 'Revoke Invitation',
            onPressed: () => _showRevokeConfirmation(context, ref, invitation),
            variant: HFButtonVariant.danger,
          ),
        ],
      ],
    );
  }

  Widget _buildAcceptanceUI(BuildContext context, WidgetRef ref, FamilyInvitation invitation) {
    final theme = Theme.of(context);
    final isExpired = invitation.isExpired;
    final isValid = invitation.status == InvitationStatus.pending && !isExpired;
    final invitationState = ref.watch(invitationNotifierProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HFSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isValid ? Icons.family_restroom : Icons.error_outline,
              size: 80,
              color: isValid ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
            const SizedBox(height: HFSpacing.l),
            Text(
              isValid ? 'You\u0027re invited!' : 'Invitation Invalid',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: HFSpacing.m),
            Text(
              isValid
                  ? 'Join ${invitation.familyName} to track habits and grow together.'
                  : _getInvalidReason(invitation),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: HFSpacing.xl),
            if (isValid)
              HFButton(
                label: 'Accept & Join Family',
                isLoading: invitationState.isLoading,
                onPressed: () => _handleAcceptance(context, ref, invitation),
              ),
            const SizedBox(height: HFSpacing.m),
            HFButton(
              label: 'Go to Dashboard',
              onPressed: () => context.go('/'),
              variant: HFButtonVariant.text,
            ),
          ],
        ),
      ),
    );
  }

  void _handleAcceptance(BuildContext context, WidgetRef ref, FamilyInvitation invitation) {
    final userProfile = ref.read(userProfileProvider).value;

    if (userProfile != null) {
      // User is already logged in, accept directly
      ref.read(invitationNotifierProvider.notifier).acceptInvitation(invitation).then((_) {
        if (context.mounted && !ref.read(invitationNotifierProvider).hasError) {
          context.goNamed(RouteNames.family);
        }
      });
    } else {
      // Guest flow: Show bottom sheet to get name
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _GuestOnboardingBottomSheet(invitation: invitation),
      );
    }
  }

  String _getInvalidReason(FamilyInvitation invitation) {
    if (invitation.status == InvitationStatus.accepted) return 'This invitation has already been used.';
    if (invitation.status == InvitationStatus.revoked) return 'This invitation has been revoked by the inviter.';
    if (invitation.isExpired) return 'This invitation has expired.';
    return 'This invitation is no longer valid.';
  }

  void _showRevokeConfirmation(BuildContext context, WidgetRef ref, FamilyInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Invitation'),
        content: const Text('Are you sure you want to revoke this invitation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(invitationNotifierProvider.notifier).revokeInvitation(invitation.id);
              if (context.mounted) {
                Navigator.pop(context); // Pop dialog
                context.pop(); // Go back to members list
              }
            },
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }
}

class _GuestOnboardingBottomSheet extends ConsumerStatefulWidget {
  final FamilyInvitation invitation;

  const _GuestOnboardingBottomSheet({required this.invitation});

  @override
  ConsumerState<_GuestOnboardingBottomSheet> createState() => _GuestOnboardingBottomSheetState();
}

class _GuestOnboardingBottomSheetState extends ConsumerState<_GuestOnboardingBottomSheet> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invitationState = ref.watch(invitationNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: HFSpacing.l,
        right: HFSpacing.l,
        top: HFSpacing.l,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: HFSpacing.l),
            Text(
              'Join the Family',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: HFSpacing.m),
            Text(
              'Enter your name to join "${widget.invitation.familyName}".',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: HFSpacing.l),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'e.g., Alex',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: HFSpacing.xl),
            HFButton(
              label: 'Join Family',
              isLoading: invitationState.isLoading,
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await ref.read(invitationNotifierProvider.notifier).acceptInvitation(
                        widget.invitation,
                        guestName: _nameController.text.trim(),
                      );

                  if (mounted && !ref.read(invitationNotifierProvider).hasError) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close bottom sheet
                      context.goNamed(RouteNames.family);
                    }
                  }
                }
              },
            ),
            const SizedBox(height: HFSpacing.xl),
          ],
        ),
      ),
    );
  }
}
