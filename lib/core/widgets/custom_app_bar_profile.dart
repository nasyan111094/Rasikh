import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

class CustomAppBarProfile extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBarProfile({
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
    this.isBackButton = true,
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
  final VoidCallback? onBackPressed;
  final double? height;
  final bool isBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? 200.h,
      decoration: BoxDecoration(
        color: myColor ?? primary,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(15.h),
          bottomLeft: Radius.circular(15.h),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              child: SvgPicture.asset('assets/icons/stars.svg'),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Gap(24.h),
                Row(
                  children: [
                    Gap(16.w),
                    if (isBackButton)
                      IconButton(
                        onPressed:
                            onBackPressed ?? () => Navigator.of(context).pop(),
                        icon: CircleAvatar(
                          radius: 22.h,
                          backgroundColor: Colors.white.withOpacity(.2),
                          child: Icon(Icons.arrow_back,
                              color: Colors.white, size: 24.sp),
                        ),
                      ),
                    Gap(16.w),
                    Text(routeName,
                        style: TextStyle(fontSize: 18.sp, color: Colors.white)),
                    const Spacer(),
                    if (actions != null && actions!.isNotEmpty) ...actions!,
                    Gap(10.w),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight ?? 200.h);
}
