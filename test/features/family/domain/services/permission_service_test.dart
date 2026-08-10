import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/permission_type.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/services/permission_service.dart';

void main() {
  late PermissionService service;
  final now = DateTime.now();

  setUp(() {
    service = PermissionService();
  });

  group('PermissionService', () {
    test('Owner has all permissions', () {
      final profile = FamilyProfile(
        id: '1', familyId: 'f1', displayName: 'Owner', profileType: ProfileType.adult, role: FamilyRole.owner, requiresPin: true, createdAt: now,
      );
      for (var p in PermissionType.values) {
        expect(service.hasPermission(profile, p), isTrue);
      }
    });

    test('Parent permissions', () {
      final profile = FamilyProfile(
        id: '2', familyId: 'f1', displayName: 'Parent', profileType: ProfileType.adult, role: FamilyRole.parent, requiresPin: true, createdAt: now,
      );
      expect(service.hasPermission(profile, PermissionType.completeHabit), isTrue);
      expect(service.hasPermission(profile, PermissionType.manageFamily), isFalse);
    });

    test('Child permissions', () {
      final profile = FamilyProfile(
        id: '3', familyId: 'f1', displayName: 'Child', profileType: ProfileType.child, role: FamilyRole.child, requiresPin: false, createdAt: now,
      );
      expect(service.hasPermission(profile, PermissionType.completeHabit), isTrue);
      expect(service.hasPermission(profile, PermissionType.createHabit), isFalse);
    });

    test('Helper methods', () {
      final child = FamilyProfile(
        id: '4', familyId: 'f1', displayName: 'Child', profileType: ProfileType.child, role: FamilyRole.child, requiresPin: false, createdAt: now,
      );
      expect(service.isChild(child), isTrue);
      expect(service.isAdult(child), isFalse);
      expect(service.requiresPin(child), isFalse);
    });
  });
}
