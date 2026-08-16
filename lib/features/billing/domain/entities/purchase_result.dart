enum PurchaseStatus {
  success,
  cancelled,
  error,
  alreadyOwned,
  nothingToRestore,
}

class PurchaseResult {
  final PurchaseStatus status;
  final String? errorMessage;

  const PurchaseResult({
    required this.status,
    this.errorMessage,
  });

  bool get isSuccess => status == PurchaseStatus.success;
  bool get isCancelled => status == PurchaseStatus.cancelled;
  bool get isError => status == PurchaseStatus.error;
  bool get isAlreadyOwned => status == PurchaseStatus.alreadyOwned;
  bool get isNothingToRestore => status == PurchaseStatus.nothingToRestore;
}
