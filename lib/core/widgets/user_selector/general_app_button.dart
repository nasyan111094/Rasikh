import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final double elevation;
  final BorderSide? borderSide;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.child,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 8,
    this.elevation = 0,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor:
          backgroundColor ?? colorScheme.primary,
          foregroundColor:
          foregroundColor ?? colorScheme.onPrimary,
          padding: padding ??
              EdgeInsets.symmetric(
                vertical: 14.h,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius.h,
            ),
            side: borderSide ?? BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: 20.w,
          height: 20.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
          ),
        )
            : Padding(
              padding:  EdgeInsets.symmetric(vertical: 2.h),
              child: child ??
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: foregroundColor ??
                      colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      ),
    );
  }
}