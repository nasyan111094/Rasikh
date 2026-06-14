// ─────────────────────────────────────────────────────────────────────────────
// appointment_booking_screen.dart  (Step 3.3 – scheduled only)
// Fixed:
//  1. _buildTimeSlotsGrid moved out of itemBuilder → proper class method
//  2. Duplicate onTap removed from GestureDetector
//  3. Slots fetched once for full 7-day window on initState (not per day tap)
//  4. Stale `times` list removed
//  5. @override added to build()
//  6. Next button calls createConsultation() + guards on selectedBookableSlot
//  7. BlocListener handles createStatus success → Nav.paymentScreen
//                                        failure → SnackBar error
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/auth_stepper.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/bookable_slot_model.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  // ── Arabic labels ──────────────────────────────────────────────────────────
  static const _arabicDays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
    'الجمعة', 'السبت', 'الأحد',
  ];
  static const _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  // Fixed 7-day window starting today
  final List<DateTime> upcomingDays =
  List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  @override
  void initState() {
    super.initState();
    // Fetch slots for the full 7-day window once on entry.
    // No need to refetch when the user taps a different day — we just filter
    // the already-loaded list by date.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllSlots();
    });
  }

  /// Fetches slots for the entire 7-day window in one API call.
  void _fetchAllSlots() {
    final cubit = context.read<ConsultationApplicationCubit>();
    final lawyer = cubit.state.selectedLawyer;
    if (lawyer == null) return;

    cubit.fetchBookableSlots(
      lawyerId: lawyer.id,
      from: upcomingDays.first,
      to: upcomingDays.last.add(const Duration(days: 1)),
      durationMinutes: cubit.state.selectedPricing?.duration,
    );
  }

  // ── Formatting helpers ────────────────────────────────────────────────────

  String _formatArabicTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour < 12 ? 'صباحا' : 'مساءً';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  // ── Time slots grid ───────────────────────────────────────────────────────

  Widget _buildTimeSlotsGrid(
      BuildContext context,
      ConsultationState state,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    final status = state.bookableSlotsStatus;

    // Show loading indicator while fetching
    if (status == ConsultationStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error + retry button on failure
    if (status == ConsultationStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'فشل تحميل المواعيد المتاحة',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            Gap(12.h),
            ElevatedButton(
              onPressed: _fetchAllSlots,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // Filter loaded slots to the currently selected day (local date comparison)
    final selectedDay = upcomingDays[state.selectedDayIndex];
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
    final daySlots = (state.bookableSlots?.slots ?? [])
        .where((s) =>
    DateFormat('yyyy-MM-dd').format(s.startTime.toLocal()) ==
        selectedDateStr)
        .toList();

    if (daySlots.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مواعيد متاحة في هذا اليوم',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return GridView.builder(

      itemCount: daySlots.length,
      padding: EdgeInsets.only(top: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 3.5,
      ),
      itemBuilder: (context, index) {
        final slot = daySlots[index];
        final isSelected =
            state.selectedBookableSlot?.startTime == slot.startTime &&
                state.selectedBookableSlot?.endTime == slot.endTime;

        return GestureDetector(
          onTap: () => context
              .read<ConsultationApplicationCubit>()
              .selectBookableSlot(slot),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.h),
              border: Border.all(
                color:
                isSelected ? colorScheme.primary : theme.dividerColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _formatArabicTime(slot.startTime.toLocal()),
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected ? colorScheme.primary : theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(title: "حجز موعد"),
      body: SafeArea(
        child: BlocListener<ConsultationApplicationCubit, ConsultationState>(
          listenWhen: (prev, curr) =>
          prev.createStatus != curr.createStatus,
          listener: (context, state) {
            if (state.createStatus == ConsultationStatus.success) {
              Nav.paymentScreen(context);
            } else if (state.createStatus == ConsultationStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.createError ?? 'حدث خطأ أثناء إنشاء الاستشارة',
                  ),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
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

                    // ── Date label ────────────────────────────────────────
                    Text(
                      "إختر تاريخ الجلسة *",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Gap(12.h),

                    // ── Days horizontal scroll ────────────────────────────
                    SizedBox(
                      height: 130.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: upcomingDays.length,
                        separatorBuilder: (_, __) => Gap(8.w),
                        itemBuilder: (context, index) {
                          final isSelected = state.selectedDayIndex == index;
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
                                borderRadius: BorderRadius.circular(12.h),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : theme.dividerColor,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
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

                    Gap(24.h),

                    // ── Time label ────────────────────────────────────────
                    Text(
                      "وقت الإستشارة *",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Gap(8.h),

                    // ── Time slots grid (from API) ─────────────────────
                    Expanded(
                      child: _buildTimeSlotsGrid(
                          context, state, theme, colorScheme),
                    ),

                    Gap(16.h),

                    // ── Next button ───────────────────────────────────────
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
                        // Disabled until a slot is selected or while creating
                        onPressed: state.selectedBookableSlot == null ||
                            state.createStatus ==
                                ConsultationStatus.loading
                            ? null
                            : () => context
                            .read<ConsultationApplicationCubit>()
                            .createConsultation(),
                        child: state.createStatus == ConsultationStatus.loading
                            ? SizedBox(
                          height: 22.h,
                          width: 22.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                            : Text(
                          'التالي',
                          style:
                          theme.textTheme.titleMedium?.copyWith(
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
      ),
    );
  }
}