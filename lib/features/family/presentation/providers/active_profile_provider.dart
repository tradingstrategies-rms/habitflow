import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/family_profile.dart';

final activeProfileProvider = StateNotifierProvider<ActiveProfileNotifier, FamilyProfile?>((ref) {
  return ActiveProfileNotifier(ref);
});

class ActiveProfileNotifier extends StateNotifier<FamilyProfile?> {
  final Ref ref;

  ActiveProfileNotifier(this.ref) : super(null);

  void setActiveProfile(FamilyProfile profile) {
    state = profile;
  }
}
