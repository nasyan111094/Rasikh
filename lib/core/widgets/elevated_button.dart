import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:size_config/size_config.dart';

import 'loading_widget.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? radius;
  final void Function()? onTap;
  final IconData? icon;
  final AssetImage? image;
  final Color? buttonColor;
  final String buttonName;
  final bool? condition;
  final bool? removeShadow;
  final TextStyle? buttonTextStyle;

  Color? borderColor;

  CustomElevatedButton(
      {super.key,
      this.height,
      this.width,
      this.radius,
      this.icon,
      this.image,
      required this.onTap,
      required this.buttonName,
      this.buttonColor,
      this.condition = true,
      this.removeShadow = false,
      this.buttonTextStyle,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 55.h,
      child: condition == true
          ? ElevatedButton(
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(0),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                backgroundColor: WidgetStateProperty.all(
                  buttonColor ?? primary,
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius ?? 12.w),
                      side:
                          BorderSide(color: borderColor ?? Colors.transparent)),
                ),
              ),
              onPressed: onTap,
              child: Text(
                buttonName,
                style: buttonTextStyle ?? getW700White16Style(),
              ))
          : const Center(
              child: LoadingWidget(),
            ),
    );
  }
}
