import 'package:flutter/material.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/widgets/picture.dart' show Picture;

class AppointmentsScreenTitle extends StatelessWidget {
  const AppointmentsScreenTitle({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Picture(getAssetIcon("Calendar.svg"),
              width: 30.w, height: 30.w , color: theme.colorScheme.onSecondaryContainer,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "مواعيد العمل",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "اضبط أوقات العمل والتحكم فيها.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}