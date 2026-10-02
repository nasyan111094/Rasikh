
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';

import 'package:size_config/size_config.dart';

import '../../../../../config/navigation/nav.dart';
import '../../../../../core/widgets/picture.dart';
import '../../../../../core/widgets/square_icon_button.dart';
import '../../../../config/theme/colors.dart' as colorScheme;
import '../bloc/lawyer_appointments_cubit.dart';
import '../lawyer_appointments_screen.dart';
import '../models/availability_slot_model.dart';

class AppointmentItem extends StatelessWidget {
  final AvailabilitySlot slot;

  final int dayIndex;

  const AppointmentItem({
    super.key,
    required this.slot,
    required this.dayIndex,
  });


  Future<void> _confirmDelete(BuildContext context) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          Loc.deleteAppointment(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          Loc.deleteAppointmentConfirmation(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              Loc.cancel(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              Loc.delete(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<LawyerAppointmentsCubit>().deleteSlot(slotId: slot.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final durationLabel = Loc.sessionDurationMinutesLabel(slot.sessionDurationMinutes);
    final gapLabel = Loc.gapMinutesLabel(slot.gapMinutes);

    final startTimeLabel = TimeFormatUtils.formatTimeString(slot.startTime);
    final endTimeLabel = TimeFormatUtils.formatTimeString(slot.endTime);

    return Container(
      padding: EdgeInsets.all(5.w),
      margin: EdgeInsets.symmetric(horizontal: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Picture(
                getAssetIcon('Calendar.svg'),
                width: 30.w,
                height: 30.w,
              ),
            ),
          ),

          Gap(8.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    children: [
                      TextSpan(
                        text: startTimeLabel,
                        style: TextStyle(

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: Loc.toWord() , style: TextStyle( color: colorScheme.primary,)),
                      TextSpan(
                        text: endTimeLabel,
                        style: TextStyle(

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(2.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        durationLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: theme.hintColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ' • ',
                      style:
                      theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                    ),
                    Flexible(
                      child: Text(
                        gapLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (slot.repeatsWeekly) ...[
                  Gap(2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 12.sp,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      Gap(3.w),
                      Text(
                        Loc.repeatsWeekly(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Gap(6.w),

          CustomIconButton(
            onTap: () => Nav.addWorkAppointment(
              context,
              slotId: slot.id,
              initialSlot: slot,
              dayIndex: dayIndex,
            ),
            iconPath: 'edit.svg',
            backgroundColor: Colors.green.withOpacity(0.08),
            iconColor: Colors.green,
            isCircular: false,
            borderRadius: 16.h,
            size: 44.h,
          ),

          Gap(6.w),

          CustomIconButton(
            onTap: () => _confirmDelete(context),
            iconPath: 'Trash_Bin.svg',
            backgroundColor: Colors.red.withOpacity(0.1),
            iconColor: Colors.red,
            isCircular: false,
            borderRadius: 16.h,
            size: 44.h,
          ),
        ],
      ),
    );
  }
}


class TimeFormatUtils {
  TimeFormatUtils._();

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String formatDateTime(DateTime dateTime) {
    return formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
  }

  static String formatTimeString(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return time;

    return formatTimeOfDay(TimeOfDay(hour: hour, minute: minute));
  }

  static String formatTimeRangeString(String range, {String separator = ' - '}) {
    final parts = range.split(separator);
    if (parts.length != 2) return range;

    final start = formatTimeString(parts[0].trim());
    final end = formatTimeString(parts[1].trim());
    return '$start$separator$end';
  }
}

extension TimeOfDayAmPmExtension on TimeOfDay {
  String toAmPm() => TimeFormatUtils.formatTimeOfDay(this);
}

extension DateTimeAmPmExtension on DateTime {
  String toAmPm() => TimeFormatUtils.formatDateTime(this);
}