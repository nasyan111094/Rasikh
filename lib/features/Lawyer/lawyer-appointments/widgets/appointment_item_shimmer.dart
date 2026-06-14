// features/Lawyer/lawyer-appointments/presentation/widgets/appointment_item_shimmer.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/widgets/shimmer_widget.dart';
import 'package:size_config/size_config.dart';



/// Skeleton placeholder that matches the layout of [AppointmentItem].
class AppointmentItemShimmer extends StatelessWidget {
  const AppointmentItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ShimmerWidget(
      child: Container(
        padding: EdgeInsets.all(5.w),
        margin: EdgeInsets.symmetric(horizontal: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.h),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Calendar icon placeholder
            ShimmerBox(
              width: 44.w,
              height: 44.w,
              radius: 22.w, // circle
            ),

            Gap(8.w),

            // Text lines placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120.w, height: 14.h, radius: 6.h),
                Gap(6.h),
                ShimmerBox(width: 180.w, height: 12.h, radius: 6.h),
              ],
            ),

            const Spacer(),

            // Edit button placeholder
            ShimmerBox(width: 44.h, height: 44.h, radius: 16.h),
            Gap(6.w),
            // Delete button placeholder
            ShimmerBox(width: 44.h, height: 44.h, radius: 16.h),
          ],
        ),
      ),
    );
  }
}
