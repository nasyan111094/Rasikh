import 'package:flutter/material.dart';
import 'package:rasikh/core/widgets/picture.dart';

import '../utils/get_asset_path.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final String iconPath;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isCircular;
  final double size;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomIconButton({
    Key? key,
    required this.onTap,
    required this.iconPath,
    this.backgroundColor,
    this.iconColor,
    this.isCircular = true,
    this.size = 44.0,
    this.iconSize = 30.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(10.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.primary.withOpacity(0.08),
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius:
          isCircular ? null : BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: padding,
          child: Picture(
            getAssetIcon(iconPath),
            color: iconColor,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }
}
