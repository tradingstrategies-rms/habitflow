import 'package:flutter/foundation.dart';

@immutable
class FamilyCircle {
  final String id;
  final String name;
  final String ownerProfileId;
  final DateTime createdAt;

  const FamilyCircle({
    required this.id,
    required this.name,
    required this.ownerProfileId,
    required this.createdAt,
  });

  FamilyCircle copyWith({
    String? id,
    String? name,
    String? ownerProfileId,
    DateTime? createdAt,
  }) {
    return FamilyCircle(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerProfileId: ownerProfileId ?? this.ownerProfileId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyCircle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          ownerProfileId == other.ownerProfileId &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ ownerProfileId.hashCode ^ createdAt.hashCode;

  @override
  String toString() =>
      'FamilyCircle(id: $id, name: $name, ownerProfileId: $ownerProfileId, createdAt: $createdAt)';
}
