import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';


import '../utils/get_asset_path.dart';
import 'elevated_button.dart';

class LogoutBottomSheet extends StatelessWidget {
  const LogoutBottomSheet({super.key, required this.onYesClicked});
  final VoidCallback onYesClicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.h, vertical: 20.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(20.h),
            DottedBorder(
              color: greyEE, // Border color
              strokeWidth: 1, // Width of the border
              dashPattern: const [
                3,
                3
              ], // Length of the dash and space between dashes
              borderType: BorderType.RRect, // Rounded border
              radius: const Radius.circular(1000), // Rounded corners radius
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Picture(
                  getAssetIcon(
                    'logout.svg',
                  ),
                  height: 40.h,
                  width: 40.h,
                  color: primary,
                ),
              ),
            ),
            Gap(20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Text(
                textAlign: TextAlign.center,
                Loc.logoutTitle(),
                style: getMediumPrimary18Style(),
              ),
            ),
            Gap(20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Text(
                textAlign: TextAlign.center,
                Loc.logoutSubtitle(),
                style: getMediumBlack16Style(),
              ),
            ),
            Gap(30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    removeShadow: true,
                    onTap: onYesClicked,
                    buttonName: "${Loc.yes()} , ${Loc.logoutTitle()}",
                  ),
                ),
              ],
            ),
            Gap(20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    removeShadow: true,
                    buttonColor: Colors.transparent,
                    buttonTextStyle: getMediumPrimary16Style(),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    buttonName: "${Loc.no()} , ${Loc.cancel()}",
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
