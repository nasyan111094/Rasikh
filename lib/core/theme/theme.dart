import 'package:flutter/material.dart';
import 'package:rasikh/core/theme/colors.dart';
import 'package:rasikh/core/theme/custom/appbar_theme.dart';
import 'package:rasikh/core/theme/custom/buttons_theme.dart';
import 'package:rasikh/core/theme/custom/dialog_theme.dart';
import 'package:rasikh/core/theme/custom/icon_theme.dart';
import 'package:rasikh/core/theme/custom/text_theme.dart';



class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TLightModeColors.primaryColor,
      brightness: Brightness.light,
      primary: TLightModeColors.primaryColor,
      primaryContainer: Colors.white,
      onPrimaryContainer: Colors.black,
      secondaryContainer: TLightModeColors.secondaryContainer,
      onSecondaryContainer: TLightModeColors.onSecondaryContainer,
      outline: TLightModeColors.outline,
      surfaceTint: Colors.grey.shade600,
      error: TLightModeColors.error,
    ),
    dialogTheme: TLightDialogTheme.lightDialogTheme,
    appBarTheme: TAppBarTheme.lightTheme,
    textTheme: TTextTheme.lightTextTheme,

    scaffoldBackgroundColor: TLightModeColors.scaffoldBgColor,
    iconTheme: TIconTheme.lightIconTheme,
    filledButtonTheme: TButtonsTheme.lightFilledButtonStyle,
    outlinedButtonTheme: TButtonsTheme.lightOutlinedButtonStyle,
    useMaterial3: true,
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TDarkModeColors.primaryColor,
      brightness: Brightness.dark,
      primary: TLightModeColors.primaryColor,
      primaryContainer: Colors.black,
      onPrimaryContainer: Colors.white,
      secondaryContainer: TDarkModeColors.secondaryContainer,
      onSecondaryContainer: TDarkModeColors.onSecondaryContainer,
      outline: TDarkModeColors.outline,
      surfaceTint: Colors.grey.shade400,
      error: TDarkModeColors.error,
    ),
    dialogTheme: TDarkDialogTheme.darkDialogTheme,
    scaffoldBackgroundColor: TDarkModeColors.scaffoldBgColor,
    appBarTheme: TAppBarTheme.darkTheme,
    textTheme: TTextTheme.darkTextTheme,
    iconTheme: TIconTheme.darkIconTheme,
    filledButtonTheme: TButtonsTheme.darkFilledButtonStyle,
    outlinedButtonTheme: TButtonsTheme.darkOutlinedButtonStyle,
    useMaterial3: true,
  );
}
