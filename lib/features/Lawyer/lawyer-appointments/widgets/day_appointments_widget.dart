// features/Lawyer/lawyer-appointments/presentation/widgets/day_appointments_widget.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../../../../../core/widgets/general_divider.dart';

import '../models/availability_slot_model.dart';
import 'appointment_item.dart';

class DayAppointments extends StatelessWidget {
  const DayAppointments({
    super.key,
    required this.theme,
    required this.day,
  });

  final ThemeData theme;
  final AvailabilityDay day;

  // ── Arabic day names (API uses Sat=0 … Fri=6, same as weekStart Sat) ──────
  static const _dayNames = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  String get _dayName {
    final idx = day.dayIndex;
    if (idx >= 0 && idx < _dayNames.length) return _dayNames[idx];
    return day.date;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day header ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Text(
                    '${day.slots.length} موعد',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          GeneralDivider(),
          Gap(12.w),

          // ── Slot list ─────────────────────────────────────────────────
          ...day.slots.map(
            (slot) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: AppointmentItem(slot: slot),
            ),
          ),

          Gap(12.w),
        ],
      ),
    );
  }
}
