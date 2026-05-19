/*
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/cache/pref_keys.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/snack_bar.dart';

import 'package:size_config/size_config.dart';

import '../../../Lawyer/Auth/otp/otp_bloc/otp_bloc.dart';
import '../../../Lawyer/Auth/otp/otp_bloc/otp_state.dart';


class UpdatePhoneOtpDialog extends StatefulWidget {
  const UpdatePhoneOtpDialog({
    super.key,
    required this.phoneNumber,
    required this.otpCode,
  });

  final String phoneNumber;
  final String otpCode;

  @override
  State<UpdatePhoneOtpDialog> createState() => _UpdatePhoneOtpDialogState();
}

class _UpdatePhoneOtpDialogState extends State<UpdatePhoneOtpDialog> {
  final otpTextController = TextEditingController();
  final GlobalKey<FormState> _checkOtp = GlobalKey<FormState>();
  final ValueNotifier<int> _timerSeconds = ValueNotifier(60);
  late bool _resendOTPIsClicked = false;
  late Timer timer;

  OtpBloc otpBloc = getIt<OtpBloc>();

  @override
  void initState() {
    super.initState();
    otpTextController.text = widget.otpCode.replaceAll(RegExp(r'[^0-9]'), '');
    startTimer();
  }

  @override
  void dispose() {
    if (_resendOTPIsClicked) timer.cancel();
    otpTextController.dispose();
    _timerSeconds.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer timer) {
      if (_timerSeconds.value == 0) {
        timer.cancel();
        _resendOTPIsClicked = false;
        _timerSeconds.value = 60;
      } else {
        _resendOTPIsClicked = true;
        _timerSeconds.value = _timerSeconds.value - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocProvider(
      create: (context) => otpBloc,
      child: BlocConsumer<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state is SuccessOtpState) {
            Logger().i("✅ OTP Verified Successfully");
            getIt<CacheHelper>().setCurrentUserAccessTokenInSharedPrefs(
                state.authModel.userData.token);
            getIt<CacheHelper>().put(
                PrefKeys.refreshToken, state.authModel.userData.refreshToken);
            SnackBarBuilder.showFeedBackMessage(
              context,
              "تم تحديث رقم الجوال بنجاح" ,
              isSuccess: true,
            );
            Navigator.pop(context); // Close dialog after success
          } else if (state is ErrorOtpState) {
            SnackBarBuilder.showFeedBackMessage(
              context,
              state.error,
              isSuccess: false,
            );
          }
        },
        builder: (context, state) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.w),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),

            child: Column(
              mainAxisSize: MainAxisSize.min ,
              children: [
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: _checkOtp,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header

                        Gap(8.h),
                        Row(
                          children: [
                            Text(
                              "تم إرسال رمز التحقق إلى ${widget.phoneNumber}",
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 14.sp,
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Gap(20.h),

                        // OTP Field
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: PinCodeTextField(
                            appContext: context,
                            length: 5,
                            backgroundColor: Colors.transparent,
                            controller: otpTextController,
                            cursorColor: colorScheme.primary,
                            keyboardType: TextInputType.number,
                            onCompleted: (v) {},
                            validator: (v) {
                              if (v == null || v.isEmpty || v.length < 5) {
                                return Loc.otbIsEmpty();
                              }
                              return null;
                            },
                            enableActiveFill: true,
                            textStyle: textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            pinTheme: PinTheme(
                              fieldHeight: 55.h,
                              fieldWidth: 50.w,
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(14.w),
                              borderWidth: 1,
                              inactiveColor: colorScheme.outline,
                              activeColor: colorScheme.primary,
                              selectedColor: colorScheme.primary,
                              activeFillColor: colorScheme.surface,
                              inactiveFillColor: colorScheme.surface,
                              selectedFillColor: colorScheme.surface,
                            ),
                          ),
                        ),
                        Gap(16.h),

                        // Resend Section
                        ValueListenableBuilder<int>(
                          valueListenable: _timerSeconds,
                          builder: (context, value, child) {
                            return RichText(
                              text: TextSpan(
                                text: '${Loc.didnt_receive_code()} ',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                children: <TextSpan>[
                                  !_resendOTPIsClicked
                                      ? TextSpan(
                                    text: Loc.resend_code(),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _resendOTPIsClicked = true;
                                        startTimer();
                                      },
                                  )
                                      : TextSpan(
                                    text:
                                    '${Loc.second()} ${_timerSeconds.value}',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        Gap(10.h),


                      ],
                    ),
                  ),
                ),
                GradiantButton(
                  text: Loc.confirm(),
                  processing: state is LoadingOtpState,
                  onTap: () async {
                    if (_checkOtp.currentState!.validate()) {
                      await otpBloc.checkOtp(
                        code: otpTextController.text,
                        from: 2, // from 2 → means update phone
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
*/
