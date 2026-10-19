
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:size_config/size_config.dart';

import '../bloc/lawyer_appointments_cubit.dart';
import '../models/availability_slot_model.dart';
import 'day_appointments_shimmer.dart';
import 'day_appointments_widget.dart';


class AppointmentsListShimmer extends StatelessWidget {
  const AppointmentsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          DayAppointmentsShimmer(slotCount: 2),
          Gap(16.h),
          DayAppointmentsShimmer(slotCount: 1),
          Gap(16.h),
          DayAppointmentsShimmer(slotCount: 3),
        ],
      ),
    );
  }
}


class AppointmentsList extends StatelessWidget {
  const AppointmentsList({
    super.key,
    required this.days,
    required this.theme,
  });

  final List<AvailabilityDay> days;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final activeDays = days.where((d) => d.slots.isNotEmpty).toList();

    if (activeDays.isEmpty) {
      return Expanded(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<LawyerAppointmentsCubit>().fetchWeeklyAvailability(),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Center(
                  child: NoDataWidget(
                      title: Loc.noWorkAppointmentsYet(),
                      message: Loc.addWorkAppointmentHint()),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () =>
            context.read<LawyerAppointmentsCubit>().fetchWeeklyAvailability(),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: activeDays.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: DayAppointments(
                theme: theme,
                day: activeDays[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
