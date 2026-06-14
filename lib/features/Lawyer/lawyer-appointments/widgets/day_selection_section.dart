import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

class DaySelectionSection extends StatefulWidget {
  /// [initialSelected] contains indexes 0..6 corresponding to the next 7 days
  /// starting today. [onChanged] is called whenever the selection changes.
  const DaySelectionSection({
    super.key,
    this.initialSelected,
    this.onChanged,
  });

  final Set<int>? initialSelected;
  final ValueChanged<Set<int>>? onChanged;

  @override
  State<DaySelectionSection> createState() => _DaySelectionSectionState();
}

class _DaySelectionSectionState extends State<DaySelectionSection> {
  // ── State is owned here — never re-assigned from props mid-build ──────────
  late Set<int> _selectedDayIndexes;
  late final List<DateTime> _upcomingDays;

  @override
  void initState() {
    super.initState();
    // Deep-copy so external mutations to the passed Set don't bleed in
    _selectedDayIndexes = Set<int>.from(widget.initialSelected ?? <int>{});
    _upcomingDays =
        List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  }

  /// Called by the parent when it restores prefill data asynchronously
  /// (e.g. after fetching from cache in initState via addPostFrameCallback).
  @override
  void didUpdateWidget(DaySelectionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelected != null &&
        widget.initialSelected != oldWidget.initialSelected) {
      setState(() {
        _selectedDayIndexes = Set<int>.from(widget.initialSelected!);
      });
    }
  }

  void _toggleDay(int index) {
    setState(() {
      if (_selectedDayIndexes.contains(index)) {
        _selectedDayIndexes.remove(index);
      } else {
        _selectedDayIndexes.add(index);
      }
    });
    widget.onChanged?.call(Set<int>.from(_selectedDayIndexes));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _upcomingDays.length,
        separatorBuilder: (_, __) => Gap(8.w),
        itemBuilder: (context, index) {
          final isSelected = _selectedDayIndexes.contains(index);
          final day = _upcomingDays[index];
          final dayName = DateFormat('EEEE', 'ar').format(day);
          final date = DateFormat('dd MMM', 'ar').format(day);

          return GestureDetector(
            onTap: () => _toggleDay(index),
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

// ── Stateless day card ────────────────────────────────────────────────────────

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 95.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.h),
        color: isSelected
            ? colorScheme.primary.withOpacity(0.06)
            : Colors.transparent,
        border: Border.all(
          color: isSelected ? colorScheme.primary : theme.dividerColor,
          width: isSelected ? 1.8.w : 1.3.w,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? colorScheme.primary.withOpacity(0.12)
                  : theme.dividerColor.withOpacity(0.3),
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
              fontSize: 13.sp,
              color: isSelected ? colorScheme.primary : theme.hintColor,
            ),
          ),
          Gap(2.h),
          Text(
            date,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 11.sp,
              color: isSelected ? colorScheme.primary : theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}