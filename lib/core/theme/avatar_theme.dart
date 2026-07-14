import 'package:flutter/material.dart';
import 'dart:ui';

/// [AvatarColors] defines the color palette for the "Organic Vitality" style.
/// Premium wellness palette with calming greens and warm earth tones.
class AvatarColors {
  // Calming Greens
  static const Color sage = Color(0xFF86A789);
  static const Color softMint = Color(0xFFB2C8BA);
  static const Color forest = Color(0xFF4F6F52);
  
  // Warm Earth Tones
  static const Color terracotta = Color(0xFFD27666);
  static const Color sand = Color(0xFFEAD8C0);
  static const Color warmClay = Color(0xFF967E76);
  static const Color desert = Color(0xFFDBC4A1);

  // Functional & Background
  static const Color surface = Color(0xFFFAFAF9);
  static const Color onSurface = Color(0xFF1C1C1E);
  
  /// Organic gradients used for backgrounds and depth.
  static const List<Color> organicGradient = [
    Color(0xFF86A789), // Sage
    Color(0xFFB2C8BA), // Soft Mint
  ];
  
  static const List<Color> vitalityGradient = [
    Color(0xFFD27666), // Terracotta
    Color(0xFFEAD8C0), // Sand
  ];
}

/// [AvatarSpacing] defines the spacing and layout tokens for avatars.
class AvatarSpacing {
  /// External padding for avatar containers.
  static const double padding = 16.0;
  
  /// Gap between avatars in a list or grid.
  static const double gap = 12.0;
  
  /// Width of the avatar border/stroke.
  static const double strokeWidth = 2.0;
  
  /// Internal padding between stroke and image.
  static const double innerPadding = 4.0;
}

/// [AvatarConstants] defines visual constants for the avatar design language.
class AvatarConstants {
  /// Corner radius for avatar cards and images.
  static const double borderRadius = 32.0;
  
  /// Standard elevation for avatar cards.
  static const double elevation = 4.0;
  
  /// Size variants for avatars.
  static const double sizeXS = 32.0;
  static const double sizeS = 48.0;
  static const double sizeM = 80.0;
  static const double sizeL = 120.0;
  static const double sizeXL = 160.0;
  
  /// Standard animation duration for avatar transitions.
  static const Duration animationDuration = Duration(milliseconds: 300);
}

/// [AvatarIllustrationGuide] provides the visual principles for the 
/// Organic Vitality illustration style.
class AvatarIllustrationGuide {
  static const String styleName = "Organic Vitality";
  static const String description = 
      "Premium wellness illustration with soft gradients, rounded features, calming greens and warm earth tones.";
  
  static const List<String> guidelines = [
    "Use soft linear or radial gradients to imply volume without harsh shadows.",
    "Prioritize rounded geometric shapes and smooth, organic transitions.",
    "Avoid pure black; use deep forest greens or warm clays for outlines and depth.",
    "Lighting should be soft, consistent, and appear natural/warm.",
    "Expressions must remain happy, motivated, healthy, and approachable.",
    "Maintain a white or ultra-light neutral background for clarity."
  ];
}

/// [AvatarTheme] encapsulates all avatar-related design tokens as a ThemeExtension.
class AvatarTheme extends ThemeExtension<AvatarTheme> {
  final Color background;
  final double radius;
  final List<BoxShadow> shadows;
  final LinearGradient primaryGradient;
  final Color strokeColor;

  const AvatarTheme({
    required this.background,
    required this.radius,
    required this.shadows,
    required this.primaryGradient,
    required this.strokeColor,
  });

  /// Factory for the default Organic Vitality theme.
  factory AvatarTheme.organic() {
    return AvatarTheme(
      background: AvatarColors.surface,
      radius: AvatarConstants.borderRadius,
      shadows: [
        BoxShadow(
          color : AvatarColors.warmClay.withValues(alpha: 0.5),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      primaryGradient: const LinearGradient(
        colors: AvatarColors.organicGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      strokeColor: AvatarColors.softMint.withValues(alpha: 0.5),
    );
  }

  @override
  AvatarTheme copyWith({
    Color? background,
    double? radius,
    List<BoxShadow>? shadows,
    LinearGradient? primaryGradient,
    Color? strokeColor,
  }) {
    return AvatarTheme(
      background: background ?? this.background,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      strokeColor: strokeColor ?? this.strokeColor,
    );
  }

  @override
  AvatarTheme lerp(ThemeExtension<AvatarTheme>? other, double t) {
    if (other is! AvatarTheme) return this;
    return AvatarTheme(
      background: Color.lerp(background, other.background, t)!,
      radius: lerpDouble(radius, other.radius, t)!,
      shadows: BoxShadow.lerpList(shadows, other.shadows, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      strokeColor: Color.lerp(strokeColor, other.strokeColor, t)!,
    );
  }
}
