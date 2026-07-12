import 'package:flutter/material.dart';

/// [HFTypography] defines the typography tokens for HabitFlow.
/// 
/// It uses the Inter font family as specified in the Design System.
class HFTypography {
  static const String fontFamily = 'Inter';

  /// Font size: 32, Weight: Bold
  static const double headingXL = 32.0;
  
  /// Font size: 28, Weight: Bold
  static const double headingL = 28.0;
  
  /// Font size: 24, Weight: SemiBold
  static const double headingM = 24.0;
  
  /// Font size: 20, Weight: SemiBold
  static const double headingS = 20.0;
  
  /// Font size: 16, Weight: Normal
  static const double body = 16.0;
  
  /// Font size: 14, Weight: Normal
  static const double caption = 14.0;
  
  /// Font size: 12, Weight: Medium
  static const double small = 12.0;

  // Font Weights
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightRegular = FontWeight.w400;
}
