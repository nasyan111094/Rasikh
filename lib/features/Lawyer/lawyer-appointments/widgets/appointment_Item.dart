import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/navigation/nav.dart';
import '../../../../core/widgets/picture.dart';
import '../../../../core/widgets/square_icon_button.dart';
import '../../../User/profile/widgets/dialog_widget.dart';

class AppointmentItem extends StatelessWidget {
  final String start;
  final String end;
  final String duration;
  final String breakTime;

  const AppointmentItem({
    required this.start,
    required this.end,
    required this.duration,
    required this.breakTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(5.w),
      margin: EdgeInsets.symmetric(horizontal: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),width: 2
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: (){},
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child:      Padding(
                padding: const EdgeInsets.all(10.0),
                child: Picture(getAssetIcon("Calendar.svg"),
                    width: 30.w, height: 30.w),
              ),
            ),
          ),
          Gap(8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$end - $start",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    duration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: theme.hintColor,
                    ),
                  ),
                  Text(
                    " • ",
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                  ),
                  Text(
                    breakTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          CustomIconButton(
            onTap: () {
             Nav.addWorkAppointment(context) ;
            },
            iconPath: "edit.svg",
            backgroundColor: Colors.green.withOpacity(0.08),
            iconColor: Colors.green,
            isCircular: false,
            borderRadius: 16.h,
            size:44.h,
          ) ,

          Gap(6.w),
          CustomIconButton(
            onTap: ()
            {

              final confirmed   = showLogoutAndDeletAccountConfirmDialog(context, title: "حذف موعد", message: "هل أنت متأكد من رغبتك في حذف ذلك الموعد  ؟", svgAsset: 'assets/icons/Logout_icon.svg') ;

              if (confirmed == true) {
                // TODO: تنفيذ عملية تسجيل الخروج هنا
              }
            },
            iconPath: "Trash_Bin.svg",
            backgroundColor: Colors.red.withOpacity(0.1),
            iconColor: Colors.red,
            isCircular: false,
            borderRadius: 16.h,
            size:44.h,

          )

        ],
      ),
    );
  }
}