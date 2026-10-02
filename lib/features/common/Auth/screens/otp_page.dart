
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/snack_bar.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/bottom_sheets/terms_conditions_button_sheet.dart';
import '../../../../config/navigation/nav.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'auth_page.dart';


class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.otpCode,
    required this.from,
  });

  final int    from;
  final String phoneNumber;
  final String otpCode;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final AuthCubit _cubit;

  final _formKey      = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  static const int _otpLength = 6;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AuthCubit>();

    if (widget.otpCode.isNotEmpty) {
      _otpController.text = widget.otpCode;
    }

    _cubit.startOtpTimer();
  }

  @override
  void dispose() {
    try {
      _otpController.dispose();
    } catch (e) {
    }
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return Loc.otpTimerSeconds(m, s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      bloc:     _cubit,
      listener: _handleState,
      builder: (context, state) {
        final isVerifying =
            state.verifyOtpStatus == RequestStatus.loading;
        final isResending =
            state.resendOtpStatus == RequestStatus.loading;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(

            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Gap(16.h),

                            AuthStepperWidget(
                              totalSteps: widget.from == 1 ? 7 : 3,
                              activeStep: 3,
                            ),

                            Gap(24.h),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Picture(
                                getAssetIcon("no_bg_logo.svg"),
                                width:  120.w,
                                height: 48.h,
                              ),
                            ),

                            Gap(20.h),

                            Text(
                              Loc.verificationCode(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color:      cs.primary,
                              ),
                              textAlign: TextAlign.right,
                            ),

                            Gap(6.h),

                            Text(
                              Loc.verificationCodeSentTo(_maskPhone(widget.phoneNumber)),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.right,
                            ),

                            Gap(28.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  Loc.verificationCode(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:      cs.onSurface,
                                  ),
                                ),
                                Gap(2.w),
                                Text(
                                  '*',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:      cs.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            Gap(12.h),

                            _buildPinField(theme, cs),

                            Gap(24.h),

                            AppButton(
                              isLoading: isVerifying,
                              title: Loc.signIn(),
                              onPressed: () {
                                if (isVerifying) return;
                                if (_formKey.currentState?.validate() ?? false) {
                                  _cubit.verifyOtp(
                                    phone: widget.phoneNumber,
                                    code:  _otpController.text.trim(),
                                  );
                                }
                              },
                            ),

                            Gap(28.h),

                            _buildResendRow(state, theme, cs, isResending),

                            Gap(14.h),

                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(
                                  Loc.changeNumber(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:           cs.primary,
                                    fontWeight:      FontWeight.w600,
                                    decoration:      TextDecoration.underline,
                                    decorationColor: cs.primary,
                                  ),
                                ),
                              ),
                            ),

                            Gap(40.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  _TermsFooter(cs: cs, theme: theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildPinField(ThemeData theme, ColorScheme cs) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PinCodeTextField(
        appContext:       context,
        controller:       _otpController,
        length:           _otpLength,
        keyboardType:     TextInputType.number,
        autoFocus:        true,
        enableActiveFill: true,
        cursorColor:      cs.primary,
        validator: (v) {
          if (v == null || v.length != _otpLength) {
            return Loc.pleaseEnterFullVerificationCode();
          }
          return null;
        },
        textStyle: theme.textTheme.titleLarge?.copyWith(
          color:      cs.primary,
          fontWeight: FontWeight.bold,
        ),
        pinTheme: PinTheme(
          fieldHeight:       60.h,
          fieldWidth:        52.w,
          shape:             PinCodeFieldShape.box,
          borderRadius:      BorderRadius.circular(14),
          activeColor:       cs.primary,
          selectedColor:     cs.primary,
          inactiveColor:     cs.outline,
          activeFillColor:   cs.onPrimary,
          selectedFillColor: cs.surface,
          inactiveFillColor: cs.onPrimary,
        ),
        onChanged: (_) {},
      ),
    );
  }


  Widget _buildResendRow(
      AuthState   state,
      ThemeData   theme,
      ColorScheme cs,
      bool        isResending,
      ) {
    if (isResending) {
      return Center(
        child: SizedBox(
          width:  22.w,
          height: 22.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: cs.primary,
          ),
        ),
      );
    }

    return Center(
      child: state.canResend
          ? GestureDetector(
        onTap: () => _cubit.resendOtp(phone: widget.phoneNumber),
        child: Text(
          Loc.resendCode(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color:           cs.primary,
            fontWeight:      FontWeight.w600,
            decoration:      TextDecoration.underline,
            decorationColor: cs.primary,
          ),
        ),
      )
          : RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
          children: [
            TextSpan(text: Loc.resendCodeAfter()),
            TextSpan(
              text: _formatTimer(state.secondsLeft),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight:      FontWeight.w700,
                color:           cs.primary,
                decoration:      TextDecoration.underline,
                decorationColor: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _maskPhone(String phone) {
    if (phone.length < 4) return '+966$phone';
    final suffix  = phone.substring(phone.length - 2);
    final stars   = '*' * (phone.length - 2);
    return '$suffix$stars\966';
  }


  void _handleState(BuildContext context, AuthState state) {
    if (!mounted) return;
    
    if (state.verifyOtpStatus == RequestStatus.success) {
      final profileCompleted = state.verifyOtpModel!.lawyer.profileCompleted;
      if (state.isRegister && !profileCompleted) {
        Nav.vendorCompletion(
          context,
          vendor: getIt<CacheHelper>().cachedVendorType!,
        );
      }
      else {
        _showUserCongratulationDialog(context);
      }
      _cubit.resetVerifyOtpState();
    }

    if (state.verifyOtpStatus == RequestStatus.error) {
      SnackBarBuilder.showFeedBackMessage(
        context,
        state.errorMessage,
        isSuccess: false,
      );
      _cubit.resetVerifyOtpState();
    }

    if (state.resendOtpStatus == RequestStatus.success) {
      SnackBarBuilder.showFeedBackMessage(
        context,
        state.resendOtpModel!.message,
        isSuccess: true,
      );
      _cubit.startOtpTimer();
      _cubit.resetResendOtpState();
    }

    if (state.resendOtpStatus == RequestStatus.error) {
      SnackBarBuilder.showFeedBackMessage(
        context,
        state.errorMessage,
        isSuccess: false,
      );
      _cubit.resetResendOtpState();
    }
  }

  void _showUserCongratulationDialog(BuildContext context) {
    showDialog(
      context:            context,
      barrierDismissible: false,
      barrierColor:       Colors.black54,
      builder: (ctx) => _CongratulationDialog(
        onDone: () {
          Nav.layout(context) ;
        },
      ),
    );
  }
}






class _TermsFooter extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData   theme;

  const _TermsFooter({required this.cs, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Text.rich(
        TextSpan(
          text:  Loc.byRegisteringYou(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline:  TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context:            context,
                  isScrollControlled: true,
                  backgroundColor:    Colors.transparent,
                  builder: (_) => const TermsBottomSheet(),
                ),
                child: Text(
                  Loc.agreeToTermsOfService(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:           cs.primary,
                    fontWeight:      FontWeight.w700,
                    decoration:      TextDecoration.underline,
                    decorationColor: cs.primary,
                  ),
                ),
              ),
            ),
            TextSpan(text: Loc.andDataProcessingAgreementLeading()),
          ],
        ),
        textAlign: TextAlign.center,
      ),
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
              Loc.dearUserCongratulations(getIt<CacheHelper>().cachedVendorType == VendorType.lawyer ? Loc.theLawyer() : Loc.theClient()),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color:      cs.primary,
              ),
              textAlign: TextAlign.center,
            ),

            Gap(14.h),

            Text(
              Loc.accountReadyRedirecting(),
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