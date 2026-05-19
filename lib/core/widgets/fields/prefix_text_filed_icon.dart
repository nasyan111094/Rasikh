import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:size_config/size_config.dart';

import '../../../config/theme/colors.dart';

class PrefixTextFiledIcon extends StatelessWidget {
  final String icon;
  Color colorIcon;
  Color colorBorer;

  PrefixTextFiledIcon({
    required this.icon,
    this.colorIcon = grey4A,
    this.colorBorer = colorSBTn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 4.h),
      child: Container(
        width: 50.w,
        margin: EdgeInsetsDirectional.only(end: 10.w),
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(color: colorBorer),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: SvgPicture.asset(icon,
              width: 24.w,
              height: 24.h,
              color: colorIcon),
        ),
      ),
    );
  }
}
