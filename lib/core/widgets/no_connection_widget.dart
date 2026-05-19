import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

class NoConnectionWidget extends StatelessWidget {
  const NoConnectionWidget({super.key, this.title, this.subTitle});
  final String? title;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Picture(getAssetIcon("no_connection.svg")),
        Text(
          title ?? "",
          style: getBoldBlack20Style(),
        ),
        SizedBox(
          height: 20.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 70.w),
          child: Text(
            subTitle ?? "",
            textAlign: TextAlign.center,
            style: getRegularBlack16Style(),
          ),
        ),
      ],
    );
  }
}
