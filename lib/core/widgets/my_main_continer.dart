import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../utils/get_asset_path.dart';

class MyMainContainer extends StatefulWidget {
  const MyMainContainer({
    super.key,
    this.onTap,
    this.ifFalseFunction,
    this.clickedColor,
    this.notClickedColor,
    required this.name,
    this.iconColor,
    required this.isChecked,
    this.icon,
    this.bgColor,

    // required this.image
  });
  final Function()? onTap;
  final Function()? ifFalseFunction;
  final Color? clickedColor;
  final Color? notClickedColor;
  final String name;
  final String? icon;
  final Color? iconColor;
  final bool isChecked;
  final Color? bgColor;
  @override
  State<MyMainContainer> createState() => _MyMainContainerState();
}

class _MyMainContainerState extends State<MyMainContainer> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10.h,
        right: widget.icon == null ? 25.w : 5.w,
        left: widget.icon == null ? 25.w : 5.w,
        bottom: 10.h,
      ),
      decoration: BoxDecoration(
        color:
            widget.isChecked ? widget.bgColor ?? primary : primaryWithOpacity1,
        borderRadius: BorderRadius.circular(5),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.name,
              style: widget.isChecked
                  ? getMediumBlue14Style().copyWith(color: white)
                  : getMediumBlue14Style(),
            ),
            Gap(
              3.w,
            ),
            if (widget.icon != null)
              Picture(
                getAssetIcon(widget.icon!),
                color: widget.iconColor,
              )
          ],
        ),
      ),
    );
  }
}
