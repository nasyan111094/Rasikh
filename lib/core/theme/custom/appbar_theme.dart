import 'package:flutter/material.dart';
import '../colors.dart';
import '../font_weights.dart';
import '../sizes.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static AppBarTheme lightTheme = AppBarTheme().copyWith(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: TLightModeColors.appBarBgColor,
    foregroundColor: TLightModeColors.appBarFgColor,
    titleTextStyle: AppBarTheme().titleTextStyle?.copyWith(
          fontSize: sp20,
          fontWeight: fw600,
          color: Colors.black,
        ),
  );

  static AppBarTheme darkTheme = AppBarTheme().copyWith(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: TDarkModeColors.scaffoldBgColor,
    foregroundColor: TDarkModeColors.appBarFgColor,
    titleTextStyle: AppBarTheme().titleTextStyle?.copyWith(
          fontSize: sp18,
          fontWeight: fw600,
          color: Colors.white,
        ),
  );
}
