import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../utils/get_asset_path.dart';
import 'elevated_button.dart';

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({super.key});

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
              color: greyEE,
              strokeWidth: 1.2,
              dashPattern: const [3, 3],
              borderType: BorderType.Circle, // ✅ Circle بدلاً من RRect
              child: Padding(
                padding: EdgeInsets.all(30.h),
                child: Picture(
                  getAssetIcon('logo.svg'),
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
                Loc.noAccountPleaseCreateOne(),
                style: getMediumPrimary18Style(),
              ),
            ),
            Gap(20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Text(
                textAlign: TextAlign.center,
                Loc.doYouWantToCreateAccount(),
                style: getBoldBlack18Style(),
              ),
            ),
            Gap(30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    removeShadow: true,
                    onTap: () async {
                      if (context.mounted) {
                        Nav.login(context);
                      }
                    },
                    buttonName: Loc.yesIWant(),
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
