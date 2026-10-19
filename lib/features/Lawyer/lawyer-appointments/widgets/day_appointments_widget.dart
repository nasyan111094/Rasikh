
import 'package:rasikh/config/localization/loc_keys.dart';
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

  static List<String> get _dayNames => [
    Loc.saturday(),
    Loc.sunday(),
    Loc.mondayAlt(),
    Loc.tuesdayAlt(),
    Loc.wednesday(),
    Loc.thursday(),
    Loc.friday(),
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
                    Loc.appointmentsCount(day.slots.length),
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

          ...day.slots.map(
                (slot) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: AppointmentItem(slot: slot, dayIndex: day.dayIndex),
            ),
          ),

          Gap(12.w),
        ],
      ),
    );
  }
}