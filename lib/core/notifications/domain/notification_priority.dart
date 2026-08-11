/// [NotificationPriority] defines the importance of a notification.
/// This is platform-independent and mapped to specific platform features 
/// (like Android channels or iOS interruption levels) in the infrastructure layer.
enum NotificationPriority {
  /// Low priority, may not make sound or show a heads-up alert.
  low,

  /// Normal priority, standard delivery.
  normal,

  /// High priority, should be delivered prominently.
  high,
}
