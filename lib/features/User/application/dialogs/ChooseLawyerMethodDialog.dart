
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:size_config/size_config.dart';

import '../../../../../config/navigation/nav.dart';
import '../../../../../core/widgets/picture.dart';

import '../bloc/consulation_application_cubit.dart';

class ChooseLawyerMethodDialog extends StatefulWidget {
  const ChooseLawyerMethodDialog({super.key});

  @override
  State<ChooseLawyerMethodDialog> createState() =>
      _ChooseLawyerMethodDialogState();
}

class _ChooseLawyerMethodDialogState
    extends State<ChooseLawyerMethodDialog> {
  String selectedOption = 'recommend';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Loc.chooseLawyerAssignmentMethod(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.dividerColor.withOpacity(.2),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(Icons.close, color: theme.hintColor),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    context,
                    title: Loc.recommendTheBest(),
                    icon: "user.svg",
                    value: 'recommend',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildOptionCard(
                    context,
                    title: Loc.iChooseTheLawyer(),
                    icon: "recommendation.svg",
                    value: 'choose',
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);

                  Logger().d(selectedOption);

                  final cubit = context.read<ConsultationApplicationCubit>();

                  if (selectedOption == 'recommend') {
                    cubit.loadRecommendedLawyer();
                  } else {
                    cubit.loadLawyers();
                  }

                  Nav.chooseLawyerScreen(context , recommended: selectedOption == 'recommend' ? true : false  );
                },
                child: Text(
                  Loc.next(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildOptionCard(
      BuildContext context, {
        required String title,
        required String icon,
        required String value,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedOption == value;

    return InkWell(
      borderRadius: BorderRadius.circular(12.h),
      onTap: () => setState(() => selectedOption = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(
            color:
            isSelected ? colorScheme.primary : theme.dividerColor,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : theme.dividerColor,
                      width: 1.5,
                    ),
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : theme.dividerColor,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0.h),
                child: Picture(
                  getAssetIcon(icon),
                  color: isSelected
                      ? colorScheme.primary
                      : theme.hintColor,
                  height: 28.h,
                  width: 28.h,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}