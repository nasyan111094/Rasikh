// ─────────────────────────────────────────────────────────────────────────────
// appointment_booking_screen.dart  (Step 3.3 – scheduled only)
// UI unchanged — now driven by ConsultationCubit
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../../core/widgets/auth_stepper.dart';

import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends State<AppointmentBookingScreen> {
  // Arabic weekday/month labels
  static const _arabicDays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
    'الجمعة', 'السبت', 'الأحد',
  ];
  static const _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  final List<DateTime> upcomingDays =
  List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  // Time slots — mirrors original list exactly
  static const List<String> times = [
    "09:00 صباحا", "09:30 صباحا", "10:00 صباحا", "10:30 صباحا",
    "11:00 صباحا", "11:30 صباحا", "12:00 مساءً",
    "01:00 مساء",  "01:30 مساء",  "02:00 مساء",  "02:30 مساء",
    "03:00 مساء",  "03:30 مساء",  "04:00 مساء",  "04:30 مساء",
    "05:00 مساء",  "05:30 مساء",  "06:00 مساء",  "06:30 مساء",
    "07:00 مساء",  "07:30 مساء",  "08:00 مساء",  "08:30 مساء",
    "09:00 مساء",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(title: "حجز موعد"),
      body: SafeArea(
        child: BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(24.h),
                  AuthStepperWidget(activeStep: 5, totalSteps: 6),
                  Gap(24.h),

                  // ── Date label ─────────────────────────────────────
                  Text(
                    "إختر تاريخ الجلسة *",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(12.h),

                  // ── Days scroll ────────────────────────────────────
                  SizedBox(
                    height: 130.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingDays.length,
                      separatorBuilder: (_, __) => Gap(8.w),
                      itemBuilder: (context, index) {
                        final isSelected =
                            state.selectedDayIndex == index;
                        final day = upcomingDays[index];
                        final dayName = _arabicDays[
                        day.weekday == 7 ? 6 : day.weekday - 1];
                        final formattedDate =
                            "${day.day} ${_arabicMonths[day.month - 1]}";

                        return GestureDetector(
                          onTap: () => context
                              .read<ConsultationApplicationCubit>()
                              .selectDay(index),
                          child: Container(
                            width: 100.w,
                            height: 140.w,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(12.h),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : theme.dividerColor,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.h),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.dividerColor
                                        .withOpacity(.4),
                                  ),
                                  child: Picture(
                                    getAssetIcon("Calendar.svg"),
                                    width: 24.h,
                                    height: 24.h,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : theme.hintColor,
                                  ),
                                ),
                                Gap(6.h),
                                Text(
                                  dayName,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : theme.hintColor,
                                  ),
                                ),
                                Gap(2.h),
                                Text(
                                  formattedDate,
                                  style:
                                  theme.textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Gap(50.h),

                  // ── Time label ─────────────────────────────────────
                  Text(
                    "وقت الإستشارة *",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(8.h),

                  // ── Time grid ──────────────────────────────────────
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: times.length,
                      padding: EdgeInsets.only(top: 8.h),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 3.5,
                      ),
                      itemBuilder: (context, index) {
                        final isSelected =
                            state.selectedTimeIndex == index;
                        return GestureDetector(
                          onTap: () => context
                              .read<ConsultationApplicationCubit>()
                              .selectTime(index),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(12.h),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : theme.dividerColor,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              times[index],
                              style:
                              theme.textTheme.titleSmall?.copyWith(
                                color: isSelected
                                    ? colorScheme.primary
                                    : theme.hintColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Gap(16.h),

                  // ── Next button ────────────────────────────────────
                  SizedBox(
                    height: 48.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                      ),
                      onPressed: () => Nav.paymentScreen(context),
                      child: Text(
                        'التالي',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Gap(16.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
