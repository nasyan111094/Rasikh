import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/theme/colors.dart';
import '../../../../core/widgets/auth_stepper.dart';
import '../bloc/consulation_application_cubit.dart';
import '../bloc/consulation_application_state.dart';

abstract class ConsultationFlowSpacing {
  static double get horizontal => 16.w;
  static double get stepperVertical => 20.h;
  static double get titleToContent => 15.h;
  static double get fieldGap => 14.h;
  static double get sectionGap => 24.h;
  static double get cardGap => 16.h;
  static double get bottomPadding => 16.h;
  static double get buttonHeight => 52.h;
  static double get radius => 12.w;
}

class ConsultationFlowStepper extends StatelessWidget {
  const ConsultationFlowStepper({super.key, required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
      buildWhen: (previous, current) =>
          previous.isScheduled != current.isScheduled,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: ConsultationFlowSpacing.stepperVertical,
          ),
          child: AuthStepperWidget(
            activeStep: activeStep,
            totalSteps: state.isScheduled ? 6 : 5,
            segmentHeight: 2.h,
            inactiveColor: primary.withOpacity(0.15),
            flushEdges: true,
          ),
        );
      },
    );
  }
}

class ConsultationFieldLabel extends StatelessWidget {
  const ConsultationFieldLabel(this.text, {super.key, this.isRequired = false});

  final String text;
  final bool isRequired;

  static const Color _textColor = Color(0xFF404040);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmed = text.trimRight();
    final hasStar = trimmed.endsWith('*');
    final label =
        hasStar ? trimmed.substring(0, trimmed.length - 1).trimRight() : trimmed;

    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (isRequired || hasStar)
            TextSpan(
              text: ' *',
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ),
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 14.5.sp,
        fontWeight: FontWeight.w500,
        color: _textColor,
        height: 1.4,
      ),
    );
  }
}

class ConsultationBottomButton extends StatelessWidget {
  const ConsultationBottomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ConsultationFlowSpacing.bottomPadding,
      ),
      child: SizedBox(
        width: double.infinity,
        height: ConsultationFlowSpacing.buttonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ConsultationFlowSpacing.radius),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22.h,
                  height: 22.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              : Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: onPressed == null ? null : colorScheme.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

class ConsultationEmptyState extends StatelessWidget {
  const ConsultationEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ConsultationFlowSpacing.sectionGap,
        vertical: ConsultationFlowSpacing.sectionGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.08),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.12),
              ),
              child: Icon(icon, size: 28.w, color: primary),
            ),
          ),
          Gap(16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF404040),
            ),
          ),
          if (message != null) ...[
            Gap(6.h),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                height: 1.5,
                color: greyIconColors,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
