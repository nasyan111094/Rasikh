import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/widgets/general_divider.dart';
import 'appointment_Item.dart';

class DayAppointments extends StatelessWidget {
  const DayAppointments({
    super.key,
    required this.theme,
    required this.day,
    required this.appointments,
  });

  final ThemeData theme;
  final Map<String, dynamic> day;
  final List appointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
            color: theme.dividerColor.withOpacity(0.2), width: 2
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟦 عنوان اليوم وعدد المواعيد
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day["day"],
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 3.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Text(
                    "${appointments.length} موعد",
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

          // 🟩 عرض كل موعد داخل اليوم
          ...appointments.map((a) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: AppointmentItem(
                start: a["start"],
                end: a["end"],
                duration: a["duration"],
                breakTime: a["breakTime"],
              ),
            );
          }).toList(),

          Gap(12.w),
        ],
      ),
    );
  }
}