import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';

extension TextThemeExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodyGreyMedium =>
      textTheme.bodyMedium!.copyWith(color: greyMedium);
  TextStyle? get headlineSmall => textTheme.headlineSmall;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get boySmall => textTheme.bodySmall;
  TextStyle? get headLineMedium => textTheme.headlineMedium;
}
