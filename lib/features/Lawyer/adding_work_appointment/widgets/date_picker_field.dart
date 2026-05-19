import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/widgets/picture.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onSelect;

  const DatePickerField({
    required this.label,
    required this.value,
    required this.onSelect,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,       // header background / selected date
              onPrimary: theme.colorScheme.onPrimary,   // header text
              onSurface: theme.colorScheme.onSurface,   // body text
            ),
            dialogBackgroundColor: theme.colorScheme.onSecondaryContainer, // picker background
            cardColor: theme.colorScheme.onSecondaryContainer,
            primaryColor: theme.colorScheme.onSecondaryContainer,
            canvasColor: theme.colorScheme.onSecondaryContainer,

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary, // buttons color
              ),
            ),
          ),
          child: child!,
        );
      },
    );


    if (picked != null) onSelect(picked);
  }









  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏷️ Label text using theme style
       if(label.isNotEmpty) Column
          (
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
          [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(10.h),
          ],
        ),

        // 📅 Date field container
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.h),

            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Picture(getAssetIcon("Calendar.svg"), width: 25.h, height: 25.h, color: theme.hintColor,),
                Gap(10.w) ,
                Expanded(
                  child: Text(
                    value == null
                        ? "DD / MM / YYYY"
                        : "${value!.day.toString().padLeft(2, '0')} / ${value!.month.toString().padLeft(2, '0')} / ${value!.year}",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: "almarai",
                      color: value == null
                          ? theme.dividerColor
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}
