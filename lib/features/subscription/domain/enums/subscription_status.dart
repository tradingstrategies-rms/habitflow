enum SubscriptionStatus {
  free,
  premium,
  expired,
  cancelled;

  bool get isPremium => this == SubscriptionStatus.premium;
}
