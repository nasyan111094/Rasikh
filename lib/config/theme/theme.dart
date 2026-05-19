import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/utils/widget_utils.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import 'colors.dart';
import 'consts.dart';

// const kPing = 'Ping';
const kLato = 'Lato';
const almarai = 'almarai';

const numbersFontFamily = kLato;

ThemeData buildAppTheme() {
  const inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(
      color: greyDC,
      width: 2,
    ),
  );
  const errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(
      color: red,
      width: 1,
    ),
  );
  const focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(
      color: primary,
      width: 1,
    ),
  );
  const fontFamily = almarai;
  final bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16.sp,
  );
  final bodyLargeGreyA9 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16.sp,
  );

  final titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 20.sp,
  );

  final titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15.sp,
  );

  final bodyMedium = TextStyle(
      fontFamily: fontFamily, fontSize: 16.sp, fontWeight: FontWeight.w500);
  final bodySmall = TextStyle(
      fontFamily: fontFamily, fontSize: 14.sp, fontWeight: FontWeight.w300);

  final headLineMedium = TextStyle(
      fontFamily: fontFamily, fontSize: 18.sp, fontWeight: FontWeight.w500);
  final headLineSmall = TextStyle(
      fontFamily: fontFamily, fontSize: 13.sp, fontWeight: FontWeight.w400);

  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    splashFactory: InkRipple.splashFactory,
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(getBorderRadius())),
      ),
    ),
    fontFamily: fontFamily,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    useMaterial3: true,
    primaryColor: primary,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: red,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    disabledColor: greyDC,
    textTheme: TextTheme(
        bodyLarge: bodyLarge,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        headlineMedium: headLineMedium,
        headlineSmall: headLineSmall),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: bodyLargeGreyA9,
      labelStyle: bodyLargeGreyA9,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      border: inputBorder,
      enabledBorder: inputBorder,
      disabledBorder: inputBorder,
      errorBorder: errorBorder,
      focusedBorder: focusedBorder,
      focusedErrorBorder: errorBorder,
      filled: true,
      fillColor: greyB2,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: highAppBarHeight,
      shadowColor: Colors.black54,
      centerTitle: true,
      color: scaffoldBackgroundColor,
      surfaceTintColor: scaffoldBackgroundColor,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      foregroundColor: Colors.black,
    ),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => const Icon(Icons.arrow_back_ios),
      drawerButtonIconBuilder: (context) => Picture(getAssetIcon('drawer.svg')),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        foregroundColor: greyA9,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(getBorderRadius())),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        disabledForegroundColor: Colors.white,
        disabledBackgroundColor: greyDC,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20.sp,
          fontWeight: FontWeight.w500,
        ),
        elevation: 10,
        shadowColor: Colors.black54,
        minimumSize: Size(double.infinity, buttonHeight),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: primary, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(getBorderRadius())),
        ),
        minimumSize: Size(0, buttonHeight),
        backgroundColor: Colors.white,
        foregroundColor: primary,
        disabledForegroundColor: greyDC,
        disabledBackgroundColor: Colors.white,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: greyF2,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.black12,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(getBorderRadius())),
        side: const BorderSide(
          color: greyF2,
          width: 1,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(getBorderRadius())),
        ),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(getBorderRadius())),
      ),
      confirmButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: primary,
      ),
      cancelButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: primaryWithOpacity1,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      // locale: const Locale('ar'),
    ),
  );
}
