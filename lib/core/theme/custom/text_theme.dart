import 'package:flutter/material.dart';
import 'package:rasikh/core/theme/colors.dart';

import '../sizes.dart';

// 🔹 توحيد المقاسات لكلا الوضعين بعد تقليلها بمقدار 1
final double headlineSmallSize = sp19;
final double headlineMediumSize = sp21;
final double headlineLargeSize = sp31;

final double titleSmallSize = sp15;
final double titleMediumSize = sp16;
final double titleLargeSize = sp19;

final double bodySmallSize = sp15;
final double bodyMediumSize = sp17;
final double bodyLargeSize = sp15;

final double labelSmallSize = sp9;
final double labelMediumSize = sp11;
final double labelLargeSize = sp13;

class TTextTheme {
  TTextTheme._();

  static TextTheme getTextTheme(Color textColor) => TextTheme(
        headlineSmall: TextStyle(
          fontSize: headlineSmallSize,
          fontWeight: FontWeight.bold,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        headlineMedium: TextStyle(
          fontSize: headlineMediumSize,
          fontWeight: FontWeight.bold,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        headlineLarge: TextStyle(
          fontSize: headlineLargeSize,
          fontWeight: FontWeight.bold,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        titleSmall: TextStyle(
          fontSize: titleSmallSize,
          fontWeight: FontWeight.w500,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        titleMedium: TextStyle(
          fontSize: titleMediumSize,
          fontWeight: FontWeight.w500,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        titleLarge: TextStyle(
          fontSize: titleLargeSize,
          fontWeight: FontWeight.w500,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        bodySmall: TextStyle(
          fontSize: bodySmallSize,
          fontWeight: FontWeight.w400,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        bodyMedium: TextStyle(
          fontSize: bodyMediumSize,
          fontWeight: FontWeight.w400,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        bodyLarge: TextStyle(
          fontSize: bodyLargeSize,
          fontWeight: FontWeight.w400,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        labelSmall: TextStyle(
          fontSize: labelSmallSize,
          fontWeight: FontWeight.w400,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        labelMedium: TextStyle(
          fontSize: labelMediumSize,
          fontWeight: FontWeight.w400,
          fontFamily: "Abel",
          color: textColor,
        
        ),
        labelLarge: TextStyle(
          fontSize: labelLargeSize,
          fontWeight: FontWeight.w400,
          fontFamily: "Abel",
          color: textColor,
        
        ),
      );

  static TextTheme lightTextTheme =
      getTextTheme(TLightModeColors.appBarFgColor);
  static TextTheme darkTextTheme = getTextTheme(TDarkModeColors.appBarFgColor);
}
