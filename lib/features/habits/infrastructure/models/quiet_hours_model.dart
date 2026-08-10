import 'package:flutter/material.dart';
import '../../domain/entities/quiet_hours_settings.dart';

/// [QuietHoursModel] handles serialization for [QuietHoursSettings].
class QuietHoursModel {
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const QuietHoursModel({
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  factory QuietHoursModel.fromJson(Map<String, dynamic> json) => QuietHoursModel(
        enabled: json['enabled'] as bool,
        startHour: json['startHour'] as int,
        startMinute: json['startMinute'] as int,
        endHour: json['endHour'] as int,
        endMinute: json['endMinute'] as int,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
      };

  factory QuietHoursModel.fromEntity(QuietHoursSettings entity) => QuietHoursModel(
        enabled: entity.enabled,
        startHour: entity.startTime.hour,
        startMinute: entity.startTime.minute,
        endHour: entity.endTime.hour,
        endMinute: entity.endTime.minute,
      );

  QuietHoursSettings toEntity() => QuietHoursSettings(
        enabled: enabled,
        startTime: TimeOfDay(hour: startHour, minute: startMinute),
        endTime: TimeOfDay(hour: endHour, minute: endMinute),
      );
}
