import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

class GeneralCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  GeneralCustomAppBar({
    super.key,
    this.myColor,
    required this.routeName,
    this.toolBarHeight,
    this.actions,
    this.flexibleSpace,
    this.bottomWidget,
    this.systemUiOverlayStyle,
    this.leadingWidget,
    this.showUserName,
    this.showStartLevel,
    this.navigateToMapScreen,
    this.automaticallyImplyLeading = false,
    this.showAppIconAndName,
    this.showGoldenCrown,
    this.onCrownClicked,
    this.onBackPressed,
    this.height,
  });

  final Color? myColor;
  final String routeName;
  final double? toolBarHeight;
  final Widget? leadingWidget;
  final PreferredSize? bottomWidget;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final List<Widget>? actions;
  final bool? automaticallyImplyLeading;
  final bool? showUserName;
  final bool? showStartLevel;
  final bool? showGoldenCrown;
  final bool? navigateToMapScreen;
  final bool? showAppIconAndName;
  final Widget? flexibleSpace;
  final VoidCallback? onCrownClicked;
  final void Function()? onBackPressed;

  double? height;

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight ?? 100.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? 140.h,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10.h),
              bottomLeft: Radius.circular(10.h))),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: -300.w,
              child: SizedBox(
                height: 140.h,
                child: Picture(
                  getAssetIcon("home_bg.svg"),
                  color: primary.withOpacity(.3),
                  fit: BoxFit.contain,
                ),
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Gap(50.h),
              Row(
                children: [
                  Gap(10.w),
                  IconButton(
                    onPressed: onBackPressed ??
                        () {
                          Navigator.of(context).pop();
                        },
                    icon: CircleAvatar(
                      radius: 22.h,
                      backgroundColor: Colors.white.withOpacity(.2),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  Gap(20.w),
                  Text(
                    routeName,
                    style: getBoldWhite16Style(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
