import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

class MyCustomIconsWidget extends StatelessWidget {
  MyCustomIconsWidget(
      {super.key,
      this.height,
      this.width,
      this.backGround,
      this.showShadow,
      required this.onTap,
      required this.childWidget});
  late double? height = 50.h;
  late double? width = 50.w;
  Color? backGround = Colors.white;
  void Function()? onTap;
  final Widget childWidget;
  final bool? showShadow;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backGround,
          // shape: BoxShape.rectangle,

          shape: BoxShape.circle,
        ),
        child: childWidget,
      ),
    );
  }
}
