import 'package:flutter/material.dart' show StatelessWidget, ThemeData, BuildContext, Widget, ListView, EdgeInsets, BorderRadius, Border, BoxDecoration, CrossAxisAlignment, MainAxisAlignment, FontWeight, Text, Container, Row, Padding, Column, Expanded;
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/widgets/general_divider.dart';
import 'appointment_Item.dart';
import 'day_appointments_widget.dart';

class AppointMentsList extends StatelessWidget {
  const AppointMentsList({
    super.key,
    required this.daysData,
    required this.theme,
  });

  final List<Map<String, dynamic>> daysData;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: daysData.length,
        itemBuilder: (context, index) {
          final day = daysData[index];
          final appointments = day["appointments"] as List;

          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: DayAppointments(theme: theme, day: day, appointments: appointments),
          );
        },
      ),
    );
  }
}

