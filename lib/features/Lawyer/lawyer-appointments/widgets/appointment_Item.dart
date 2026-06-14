// features/Lawyer/lawyer-appointments/presentation/widgets/appointment_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:size_config/size_config.dart';

import '../../../../../config/navigation/nav.dart';
import '../../../../../core/widgets/picture.dart';
import '../../../../../core/widgets/square_icon_button.dart';
import '../bloc/lawyer_appointments_cubit.dart';
import '../models/availability_slot_model.dart';

class AppointmentItem extends StatelessWidget {
  final AvailabilitySlot slot;

  const AppointmentItem({super.key, required this.slot});

  // ── Delete confirmation dialog ────────────────────────────────────────────

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
          'حذف الموعد',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا الموعد؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          // ── Cancel ──────────────────────────────────────────────────────
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'إلغاء',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // ── Confirm delete ───────────────────────────────────────────────
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
            child: const Text(
              'حذف',
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

    final durationLabel = 'مدة الجلسة ${slot.sessionDurationMinutes} دقيقة';
    final gapLabel = 'فاصل ${slot.gapMinutes} دقائق';

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
          // ── Calendar icon ───────────────────────────────────────────────
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

          // ── Time & details ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.endTime} - ${slot.startTime}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
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
                // ── Weekly repeat badge ──────────────────────────────────
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
                        'يتكرر أسبوعياً',
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

          // ── Edit button ─────────────────────────────────────────────────
          CustomIconButton(
            onTap: () => Nav.addWorkAppointment(context, slotId: slot.id),
            iconPath: 'edit.svg',
            backgroundColor: Colors.green.withOpacity(0.08),
            iconColor: Colors.green,
            isCircular: false,
            borderRadius: 16.h,
            size: 44.h,
          ),

          Gap(6.w),

          // ── Delete button ───────────────────────────────────────────────
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