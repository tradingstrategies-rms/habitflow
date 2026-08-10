import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/active_profile_session.dart';
import '../../domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';

final activeProfileSessionProvider = StateNotifierProvider<ActiveProfileSessionNotifier, ActiveProfileSession?>((ref) {
  return ActiveProfileSessionNotifier(ref.watch(familyRepositoryProvider));
});

class ActiveProfileSessionNotifier extends StateNotifier<ActiveProfileSession?> {
  final FamilyRepository _repository;

  ActiveProfileSessionNotifier(this._repository) : super(null) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    state = await _repository.getActiveProfileSession();
  }

  Future<bool> verifyPin(String pin) async {
    return await _repository.verifyParentPin(pin);
  }

  Future<void> startSession(String profileId, bool pinVerified) async {
    final session = ActiveProfileSession(
      profileId: profileId,
      pinVerified: pinVerified,
      startedAt: DateTime.now(),
    );
    await _repository.setActiveProfileSession(session);
    state = session;
  }

  Future<void> endSession() async {
    await _repository.clearActiveProfileSession();
    state = null;
  }
}
