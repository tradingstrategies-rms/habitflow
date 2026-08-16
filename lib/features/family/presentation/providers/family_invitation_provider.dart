import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/features/family/domain/entities/family_invitation.dart';
import 'package:habitflow/features/family/domain/enums/invitation_status.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/entities/family_activity.dart';
import 'package:habitflow/features/family/domain/enums/family_activity_type.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/challenges/presentation/providers/challenges_controller_provider.dart';

import 'package:habitflow/features/family/domain/enums/permission_type.dart';
import 'package:habitflow/features/family/application/providers/family_permission_providers.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';

final familyInvitationsProvider = FutureProvider<List<FamilyInvitation>>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.email.isEmpty) return [];
  
  final repository = ref.watch(familyRepositoryProvider);
  return await repository.getInvitationsForEmail(userProfile.email);
});

final familyOutboundInvitationsProvider = FutureProvider<List<FamilyInvitation>>((ref) async {
  final familyCircle = ref.watch(familyProvider.select((s) => s.circle));
  if (familyCircle == null) return [];
  
  final repository = ref.watch(familyRepositoryProvider);
  final invitations = await repository.getInvitationsByFamilyId(familyCircle.id);
  
  // Sort by date descending
  invitations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return invitations;
});

final familyInvitationByTokenProvider = FutureProvider.family<FamilyInvitation?, String>((ref, token) async {
  final repository = ref.watch(familyRepositoryProvider);
  return await repository.getInvitationByToken(token);
});

final invitationNotifierProvider = StateNotifierProvider<InvitationNotifier, AsyncValue<void>>((ref) {
  return InvitationNotifier(ref);
});

class InvitationNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  InvitationNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> sendInvitation(String email, String familyId, String familyName) async {
    state = const AsyncValue.loading();
    try {
      final familyState = _ref.read(familyProvider);
      final session = _ref.read(activeProfileSessionProvider);
      
      if (session == null) throw Exception('No active profile session');
      
      final activeProfile = familyState.profiles.firstWhere(
        (p) => p.id == session.profileId,
        orElse: () => throw Exception('Active profile not found'),
      );

      final permissionService = _ref.read(familyPermissionServiceProvider);
      if (!permissionService.hasPermission(activeProfile, PermissionType.inviteMember)) {
        throw Exception('You do not have permission to invite members');
      }

      final invitation = FamilyInvitation(
        id: const Uuid().v4(),
        familyId: familyId,
        familyName: familyName,
        invitedEmail: email,
        invitedBy: activeProfile.id, // Using profile ID instead of user ID
        invitedByName: activeProfile.displayName,
        invitedAt: DateTime.now(),
        status: InvitationStatus.pending,
        inviterProfileId: activeProfile.id,
        token: const Uuid().v4(),
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      await _ref.read(familyRepositoryProvider).sendInvitation(invitation);
      _ref.invalidate(familyOutboundInvitationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> revokeInvitation(String invitationId) async {
    state = const AsyncValue.loading();
    try {
      final familyState = _ref.read(familyProvider);
      final session = _ref.read(activeProfileSessionProvider);
      
      if (session == null) throw Exception('No active profile session');
      
      final activeProfile = familyState.profiles.firstWhere(
        (p) => p.id == session.profileId,
        orElse: () => throw Exception('Active profile not found'),
      );

      final permissionService = _ref.read(familyPermissionServiceProvider);
      if (!permissionService.hasPermission(activeProfile, PermissionType.inviteMember)) {
        throw Exception('You do not have permission to revoke invitations');
      }

      await _ref.read(familyRepositoryProvider).revokeInvitation(invitationId);
      _ref.invalidate(familyOutboundInvitationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> acceptInvitation(FamilyInvitation invitation, {String? guestName}) async {
    state = const AsyncValue.loading();
    try {
      final userProfile = _ref.read(userProfileProvider).value;
      
      if (userProfile == null && (guestName == null || guestName.trim().isEmpty)) {
        throw Exception('Please provide a name to join');
      }

      final repository = _ref.read(familyRepositoryProvider);
      
      // 1. Determine Identity
      final String displayName = userProfile?.displayName ?? guestName!.trim();
      final String? userId = userProfile?.uid;

      // 2. Check for existing profile in this family
      final existingProfiles = await repository.getProfiles(invitation.familyId);
      FamilyProfile? profile;
      
      if (userId != null) {
        try {
          profile = existingProfiles.firstWhere((p) => p.userId == userId);
        } catch (_) {
          // No existing profile for this user ID
        }
      }

      // 3. Create profile if it doesn't exist
      if (profile == null) {
        final profileId = const Uuid().v4();
        profile = FamilyProfile(
          id: profileId,
          familyId: invitation.familyId,
          displayName: displayName,
          profileType: ProfileType.adult,
          role: FamilyRole.parent, // Guest join as parent/adult by default for invitation flow
          userId: userId,
          requiresPin: true,
          createdAt: DateTime.now(),
        );
        
        await repository.createAdultProfile(profile);
        
        // Record Activity
        await repository.recordActivity(FamilyActivity(
          id: const Uuid().v4(),
          familyId: invitation.familyId,
          profileId: profile.id,
          profileName: profile.displayName,
          profileAvatarUrl: userProfile?.photoUrl,
          type: FamilyActivityType.memberJoined,
          description: '${profile.displayName} joined the family',
          timestamp: DateTime.now(),
        ));
      }

      // 4. Mark invitation as accepted
      // acceptInvitation handles status, usedAt and usedByProfileId
      await repository.acceptInvitation(invitation.id, profile.id);
      
      // 5. Establish session for the new profile
      await _ref.read(activeProfileSessionProvider.notifier).startSession(profile.id, true);

      // 6. Refresh family state
      await _ref.read(familyProvider.notifier).loadFamily();
      _ref.invalidate(familyInvitationsProvider);
      _ref.invalidate(familyOutboundInvitationsProvider);
      _ref.invalidate(familyInvitationByTokenProvider(invitation.token));
      
      // 7. Update Challenge Progress if authenticated
      if (userId != null) {
        await _ref.read(challengesControllerProvider).incrementProgressByRelatedId(
          userId, 
          'family', 
          1.0,
        );
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> declineInvitation(String invitationId) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(familyRepositoryProvider).declineInvitation(invitationId);
      _ref.invalidate(familyInvitationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
