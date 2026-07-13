import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/features/profile/domain/profile_repository.dart';
import 'package:habitflow/features/profile/data/firestore_profile_repository.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';

/// Provider for [ProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return FirestoreProfileRepository(databaseService);
});

/// Stream provider for the current user's profile.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.value;
  if (uid == null) return Stream.value(null);
  
  return ref.watch(profileRepositoryProvider).watchProfile(uid);
});
