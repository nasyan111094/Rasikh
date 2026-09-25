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
//  8. [NEW] isRescheduleMode flag: skips stepper, changes title & button label,
//     calls onRescheduleConfirmed(startTime) instead of createConsultation().
//     The ConsultationsCubit reschedule listener lives in MyAppointmentsScreen.
//  9. [NEW] Time-slots grid now handles loading / empty / error with reusable
//     widgets (NoDataWidget, ErrorStateWidget) and filters out past slots.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/features/Lawyer/consultation/Bloc/consultations_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/auth_stepper.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/no_data_widget.dart';
import '../../Lawyer/consultation/Bloc/consultations_states.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/bookable_slot_model.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String? lawyerId;

  // ── Booking mode ───────────────────────────────────────────────────────────
  /// ID of an existing consultation (only used in booking mode for reference).
  final String? consultationId;

  // ── Reschedule mode ──────────────────────────────────────────────────────
  /// When [true] the screen operates in reschedule mode:
  ///   • Stepper is hidden.
  ///   • AppBar title becomes "إعادة الجدولة".
  ///   • Confirm button calls [onRescheduleConfirmed] instead of
  ///     createConsultation(), passing the selected slot's start time.
  ///   • The BlocListener for createStatus is NOT wired (it's the caller's
  ///     responsibility to listen to ConsultationRescheduled / Error).
  final bool isRescheduleMode;

  /// Called with the chosen [DateTime] when the user taps "تأكيد إعادة الجدولة"
  /// in reschedule mode. The caller (MyAppointmentsScreen) owns the cubit call.
  final void Function(DateTime newStartTime)? onRescheduleConfirmed;

  const AppointmentBookingScreen({
    super.key,
    this.lawyerId,
    this.consultationId,
    this.isRescheduleMode = false,
    this.onRescheduleConfirmed,
  }) : assert(
  !isRescheduleMode || onRescheduleConfirmed != null,
  'onRescheduleConfirmed must be provided when isRescheduleMode is true',
  );

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllSlots();
    });
  }

  /// Fetches slots for the entire 7-day window in one API call.
  void _fetchAllSlots() {
    final cubit = context.read<ConsultationApplicationCubit>();
    final lawyer = cubit.state.selectedLawyer;

    // In reschedule mode the lawyer may not be in the application cubit's
    // state; fall back to the widget param so the fetch still works.
    final lawyerId = widget.lawyerId ?? lawyer?.id;
    if (lawyerId == null) return;

    cubit.fetchBookableSlots(
      lawyerId: lawyerId,
      from: upcomingDays.first,
      to: upcomingDays.last.add(const Duration(days: 1)),
      durationMinutes: cubit.state.selectedPricing?.duration,
    );
  }

  // ── Formatting helpers ────────────────────────────────────────────────────

  String _formatArabicTime(DateTime dt) {
    dt = dt.toLocal();
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

    // ── Loading ─────────────────────────────────────────────────────────────
    if (status == ConsultationStatus.loading) {
      return _buildSlotsShimmer(theme);
    }

    // ── Error ───────────────────────────────────────────────────────────────
    if (status == ConsultationStatus.failure) {
      return Center(
        child: ErrorStateWidget(
          title: 'فشل تحميل المواعيد',
          message: state.bookableSlotsError ?? 'تعذر الاتصال بالخادم',
          actionLabel: 'إعادة المحاولة',
          onAction: _fetchAllSlots,
        ),
      );
    }

    final selectedDay = upcomingDays[state.selectedDayIndex];
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
    final now = DateTime.now();

    // ✅ Only show slots that are:
    //    1. On the selected day
    //    2. Strictly after "now" (you can't book a slot that already started)
    final daySlots = (state.bookableSlots?.slots ?? [])
        .where((s) {
      final localStart = s.startTime.toLocal();
      final dateMatch =
          DateFormat('yyyy-MM-dd').format(localStart) == selectedDateStr;
      final isFuture = localStart.isAfter(now);
      return dateMatch && isFuture;
    })
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // ── Empty ─────────────────────────────────────────────────────────────────
    if (daySlots.isEmpty) {
      return Center(
        child: NoDataWidget(
          icon: Icons.event_busy_rounded,
          title: 'لا توجد مواعيد متاحة',
          message: selectedDay.day == now.day
              ? 'لا توجد مواعيد متبقية لهذا اليوم'
              : 'لا توجد مواعيد متاحة في هذا اليوم',
        ),
      );
    }

    // ── Success (has data) ──────────────────────────────────────────────────
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
                color: isSelected ? colorScheme.primary : theme.dividerColor,
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

  // ── Shimmer for time slots ────────────────────────────────────────────────

  Widget _buildSlotsShimmer(ThemeData theme) {
    final baseColor = theme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final highlightColor = theme.brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade600;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        itemCount: 6,
        padding: EdgeInsets.only(top: 8.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 3.5,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.h),
          ),
        ),
      ),
    );
  }

  // ── Confirm action ────────────────────────────────────────────────────────

  /// Handles the primary button press depending on the current mode.
  void _onConfirm(BuildContext context, ConsultationState state) {
    if (widget.isRescheduleMode) {
      final slot = state.selectedBookableSlot;
      if (slot == null) return;
      // Pop the screen first so the BlocListener in MyAppointmentsScreen
      // can display snack-bars correctly on top of the list screen.
      Navigator.of(context).pop();
      widget.onRescheduleConfirmed!(slot.startTime);
    } else {
      context.read<ConsultationApplicationCubit>().createConsultation();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // In reschedule mode we don't need the outer ConsultationsCubit listener
    // because MyAppointmentsScreen's BlocListener already handles those states.
    // We still wrap with BlocConsumer so the widget tree is valid in both modes.
    return BlocConsumer<ConsultationsCubit, ConsultationsState>(
      listener: (context, state) {
        // Intentionally empty: reschedule feedback is handled by the caller.
      },
      builder: (context, _) {
        return Scaffold(
          appBar: GeneralAppBar(
            title: widget.isRescheduleMode ? 'إعادة الجدولة' : 'حجز موعد',
          ),
          body: SafeArea(
            child: BlocListener<ConsultationApplicationCubit, ConsultationState>(
              listenWhen: (prev, curr) =>
              !widget.isRescheduleMode &&
                  prev.createStatus != curr.createStatus,
              listener: (context, state) {
                // Only active in booking mode.
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
                  final isCreating =
                      state.createStatus == ConsultationStatus.loading;
                  final hasSlot = state.selectedBookableSlot != null;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(24.h),

                        // ── Stepper (booking mode only) ───────────────────
                        if (!widget.isRescheduleMode) ...[
                          AuthStepperWidget(activeStep: 5, totalSteps: 6),
                          Gap(24.h),
                        ],

                        // ── Date label ────────────────────────────────────
                        Text(
                          'إختر تاريخ الجلسة *',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Gap(12.h),

                        // ── Days horizontal scroll ────────────────────────
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
                                  '${day.day} ${_arabicMonths[day.month - 1]}';

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
                                          getAssetIcon('Calendar.svg'),
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

                        // ── Time label ────────────────────────────────────
                        Text(
                          'وقت الإستشارة *',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Gap(8.h),

                        // ── Time slots grid ───────────────────────────────
                        Expanded(
                          child: _buildTimeSlotsGrid(
                              context, state, theme, colorScheme),
                        ),

                        Gap(16.h),

                        // ── Primary button ────────────────────────────────
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
                            // Disabled until a slot is selected or while loading.
                            onPressed: (!hasSlot || isCreating)
                                ? null
                                : () => _onConfirm(context, state),
                            child: isCreating
                                ? SizedBox(
                              height: 22.h,
                              width: 22.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                                : Text(
                              widget.isRescheduleMode
                                  ? 'تأكيد إعادة الجدولة'
                                  : 'التالي',
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
          ),
        );
      },
    );
  }
}