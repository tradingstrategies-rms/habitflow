import 'package:flutter/material.dart';

/// [HFRadius] defines the border radius tokens for HabitFlow.
class HFRadius {
  /// 12.0 - Used for chips and small elements.
  static const double chip = 12.0;
  static const Radius chipRadius = Radius.circular(chip);
  static const BorderRadius chipBorderRadius = BorderRadius.all(chipRadius);

  /// 16.0 - Used for buttons.
  static const double button = 16.0;
  static const Radius buttonRadius = Radius.circular(button);
  static const BorderRadius buttonBorderRadius = BorderRadius.all(buttonRadius);

  /// 20.0 - Used for cards.
  static const double card = 20.0;
  static const Radius cardRadius = Radius.circular(card);
  static const BorderRadius cardBorderRadius = BorderRadius.all(cardRadius);

  /// 24.0 - Used for dialogs.
  static const double dialog = 24.0;
  static const Radius dialogRadius = Radius.circular(dialog);
  static const BorderRadius dialogBorderRadius = BorderRadius.all(dialogRadius);
}
