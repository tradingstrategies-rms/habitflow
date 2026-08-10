enum ProfileType {
  adult,
  child;

  String get displayName {
    switch (this) {
      case ProfileType.adult:
        return 'Adult';
      case ProfileType.child:
        return 'Child';
    }
  }
}
