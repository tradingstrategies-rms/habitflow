import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/features/profile/domain/profile_repository.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';

/// [ProfileController] manages the user profile state and operations.
class ProfileController extends StateNotifier<AsyncValue<void>> {
  ProfileController(this._repository) : super(const AsyncValue.data(null));

  final ProfileRepository _repository;

  Future<void> saveProfile(UserProfile profile) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.saveProfile(profile));
  }
}

/// Provider for [ProfileController].
final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(repository);
});
