import 'package:flutter/material.dart';

class CircularProgress extends StatelessWidget {
  const CircularProgress({
    super.key,
    this.value,
    this.strokeWidth,
    this.backgroundColor,
    this.valueColor,
  });

  final double? value;
  final double? strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: Directionality.of(context) == TextDirection.rtl ? -1 : 1,
      child: RotatedBox(
        quarterTurns: 2,
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation(valueColor),
          value: value,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth ?? 4.0,
        ),
      ),
    );
  }
}
