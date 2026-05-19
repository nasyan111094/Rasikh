import 'package:flutter/material.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';

class CircleIconContainer extends StatelessWidget {
  final String icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final bool hasShadow;
  final double? borderRadius;
  final VoidCallback? onPressed;

  const CircleIconContainer({
    super.key,
    required this.icon,
    this.size = 50,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.iconColor = Colors.black87,
    this.iconSize = 24,
    this.hasShadow = false,
    this.borderRadius,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size / 2;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: hasShadow
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Center(
          child: Picture(
            getAssetIcon(icon),
            color: iconColor,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }
}
