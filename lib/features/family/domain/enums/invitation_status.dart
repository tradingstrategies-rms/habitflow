enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
  revoked;

  String get displayName {
    switch (this) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
      case InvitationStatus.revoked:
        return 'Revoked';
    }
  }
}
