import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

class DaySelectionSection extends StatefulWidget {
  const DaySelectionSection({super.key});

  @override
  State<DaySelectionSection> createState() => _DaySelectionSectionState();
}

class _DaySelectionSectionState extends State<DaySelectionSection> {
  final Set<int> selectedDayIndexes = {};
  final List<DateTime> upcomingDays =
  List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: upcomingDays.length,
        separatorBuilder: (_, __) => Gap(8.w),
        itemBuilder: (context, index) {
          final isSelected = selectedDayIndexes.contains(index);
          final day = upcomingDays[index];
          final dayName = DateFormat('EEEE', 'ar').format(day);
          final date = DateFormat('dd MMM', 'ar').format(day);

          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected
                    ? selectedDayIndexes.remove(index)
                    : selectedDayIndexes.add(index);
              });
            },
            child: _DayCard(
              isSelected: isSelected,
              dayName: dayName,
              date: date,
              theme: theme,
              colorScheme: colorScheme,
            ),
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final bool isSelected;
  final String dayName;
  final String date;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _DayCard({
    required this.isSelected,
    required this.dayName,
    required this.date,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: isSelected ? colorScheme.primary : theme.dividerColor,
          width: 1.3.w,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.dividerColor.withOpacity(.3),
            ),
            child: Picture(
              getAssetIcon("Calendar.svg"),
              width: 24.h,
              height: 24.h,
              color: isSelected ? colorScheme.primary : theme.hintColor,
            ),
          ),
          Gap(6.h),
          Text(
            dayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? colorScheme.primary : theme.hintColor,
            ),
          ),
          Gap(2.h),
          Text(
            date,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected ? colorScheme.primary : theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
