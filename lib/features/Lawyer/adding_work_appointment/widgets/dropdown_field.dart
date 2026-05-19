import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

class DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String unit;
  final ValueChanged<T?> onChanged;

  const DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🏷️ Label uses current theme text style
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(10.h),

        /// 📦 Dropdown field container
        Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: DropdownButton<T>(
            isExpanded: true,
            dropdownColor: theme.colorScheme.onSecondary,
            value: value,
            underline: const SizedBox(),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  "$e $unit",
                  style: theme.textTheme.titleSmall!.copyWith(color: ColorScheme.of(context).primary),
                ),
              ),
            )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
