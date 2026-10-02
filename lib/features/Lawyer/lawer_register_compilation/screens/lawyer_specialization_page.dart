
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/snack_bar.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:rasikh/features/common/Auth/screens/auth_page.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/bottom_sheets/terms_conditions_button_sheet.dart';
import '../../../../Shared/widgets/specialization_card.dart';
import '../../../../config/navigation/nav.dart';
import '../cubit/lawyer_registeration_complation_cubit.dart';
import '../cubit/lawyer_registeration_complation_state.dart';
import '../models/lawyer_registeration_complation_model.dart';

class LawyerSpecializationPage extends StatefulWidget {
  const LawyerSpecializationPage({super.key});

  @override
  State<LawyerSpecializationPage> createState() =>
      _LawyerSpecializationPageState();
}

class _LawyerSpecializationPageState extends State<LawyerSpecializationPage> {
  late final LawyerCompletionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LawyerCompletionCubit>()..fetchSpecializations();
  }

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<LawyerCompletionCubit, LawyerCompletionState>(
          listener: (context, state) {
            if (state is LawyerProfileCompleted) {
              _showCongratulationDialog(context);
            } else if (state is LawyerCompletionError) {
              SnackBarBuilder.showFeedBackMessage(
                context,
                state.message,
                isSuccess: false,
              );
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthStepperWidget(totalSteps: 7, activeStep: 7),
                        Gap(16.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Picture(
                            getAssetIcon("no_bg_logo.svg"),
                            width:  120.w,
                            height: 48.h,
                          ),
                        ),
                        Gap(10.h),
                        Text(
                          Loc.specializations(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:      colorScheme.primary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Gap(4.h),
                        Text(
                          Loc.specializationsSubtitle(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Gap(16.h),
                      ],
                    ),
                  ),

                  Expanded(
                    child: BlocBuilder<LawyerCompletionCubit,
                        LawyerCompletionState>(
                      builder: (context, state) {
                        if (state is LawyerSpecializationLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                                color: colorScheme.primary),
                          );
                        }
                        if (state is LawyerSpecializationError) {
                          return _ErrorView(
                            message: state.message,
                            onRetry: _cubit.fetchSpecializations,
                          );
                        }
                        if (state is LawyerSpecializationLoaded) {
                          if (state.specializations.isEmpty) {
                            return Center(
                              child: Text(
                                Loc.noSpecializationsAvailable(),
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: theme.hintColor),
                              ),
                            );
                          }
                          return ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                                20.w, 0, 20.w, 8.h),
                            itemCount: state.specializations.length,
                            separatorBuilder: (_, __) => Gap(12.h),
                            itemBuilder: (_, i) => SpecializationCard(
                              spec:  state.specializations[i],
                              state: state,
                              cubit: _cubit,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                    child: Column(
                      children: [
                        _SubmitButton(cubit: _cubit),
                        Gap(14.h),
                        Text.rich(
                          TextSpan(
                            text: Loc.byRegisteringYou(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()..onTap=
                                    ()
                                {
                                  showModalBottomSheet(
                                    context:          context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const TermsBottomSheet(),
                                  );
                                },
                                text: Loc.agreeToTermsOfServiceTrailing(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:      colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                  text: Loc.andDataProcessingAgreement()),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCongratulationDialog(BuildContext context) {
    showDialog(
      context:            context,
      barrierDismissible: false,
      barrierColor:       Colors.black54,
      builder: (ctx) => _CongratulationDialog(
        onDone: () {
          Navigator.of(ctx, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Loc.thanksAccountUnderReview()),

              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => AuthPage(),
            ),
                (route) => false,
          );
        },
      ),
    );
  }
}







class _SubmitButton extends StatelessWidget {
  final LawyerCompletionCubit cubit;
  const _SubmitButton({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return BlocBuilder<LawyerCompletionCubit, LawyerCompletionState>(
      builder: (context, state) {
        final canProceed   = state is LawyerSpecializationLoaded &&
            state.canProceed;
        final isSubmitting = state is LawyerProfileSubmitting;

        return SizedBox(
          width:  double.infinity,
          height: 54.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: (canProceed && !isSubmitting)
                  ? LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(0.82)],
                begin:  Alignment.centerRight,
                end:    Alignment.centerLeft,
              )
                  : null,
              color: (!canProceed || isSubmitting)
                  ? cs.outlineVariant.withOpacity(0.3)
                  : null,
            ),
            child: AppButton(
              onPressed: (canProceed && !isSubmitting)
                  ? () {
                cubit.saveSpecializations(
                  mainIds: cubit.selectedMainIds,
                  subIds:  cubit.selectedSubIds,
                );
                cubit.completeProfile();
              }
                  : null,

              title : Loc.sendForReview() ,
              isLoading: isSubmitting,

            ),
          ),
        );
      },
    );
  }
}


class _CongratulationDialog extends StatefulWidget {
  final VoidCallback onDone;
  const _CongratulationDialog({required this.onDone});

  @override
  State<_CongratulationDialog> createState() => _CongratulationDialogState();
}

class _CongratulationDialogState extends State<_CongratulationDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      backgroundColor: cs.onPrimary,
      insetPadding:    EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:      116.w,
              height:     116.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [Color(0xFFB8D8EE), Color(0xFFD6ECF7)],
                ),
                border: Border.all(
                  color: const Color(0xFFB5A47A),
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/avatar.png",
                  fit:          BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person_rounded,
                    size:  56.sp,
                    color: cs.primary,
                  ),
                ),
              ),
            ),

            Gap(24.h),

            Text(
              Loc.dearLawyerCongratulations(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color:      cs.primary,
              ),
              textAlign: TextAlign.center,
            ),

            Gap(14.h),

            Text(
              Loc.requestReceivedWillReview(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color:  cs.onSurfaceVariant,
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),

            Gap(30.h),

            SizedBox(
              width:  34.w,
              height: 34.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color:       cs.primary,
              ),
            ),

            Gap(4.h),
          ],
        ),
      ),
    );
  }
}


class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 52.sp, color: cs.error.withOpacity(0.45)),
            Gap(12.h),
            Text(message,
                style:
                theme.textTheme.bodyMedium?.copyWith(color: cs.error),
                textAlign: TextAlign.center),
            Gap(20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:      const Icon(Icons.refresh_rounded),
              label:     Text(Loc.retryAgain()),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}