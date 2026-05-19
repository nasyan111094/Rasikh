import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:size_config/size_config.dart';

/// A general reusable option card widget with icon, title, subtitle and radio.
class OptionCard extends StatelessWidget {
  final bool isHorizontal;
  final String value;
  final Widget icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    this.isHorizontal = false,
    required this.value,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: isHorizontal ? EdgeInsets.all(3.w) : EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colorScheme.primary : theme.dividerColor,
            width: 1.w,
          ),
          borderRadius: BorderRadius.circular(12.h),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isHorizontal ? Colors.transparent : isSelected ? colorScheme.primary : theme.dividerColor,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: icon,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),

                  if (!isHorizontal)
                  Column(
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          fontSize: 13.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
           isHorizontal ? Row(children:
           [
             Text(
               subtitle,
               style: theme.textTheme.bodyMedium?.copyWith(
                 color: theme.hintColor,
                 fontSize: 13.sp,
               ),
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
             ),
             Gap(10.w) ,
             Radio<String>(
               value: value,
               groupValue: isSelected ? value : null,
               activeColor: colorScheme.primary,
               onChanged: (_) => onTap(),
             ),
           ],) :

            Radio<String>(
              value: value,
              groupValue: isSelected ? value : null,
              activeColor: colorScheme.primary,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}
