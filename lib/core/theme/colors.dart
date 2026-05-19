import 'package:flutter/material.dart';

// ====================== BASE COLORS ======================

// primary
const primary = Color(0xffB29569);
const secondary = Color(0xff1C3522);

// blue
const purble = Color(0xff4f008d);

// red
const red = Color(0xffff3333);
const redError = Color(0xffFF3333);

// opacities
Color primaryWithOpacity1 = const Color(0xfff8f6f9);

// greys
const lightGrey = Color(0xFFF9F9F9);
const greyA9 = Color(0xffa9a9a9);
const greyFD = Color(0xffFAF0FD);
const greyA5 = Color(0xffa5a5a5);
const grey80 = Color(0xcc808080);
const grey33 = Color(0xff333333);
const greyD9 = Color(0x1ad9d9d9);
const greyDC = Color(0xffDCDCDC);
const greyDB = Color(0xffDBDBDB);
const greyD4 = Color(0xffD4D4D4);
const greyD8 = Color(0xffD8D5DC);
const greyB2 = Color(0x0ab2b2b2);
const greyC0 = Color(0xffc0c0c0);
const grey5C = Color(0xff5c5c5e);
const greyFB = Color(0xfffbfbfb);
const greyF2 = Color(0xfff2f2f2);
const greyF3 = Color(0xffF3F5F5);
const greyF4 = Color(0xfff4f5fe);
const greyE8 = Color(0xffE8E9EC);
const greyEC = Color(0xffECECEC);
const grey4A = Color(0xff4a4a4a);
const greyD0 = Color(0xffD0D0D0);
const greyF8 = Color(0xffF8F8F8);
const grey71 = Color(0xfF717E9A);
const greyEB = Color(0xffEBEBEB);
const greyEA = Color(0xffd9dbe0);
const greyF9 = Color(0xffF8F6F9);
const greyFA = Color(0xffF7F8FA);
const greyEE = Color(0xffE5D9EE);
const scaffoldBackgroundColor = Color(0xffffffff);
const greyText = Color(0xff9a9fae);
const greyMedium = Color(0xff6d758a);
const greyContact = Color(0xfff1f5f8);
const checkBoxBorderColor = Color(0xfff1f1f1);
const grey = Color(0xffadb1bd);
const selectedColor = Color(0xffd5e7ff);
const cancelColor = Color(0xffd3e3f8);
const heavyPhoneNumberColor = Color(0xff27d5ab);
const lightGreenColor = Color(0xffc0efe1);
const heavyGreenColor = Color(0xff009568);
const heavyGreenColorNew = Color(0xff00b12f);
const lightPhoneNumberColor = Color(0xfff1fffb);
const darkBlueColor = Color(0xffcbddeb);
const lightRedColor = Color(0xffffc9c9);
const lightBlueColor = Color(0xffd3e4f8);
const senderYellowColor = Color(0xfffffae2);
const receiverBlueColor = Color(0xffe1fff7);
const bottomNavColor = Color(0xffe4dce9);
const bottomNavIconColor = Color(0xfff7f8fa);
const bottomNavIconColor2 = Color(0xffa89fb0);
const colorBorders = Color(0xffDDE6E5);
const colorSBTn = Color(0xffE8EEEE);
const Color colorIcons = Color(0xCC808080);
const reeStyle = Color(0xffD65745);

// blacks
const black = Colors.black;
const black19 = Color(0xff191e3a);

// white
const white = Color(0xffffffff);

// ====================== LIGHT THEME COLORS ======================
class TLightModeColors {
  TLightModeColors._();

  static Color primaryColor = primary;
  static Color scaffoldBgColor = Color(0xffffffff);
  static Color appBarBgColor = white;
  static Color appBarFgColor = black.withOpacity(.8);
  static Color secondaryContainer = greyFA;
  static Color onSecondaryContainer = greyMedium;
  static Color outline = greyDC;
  static Color error = redError;
}

// ====================== DARK THEME COLORS ======================
class TDarkModeColors {
  TDarkModeColors._();
  static Color primaryColor = primary;
  static Color scaffoldBgColor = Colors.black;
  static Color appBarBgColor = grey5C;
  static Color appBarFgColor = white.withOpacity(.8);
  static Color secondaryContainer = grey33;
  static Color onSecondaryContainer = greyC0;
  static Color outline = grey80;
  static Color error = redError;
}
