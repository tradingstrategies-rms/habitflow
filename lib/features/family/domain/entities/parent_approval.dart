import 'package:flutter/foundation.dart';
import '../enums/approval_status.dart';

@immutable
class ParentApproval {
  final String id;
  final String childProfileId;
  final String childName;
  final String habitId;
  final ApprovalStatus status;
  final DateTime createdAt;
  final String? note;

  const ParentApproval({
    required this.id,
    required this.childProfileId,
    required this.childName,
    required this.habitId,
    required this.status,
    required this.createdAt,
    this.note,
  });

  ParentApproval copyWith({
    String? id,
    String? childProfileId,
    String? childName,
    String? habitId,
    ApprovalStatus? status,
    DateTime? createdAt,
    String? note,
  }) {
    return ParentApproval(
      id: id ?? this.id,
      childProfileId: childProfileId ?? this.childProfileId,
      childName: childName ?? this.childName,
      habitId: habitId ?? this.habitId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParentApproval &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          childProfileId == other.childProfileId &&
          childName == other.childName &&
          habitId == other.habitId &&
          status == other.status &&
          createdAt == other.createdAt &&
          note == other.note);

  @override
  int get hashCode =>
      id.hashCode ^
      childProfileId.hashCode ^
      childName.hashCode ^
      habitId.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      note.hashCode;

  @override
  String toString() =>
      'ParentApproval(id: $id, childProfileId: $childProfileId, childName: $childName, habitId: $habitId, status: $status, createdAt: $createdAt, note: $note)';
}
