import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../config/theme/colors.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key, this.title, this.externalWidget});
  final String? title;
  final Widget? externalWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
               gradient:  const LinearGradient(colors: [
                  primary,
                  primary,
                ]).withOpacity(.1)
          ),
            child: Padding(
              padding: EdgeInsets.all(100.h),
              child: Picture(
                getAssetIcon("nodata.svg"),
                height: 200.h,
                width: 200.h,
              ),
            ),
          ),
        ),
        Gap(25.h),
        Text(
          title ?? "",
          style: getBoldBlack20Style(),
        ),
        externalWidget ?? const SizedBox(),
      ],
    );
  }
}
