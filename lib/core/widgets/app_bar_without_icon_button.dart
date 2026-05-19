import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/theme/custom/text_theme.dart';
import 'package:size_config/size_config.dart';

class AppBarWithoutBackIconButton extends StatelessWidget {
   AppBarWithoutBackIconButton({
    super.key,
    required this.theme,
    required this.title ,
  });

  final ThemeData theme;

  String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w , vertical: 23.5.h),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.titleSmall?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Divider(
          height: 1.h,
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
        Gap(23.5.h) ,
      ],
    );
  }
}