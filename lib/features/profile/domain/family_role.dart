/// [FamilyRole] defines the role of a user within a family.
enum FamilyRole {
  parent('Parent'),
  child('Child');

  const FamilyRole(this.label);
  final String label;

  static FamilyRole fromString(String? value) {
    return FamilyRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FamilyRole.parent,
    );
  }
}
