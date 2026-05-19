import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      child: Divider(
        color: colorSBTn.withOpacity(.5),
        height: 1,
        thickness: 1,
      ),
    );
  }
}
