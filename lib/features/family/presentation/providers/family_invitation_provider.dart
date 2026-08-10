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

final familyInvitationsProvider = FutureProvider<List<FamilyInvitation>>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.email.isEmpty) return [];
  
  final repository = ref.watch(familyRepositoryProvider);
  return await repository.getInvitationsForEmail(userProfile.email);
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
      final userProfile = _ref.read(userProfileProvider).value;
      if (userProfile == null) throw Exception('User profile not found');

      final invitation = FamilyInvitation(
        id: const Uuid().v4(),
        familyId: familyId,
        familyName: familyName,
        invitedEmail: email,
        invitedBy: userProfile.uid,
        invitedByName: userProfile.displayName,
        invitedAt: DateTime.now(),
        status: InvitationStatus.pending,
      );

      await _ref.read(familyRepositoryProvider).sendInvitation(invitation);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> acceptInvitation(FamilyInvitation invitation) async {
    state = const AsyncValue.loading();
    try {
      final userProfile = _ref.read(userProfileProvider).value;
      if (userProfile == null) throw Exception('Not authenticated');

      final repository = _ref.read(familyRepositoryProvider);
      
      // 1. Create adult profile for this user in the family
      final profile = FamilyProfile(
        id: const Uuid().v4(),
        familyId: invitation.familyId,
        displayName: userProfile.displayName,
        profileType: ProfileType.adult,
        role: FamilyRole.parent,
        userId: userProfile.uid,
        requiresPin: true,
        createdAt: DateTime.now(),
      );
      
      await repository.createAdultProfile(profile);
      
      // Record Activity
      await repository.recordActivity(FamilyActivity(
        id: const Uuid().v4(),
        familyId: invitation.familyId,
        profileId: userProfile.uid,
        profileName: userProfile.displayName,
        profileAvatarUrl: userProfile.photoUrl,
        type: FamilyActivityType.memberJoined,
        description: '${userProfile.displayName} joined the family',
        timestamp: DateTime.now(),
      ));
      
      // 2. Mark invitation as accepted (or delete it)
      await repository.acceptInvitation(invitation.id, userProfile.uid);
      
      // 3. Refresh family state
      await _ref.read(familyProvider.notifier).loadFamily();
      _ref.invalidate(familyInvitationsProvider);
      
      // Update Challenge Progress
      await _ref.read(challengesControllerProvider).incrementProgressByRelatedId(
        userProfile.uid, 
        'family', 
        1.0,
      );

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
