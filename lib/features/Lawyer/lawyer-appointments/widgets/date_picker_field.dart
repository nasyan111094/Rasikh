import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/widgets/picture.dart';

/// A tappable field that opens Flutter's built-in [showTimePicker] and exposes
/// the selected time as a [DateTime] (date portion is today; only h/m matter).
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onSelect;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onSelect,
  });

  Future<void> _pickTime(BuildContext context) async {
    final initial = value != null
        ? TimeOfDay(hour: value!.hour, minute: value!.minute)
        : TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              surface: Colors.white,
              primary: primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      onSelect(DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
    }
  }

  /// e.g. 09:05 AM  /  02:30 PM  — uses 12-h display for friendliness
  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final period = h >= 12 ? 'م' : 'ص';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    return '${displayH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ────────────────────────────────────────────────────────
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(10.h),
        ],

        // ── Time field ───────────────────────────────────────────────────
        GestureDetector(
          onTap: () => _pickTime(context),
          child: Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: value != null
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12.h),
              color: value != null
                  ? theme.colorScheme.primary.withOpacity(0.03)
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Picture(
                  getAssetIcon("Clock.svg"),
                  width: 25.h,
                  height: 25.h,
                  color: value != null
                      ? theme.colorScheme.primary
                      : theme.hintColor,
                ),
                Gap(10.w),
                Expanded(
                  child: Text(
                    value == null ? 'HH : MM' : _formatTime(value!),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: "almarai",
                      color: value == null ? theme.dividerColor : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  color: theme.hintColor,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}