import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

class AuthStepperWidget extends StatelessWidget {
  final int totalSteps;
  final int activeStep;
  final Color? inactiveColor;
  final double? segmentHeight;
  final bool flushEdges;

  const AuthStepperWidget({
    Key? key,
    required this.totalSteps,
    required this.activeStep,
    this.inactiveColor,
    this.segmentHeight,
    this.flushEdges = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 10.h,
      child: Row(
        children: List.generate(
          totalSteps,
              (index) => Expanded(
            child: Container(
              height: segmentHeight ?? 3.h,
              margin: EdgeInsetsDirectional.only(
                start: flushEdges && index == 0 ? 0 : 4.w,
                end: flushEdges && index == totalSteps - 1 ? 0 : 4.w,
              ),
              color: index < activeStep
                  ? colorScheme.primary
                  : inactiveColor ?? colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }
}
