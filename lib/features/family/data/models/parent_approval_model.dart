import '../../domain/entities/parent_approval.dart';
import '../../domain/enums/approval_status.dart';

class ParentApprovalModel extends ParentApproval {
  const ParentApprovalModel({
    required super.id,
    required super.childProfileId,
    required super.childName,
    required super.habitId,
    required super.status,
    required super.createdAt,
    super.note,
  });

  factory ParentApprovalModel.fromEntity(ParentApproval entity) {
    return ParentApprovalModel(
      id: entity.id,
      childProfileId: entity.childProfileId,
      childName: entity.childName,
      habitId: entity.habitId,
      status: entity.status,
      createdAt: entity.createdAt,
      note: entity.note,
    );
  }

  factory ParentApprovalModel.fromJson(Map<String, dynamic> json) {
    return ParentApprovalModel(
      id: json['id']?.toString() ?? '',
      childProfileId: json['childProfileId']?.toString() ?? '',
      childName: json['childName']?.toString() ?? 'Child',
      habitId: json['habitId']?.toString() ?? '',
      status: json['status'] != null
          ? ApprovalStatus.values.firstWhere(
              (e) => e.name == json['status'].toString(),
              orElse: () => ApprovalStatus.pending,
            )
          : ApprovalStatus.pending,
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childProfileId': childProfileId,
      'childName': childName,
      'habitId': habitId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  ParentApproval toEntity() {
    return ParentApproval(
      id: id,
      childProfileId: childProfileId,
      childName: childName,
      habitId: habitId,
      status: status,
      createdAt: createdAt,
      note: note,
    );
  }
}
