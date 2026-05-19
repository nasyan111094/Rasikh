import 'package:flutter/material.dart';
import 'package:rasikh/core/theme/colors.dart';

class TLightDialogTheme {
  TLightDialogTheme._();

  static DialogThemeData lightDialogTheme = DialogThemeData(
    actionsPadding: EdgeInsets.all(14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    elevation: 0,
    backgroundColor: TLightModeColors.scaffoldBgColor,
  );
}

class TDarkDialogTheme {
  TDarkDialogTheme._();

  static DialogThemeData darkDialogTheme = DialogThemeData(
    insetPadding: EdgeInsets.all(8),
    actionsPadding: EdgeInsets.all(14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    elevation: 0,
    backgroundColor: TDarkModeColors.secondaryContainer,
  );
}
