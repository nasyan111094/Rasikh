import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

class LineBottomSheet extends StatelessWidget {
  const LineBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 3.h,
      decoration: BoxDecoration(
        color: primary,
        gradient: const LinearGradient(
          colors: [
            heavyGreenColorNew,
            primary,
          ],
        ),
        borderRadius: BorderRadius.circular(50.w),
      ),
    );
  }
}
