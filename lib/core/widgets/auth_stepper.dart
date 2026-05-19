import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

class AuthStepperWidget extends StatelessWidget {
  final int totalSteps;
  final int activeStep;

  const AuthStepperWidget({
    Key? key,
    required this.totalSteps,
    required this.activeStep,
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
              height: 3.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              color: index < activeStep
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.2), // لون الخطوات الغير نشطة
            ),
          ),
        ),
      ),
    );
  }
}
