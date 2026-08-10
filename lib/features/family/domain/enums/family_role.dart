enum FamilyRole {
  owner,
  parent,
  adultMember,
  child;

  String get displayName {
    switch (this) {
      case FamilyRole.owner:
        return 'Owner';
      case FamilyRole.parent:
        return 'Parent';
      case FamilyRole.adultMember:
        return 'Adult Member';
      case FamilyRole.child:
        return 'Child';
    }
  }
}
