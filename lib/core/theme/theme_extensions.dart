import 'package:flutter/material.dart';

/// [HFThemeExtension] allows us to define custom colors and styles that aren't 
/// part of the standard [ThemeData].
class HFThemeExtension extends ThemeExtension<HFThemeExtension> {
  const HFThemeExtension({
    required this.lifeAreaHealth,
    required this.lifeAreaLearning,
    required this.lifeAreaDiscipline,
    required this.lifeAreaFamily,
    required this.lifeAreaFinance,
    required this.lifeAreaFitness,
    required this.lifeAreaSpiritual,
    required this.lifeAreaCreativity,
    required this.lifeAreaSocial,
    required this.xpColor,
    required this.levelColor,
    required this.rewardColor,
  });

  final Color? lifeAreaHealth;
  final Color? lifeAreaLearning;
  final Color? lifeAreaDiscipline;
  final Color? lifeAreaFamily;
  final Color? lifeAreaFinance;
  final Color? lifeAreaFitness;
  final Color? lifeAreaSpiritual;
  final Color? lifeAreaCreativity;
  final Color? lifeAreaSocial;
  final Color? xpColor;
  final Color? levelColor;
  final Color? rewardColor;

  @override
  HFThemeExtension copyWith({
    Color? lifeAreaHealth,
    Color? lifeAreaLearning,
    Color? lifeAreaDiscipline,
    Color? lifeAreaFamily,
    Color? lifeAreaFinance,
    Color? lifeAreaFitness,
    Color? lifeAreaSpiritual,
    Color? lifeAreaCreativity,
    Color? lifeAreaSocial,
    Color? xpColor,
    Color? levelColor,
    Color? rewardColor,
  }) {
    return HFThemeExtension(
      lifeAreaHealth: lifeAreaHealth ?? this.lifeAreaHealth,
      lifeAreaLearning: lifeAreaLearning ?? this.lifeAreaLearning,
      lifeAreaDiscipline: lifeAreaDiscipline ?? this.lifeAreaDiscipline,
      lifeAreaFamily: lifeAreaFamily ?? this.lifeAreaFamily,
      lifeAreaFinance: lifeAreaFinance ?? this.lifeAreaFinance,
      lifeAreaFitness: lifeAreaFitness ?? this.lifeAreaFitness,
      lifeAreaSpiritual: lifeAreaSpiritual ?? this.lifeAreaSpiritual,
      lifeAreaCreativity: lifeAreaCreativity ?? this.lifeAreaCreativity,
      lifeAreaSocial: lifeAreaSocial ?? this.lifeAreaSocial,
      xpColor: xpColor ?? this.xpColor,
      levelColor: levelColor ?? this.levelColor,
      rewardColor: rewardColor ?? this.rewardColor,
    );
  }

  @override
  HFThemeExtension lerp(ThemeExtension<HFThemeExtension>? other, double t) {
    if (other is! HFThemeExtension) return this;
    return HFThemeExtension(
      lifeAreaHealth: Color.lerp(lifeAreaHealth, other.lifeAreaHealth, t),
      lifeAreaLearning: Color.lerp(lifeAreaLearning, other.lifeAreaLearning, t),
      lifeAreaDiscipline: Color.lerp(lifeAreaDiscipline, other.lifeAreaDiscipline, t),
      lifeAreaFamily: Color.lerp(lifeAreaFamily, other.lifeAreaFamily, t),
      lifeAreaFinance: Color.lerp(lifeAreaFinance, other.lifeAreaFinance, t),
      lifeAreaFitness: Color.lerp(lifeAreaFitness, other.lifeAreaFitness, t),
      lifeAreaSpiritual: Color.lerp(lifeAreaSpiritual, other.lifeAreaSpiritual, t),
      lifeAreaCreativity: Color.lerp(lifeAreaCreativity, other.lifeAreaCreativity, t),
      lifeAreaSocial: Color.lerp(lifeAreaSocial, other.lifeAreaSocial, t),
      xpColor: Color.lerp(xpColor, other.xpColor, t),
      levelColor: Color.lerp(levelColor, other.levelColor, t),
      rewardColor: Color.lerp(rewardColor, other.rewardColor, t),
    );
  }
}
