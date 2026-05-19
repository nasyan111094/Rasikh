import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../utils/get_asset_path.dart';
import 'elevated_button.dart';

class DeleteBottomSheet extends StatelessWidget {
  const DeleteBottomSheet({super.key, required this.onYesClicked});
  final VoidCallback onYesClicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.h, vertical: 50.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Picture(
              getAssetIcon('delete.svg'),
            ),
            Gap(20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Text(
                textAlign: TextAlign.center,
                Loc.areYouSureAboutDeleting(),
                style: getMediumBlack23Style(),
              ),
            ),
            Gap(30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    removeShadow: true,
                    onTap: () {
                      onYesClicked.call();
                      Navigator.pop(context);
                    },
                    buttonName: Loc.yes(),
                  ),
                ),
                Gap(15.w),
                Expanded(
                  child: CustomElevatedButton(
                    removeShadow: true,
                    buttonName: Loc.no(),
                    buttonTextStyle: const TextStyle(color: Colors.blue),
                    buttonColor: lightBlueColor,
                    onTap: () {
                      Navigator.pop(context);
                    },
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
