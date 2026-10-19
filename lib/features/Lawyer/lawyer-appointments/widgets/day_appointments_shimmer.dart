// features/Lawyer/lawyer-appointments/presentation/widgets/day_appointments_shimmer.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/widgets/shimmer_widget.dart';
import 'package:size_config/size_config.dart';

import '../../../../../core/widgets/general_divider.dart';

import 'appointment_item_shimmer.dart';

/// Skeleton placeholder that matches the layout of [DayAppointments].
class DayAppointmentsShimmer extends StatelessWidget {
  const DayAppointmentsShimmer({
    super.key,
    this.slotCount = 2,
  });

  /// How many [AppointmentItemShimmer] rows to show inside this skeleton card.
  final int slotCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.15),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day header skeleton ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 80.w, height: 16.h, radius: 6.h),
                ShimmerBox(width: 60.w, height: 24.h, radius: 8.h),
              ],
            ),
          ),

          GeneralDivider(),
          Gap(12.w),

          // ── Slot skeletons ────────────────────────────────────────────
          for (int i = 0; i < slotCount; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: const AppointmentItemShimmer(),
            ),

          Gap(12.w),
        ],
      ),
    );
  }
}
