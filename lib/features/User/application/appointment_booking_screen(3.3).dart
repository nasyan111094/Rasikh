
import 'package:rasikh/config/localization/loc_keys.dart';
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

import '../../../core/widgets/error_state_widget.dart';
import '../../Lawyer/consultation/Bloc/consultations_states.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/bookable_slot_model.dart';
import 'widgets/consultation_flow_widgets.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String? lawyerId;

  final String? consultationId;

  final bool isRescheduleMode;

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
  static List<String> get _arabicDays => [
    Loc.mondayAlt(), Loc.tuesdayAlt(), Loc.wednesday(), Loc.thursday(),
    Loc.friday(), Loc.saturday(), Loc.sunday(),
  ];
  static List<String> get _arabicMonths => [
    Loc.january(), Loc.february(), Loc.march(), Loc.april(), Loc.may(), Loc.june(),
    Loc.july(), Loc.august(), Loc.september(), Loc.october(), Loc.november(), Loc.december(),
  ];

  final List<DateTime> upcomingDays =
  List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllSlots();
    });
  }

  void _fetchAllSlots() {
    final cubit = context.read<ConsultationApplicationCubit>();
    final lawyer = cubit.state.selectedLawyer;

    final lawyerId = widget.lawyerId ?? lawyer?.id;
    if (lawyerId == null) return;

    cubit.fetchBookableSlots(
      lawyerId: lawyerId,
      from: upcomingDays.first,
      to: upcomingDays.last.add(const Duration(days: 1)),
      durationMinutes: cubit.state.selectedPricing?.duration,
    );
  }


  String _formatArabicTime(DateTime dt) {
    dt = dt.toLocal();
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour < 12 ? Loc.amPlain() : Loc.pmLong();
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }


  Widget _buildTimeSlotsGrid(
      BuildContext context,
      ConsultationState state,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    final status = state.bookableSlotsStatus;

    if (status == ConsultationStatus.loading) {
      return _buildSlotsShimmer(theme);
    }

    if (status == ConsultationStatus.failure) {
      return Center(
        child: ErrorStateWidget(
          title: Loc.failedToLoadAppointments(),
          message: state.bookableSlotsError ?? Loc.unableToConnectToServer(),
          actionLabel: Loc.retryAgain(),
          onAction: _fetchAllSlots,
        ),
      );
    }

    final selectedDay = upcomingDays[state.selectedDayIndex];
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
    final now = DateTime.now();

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

    if (daySlots.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: ConsultationEmptyState(
            icon: Icons.event_busy_rounded,
            title: Loc.noAvailableAppointments(),
            message: selectedDay.day == now.day
                ? Loc.noRemainingAppointmentsToday()
                : Loc.noAvailableAppointmentsThisDay(),
          ),
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


  void _onConfirm(BuildContext context, ConsultationState state) {
    if (widget.isRescheduleMode) {
      final slot = state.selectedBookableSlot;
      if (slot == null) return;
      Navigator.of(context).pop();
      widget.onRescheduleConfirmed!(slot.startTime);
    } else {
      context.read<ConsultationApplicationCubit>().createConsultation();
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<ConsultationsCubit, ConsultationsState>(
      listener: (context, state) {
      },
      builder: (context, _) {
        return Scaffold(
          appBar: GeneralAppBar(
            title: widget.isRescheduleMode ? Loc.reschedule() : Loc.bookAppointment(),
            backIcon: Icons.arrow_back,
            backIconSize: 22,
          ),
          body: SafeArea(
            child: BlocListener<ConsultationApplicationCubit, ConsultationState>(
              listenWhen: (prev, curr) =>
              !widget.isRescheduleMode &&
                  prev.createStatus != curr.createStatus,
              listener: (context, state) {
                if (state.createStatus == ConsultationStatus.success) {
                  Nav.paymentScreen(context);
                } else if (state.createStatus == ConsultationStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.createError ?? Loc.errorCreatingConsultation(),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: ConsultationFlowSpacing.horizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isRescheduleMode)
                          Gap(ConsultationFlowSpacing.sectionGap)
                        else
                          const ConsultationFlowStepper(activeStep: 5),

                        ConsultationFieldLabel(Loc.chooseSessionDateRequired()),
                        Gap(ConsultationFlowSpacing.titleToContent),

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

                        Gap(ConsultationFlowSpacing.sectionGap),

                        ConsultationFieldLabel(Loc.consultationTimeRequired()),
                        Gap(ConsultationFlowSpacing.titleToContent),

                        Expanded(
                          child: _buildTimeSlotsGrid(
                              context, state, theme, colorScheme),
                        ),

                        ConsultationBottomButton(
                          text: widget.isRescheduleMode
                              ? Loc.confirmReschedule()
                              : Loc.next(),
                          isLoading: isCreating,
                          onPressed: hasSlot
                              ? () => _onConfirm(context, state)
                              : null,
                        ),
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