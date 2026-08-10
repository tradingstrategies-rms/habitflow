import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/quiet_hours_repository.dart';
import '../../infrastructure/repositories/local_quiet_hours_repository.dart';
import '../services/quiet_hours_policy_service.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

/// Provider for [QuietHoursRepository].
final quietHoursRepositoryProvider = Provider<QuietHoursRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalQuietHoursRepository(prefs);
});

/// Provider for [QuietHoursPolicyService].
final quietHoursPolicyServiceProvider = Provider<QuietHoursPolicyService>((ref) {
  final repository = ref.watch(quietHoursRepositoryProvider);
  return QuietHoursPolicyService(repository);
});

/// Provider for current quiet hours settings.
final quietHoursSettingsProvider = FutureProvider((ref) {
  return ref.watch(quietHoursRepositoryProvider).getSettings();
});
