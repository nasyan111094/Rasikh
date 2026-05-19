import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/widgets/appointment_Item.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/widgets/appointments_list_widget.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/widgets/appointments_screen_title.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../core/widgets/app_bar_without_icon_button.dart';
import '../../../core/widgets/square_icon_button.dart';

class LawyerAppointmentsScreen extends StatelessWidget {
  LawyerAppointmentsScreen({super.key});
  final List<Map<String, dynamic>> daysData = [
    {
      "day": "السبت",
      "appointments": [
        {
          "start": "09:00",
          "end": "09:30",
          "duration": "مدة الجلسة 30 دقيقة",
          "breakTime": "فاصل 10 دقائق",
        },
        {
          "start": "09:45",
          "end": "10:30",
          "duration": "مدة الجلسة 45 دقيقة",
          "breakTime": "فاصل 5 دقائق",
        },
      ],
    },
    {
      "day": "الأحد",
      "appointments": [
        {
          "start": "08:00",
          "end": "08:45",
          "duration": "مدة الجلسة 45 دقيقة",
          "breakTime": "فاصل 10 دقائق",
        },
        {
          "start": "09:00",
          "end": "09:30",
          "duration": "مدة الجلسة 30 دقيقة",
          "breakTime": "فاصل 15 دقيقة",
        },
        {
          "start": "10:00",
          "end": "11:00",
          "duration": "مدة الجلسة 60 دقيقة",
          "breakTime": "فاصل 10 دقائق",
        },
      ],
    },
    {
      "day": "الاثنين",
      "appointments": [
        {
          "start": "09:00",
          "end": "10:00",
          "duration": "مدة الجلسة 60 دقيقة",
          "breakTime": "فاصل 10 دقائق",
        },
        {
          "start": "10:15",
          "end": "11:00",
          "duration": "مدة الجلسة 45 دقيقة",
          "breakTime": "فاصل 5 دقائق",
        },
      ],
    },
    {
      "day": "الثلاثاء",
      "appointments": [
        {
          "start": "08:30",
          "end": "09:00",
          "duration": "مدة الجلسة 30 دقيقة",
          "breakTime": "فاصل 10 دقائق",
        },
        {
          "start": "09:15",
          "end": "10:15",
          "duration": "مدة الجلسة 60 دقيقة",
          "breakTime": "فاصل 10 دقائق",
        },
      ],
    },
    {
      "day": "الأربعاء",
      "appointments": [
        {
          "start": "09:00",
          "end": "09:45",
          "duration": "مدة الجلسة 45 دقيقة",
          "breakTime": "فاصل 5 دقائق",
        },
      ],
    },
    {
      "day": "الخميس",
      "appointments": [
        {
          "start": "08:00",
          "end": "09:00",
          "duration": "مدة الجلسة 60 دقيقة",
          "breakTime": "فاصل 10 دقائق",
        },
        {
          "start": "09:15",
          "end": "09:45",
          "duration": "مدة الجلسة 30 دقيقة",
          "breakTime": "فاصل 15 دقيقة",
        },
        {
          "start": "10:00",
          "end": "10:30",
          "duration": "مدة الجلسة 30 دقيقة",
          "breakTime": "فاصل 5 دقائق",
        },
      ],
    },
    {
      "day": "الجمعة",
      "appointments": [
        {
          "start": "10:00",
          "end": "11:00",
          "duration": "مدة الجلسة 60 دقيقة",
          "breakTime": "فاصل 10 دقائق",
        },
        {
          "start": "11:15",
          "end": "12:00",
          "duration": "مدة الجلسة 45 دقيقة",
          "breakTime": "فاصل 15 دقائق",
        },
      ],
    },
  ];


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarWithoutBackIconButton(theme: theme , title: "مواعيدي",),
            AppointmentsScreenTitle(theme: theme),
            GeneralDivider(
              height: 25.h,
            ),
            AppointMentsList(daysData: daysData, theme: theme),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GradiantButton(text: "إضافة موعد عمل", onTap:(){Nav.addWorkAppointment(context) ; }),
            ),
          ],
        ),
      ),
    );
  }
}









