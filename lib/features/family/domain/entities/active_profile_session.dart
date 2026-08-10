import 'package:flutter/foundation.dart';

@immutable
class ActiveProfileSession {
  final String profileId;
  final bool pinVerified;
  final DateTime startedAt;

  const ActiveProfileSession({
    required this.profileId,
    required this.pinVerified,
    required this.startedAt,
  });

  ActiveProfileSession copyWith({
    String? profileId,
    bool? pinVerified,
    DateTime? startedAt,
  }) {
    return ActiveProfileSession(
      profileId: profileId ?? this.profileId,
      pinVerified: pinVerified ?? this.pinVerified,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveProfileSession &&
          runtimeType == other.runtimeType &&
          profileId == other.profileId &&
          pinVerified == other.pinVerified &&
          startedAt == other.startedAt);

  @override
  int get hashCode => profileId.hashCode ^ pinVerified.hashCode ^ startedAt.hashCode;
}
