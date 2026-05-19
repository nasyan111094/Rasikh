import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

import '../../utils/widget_utils.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: redError.withOpacity(
          0.7,
        ),
        borderRadius: BorderRadius.circular(
          getLowBorderRadius(),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 10.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error.trim(),
            style: TextStyle(
              color: white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
