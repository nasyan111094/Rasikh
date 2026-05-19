import 'package:flutter/material.dart';


import '../sizes.dart';

class TIconTheme {
  TIconTheme._();

  static IconThemeData lightIconTheme = IconThemeData().copyWith(
    color: Colors.black,
    size: sp24,
  );

  static IconThemeData darkIconTheme = IconThemeData().copyWith(
    color: Colors.white,
    size: sp24,
  );
}
