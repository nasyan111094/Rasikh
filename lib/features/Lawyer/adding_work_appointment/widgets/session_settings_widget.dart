import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/features/Lawyer/adding_work_appointment/widgets/weekly_repeat_switch.dart';
import 'package:size_config/size_config.dart';

import 'date_picker_field.dart';
import 'dropdown_field.dart';



class SessionSettingsWidget extends StatefulWidget {
  const SessionSettingsWidget({super.key});

  @override
  State<SessionSettingsWidget> createState() => _SessionSettingsWidgetState();
}

class _SessionSettingsWidgetState extends State<SessionSettingsWidget> {
  DateTime? startDate;
  DateTime? endDate;
  int sessionDuration = 30;
  int sessionGap = 10;
  bool isWeeklyRepeat = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🗓️ صف التواريخ
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: "إختر وقت البداية *",
                value: startDate,
                onSelect: (d) => setState(() => startDate = d),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: DatePickerField(
                label: "إختر وقت النهاية *",
                value: endDate,
                onSelect: (d) => setState(() => endDate = d),
              ),
            ),
          ],
        ),
        Gap(40.h),

        /// ⏱️ صف المدة والفاصل
        Row(
          children: [
            Expanded(
              child: DropdownField<int>(
                label: "مدة الجلسة *",
                value: sessionDuration,
                items: [15, 30, 45, 60],
                unit: "دقيقة",
                onChanged: (v) => setState(() => sessionDuration = v!),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: DropdownField<int>(
                label: "الفاصل بين الجلسات *",
                value: sessionGap,
                items: [5, 10, 15, 20],
                unit: "دقائق",
                onChanged: (v) => setState(() => sessionGap = v!),
              ),
            ),
          ],
        ),
        Gap(40.h),

        /// 🔁 تكرار أسبوعي
        WeeklyRepeatSwitch(
          value: isWeeklyRepeat,
          onChanged: (v) => setState(() => isWeeklyRepeat = v),
        ),
      ],
    );
  }
}
