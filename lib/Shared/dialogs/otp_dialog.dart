// ─────────────────────────────────────────────────────────────────────────────
// shared/dialogs/otp_dialog.dart
//
// Reusable OTP Dialog
// • Internal resend countdown handling
// • No Bloc
// • No API
// • No Navigation Logic
// • Reusable anywhere
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:size_config/size_config.dart';

class OtpDialog extends StatefulWidget {
  OtpDialog({
    super.key,
    required this.phoneNumber,
    this.onSubmit,
    this.onResend,
    this.onChangeNumber,
    this.initialSeconds = 60,
    this.isLoading = false,
    required this.otpController ,
  });

  final String phoneNumber;
  TextEditingController otpController ;

  final VoidCallback? onSubmit;
  final VoidCallback? onResend;
  final VoidCallback? onChangeNumber;

  final int initialSeconds;

  final bool isLoading;

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final _formKey = GlobalKey<FormState>();



  static const int _otpLength = 6;

  late int _secondsLeft;

  bool _canResend = false;

  Timer? _timer;

  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _secondsLeft = widget.initialSeconds;

    _startTimer();
  }

  // ───────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _timer?.cancel();
    // Don't dispose the controller - it's owned by the parent widget
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TIMER
  // ───────────────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();

    _canResend = false;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) return;

        if (_secondsLeft <= 1) {
          timer.cancel();

          setState(() {
            _secondsLeft = 0;
            _canResend = true;
          });

          return;
        }

        setState(() {
          _secondsLeft--;
        });
      },
    );
  }

  void _onResendPressed() {
    widget.onResend?.call();

    setState(() {
      _secondsLeft = widget.initialSeconds;
      _canResend = false;
    });

    _startTimer();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FORMAT TIMER
  // ───────────────────────────────────────────────────────────────────────────

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString();

    final remainingSeconds =
    (seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$remainingSeconds ثانية';
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MASK PHONE
  // ───────────────────────────────────────────────────────────────────────────

  String _maskPhone(String phone) {
    if (phone.length < 4) return phone;

    final suffix = phone.substring(phone.length - 2);

    final stars = '*' * (phone.length - 2);

    return '$stars$suffix';
  }

  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),

        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24.w,
            28.h,
            24.w,
            20.h,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                // ───────────────────────────────────────────────────────
                // TITLE
                // ───────────────────────────────────────────────────────

                Text(
                  'رمز التحقق',

                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),

                  textAlign: TextAlign.center,
                ),

                Gap(10.h),

                // ───────────────────────────────────────────────────────
                // SUBTITLE
                // ───────────────────────────────────────────────────────

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [
                    Expanded(
                      child: Text(
                        'تم إرسال رمز التحقق إلى',

                        style:
                        theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),

                    Gap(8.w),

                    Text(
                      _maskPhone(widget.phoneNumber),

                      style:
                      theme.textTheme.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                Gap(28.h),

                // ───────────────────────────────────────────────────────
                // LABEL
                // ───────────────────────────────────────────────────────

                Row(
                  children: [
                    Text(
                      'رمز التحقق',

                      style:
                      theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Gap(4.w),

                    Text(
                      '*',

                      style:
                      theme.textTheme.bodyMedium?.copyWith(
                        color: cs.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Gap(14.h),

                // ───────────────────────────────────────────────────────
                // PIN FIELD
                // ───────────────────────────────────────────────────────

                Directionality(
                  textDirection: TextDirection.ltr,

                  child: PinCodeTextField(
                    appContext: context,

                    controller: widget.otpController,

                    length: _otpLength,

                    autoFocus: true,

                    keyboardType: TextInputType.number,



                    cursorColor: cs.primary,

                    validator: (v) {
                      if (v == null ||
                          v.trim().length != _otpLength) {
                        return 'يرجى إدخال الرمز كاملاً';
                      }

                      return null;
                    },

                    textStyle:
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),

                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,

                      borderRadius:
                      BorderRadius.circular(14),

                      fieldHeight: 58.h,
                      fieldWidth: 48.w,

                      activeColor: cs.primary,
                      selectedColor: cs.primary,
                      inactiveColor: cs.outline,

                      activeFillColor: cs.surface,
                      selectedFillColor: cs.surface,
                      inactiveFillColor: cs.surface,
                    ),

                    onChanged: (_) {},
                  ),
                ),

                Gap(28.h),

                // ───────────────────────────────────────────────────────
                // SUBMIT BUTTON
                // ───────────────────────────────────────────────────────

                SizedBox(
                  height: 54.h,

                  child: AppButton(
                    title: 'تأكيد',

                    isLoading: widget.isLoading,

                    onPressed: widget.isLoading
                        ? null
                        : () {
                      if (_formKey.currentState
                          ?.validate() ??
                          false) {
                        widget.onSubmit?.call();
                      }
                    },
                  ),
                ),

                Gap(26.h),

                // ───────────────────────────────────────────────────────
                // RESEND
                // ───────────────────────────────────────────────────────

                Center(
                  child: _canResend
                      ? GestureDetector(
                    onTap: _onResendPressed,

                    child: Text(
                      'إعادة إرسال الكود',

                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        decoration:
                        TextDecoration.underline,
                        decorationColor: cs.primary,
                      ),
                    ),
                  )
                      : RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),

                      children: [
                        const TextSpan(
                          text:
                          'إعادة إرسال الكود بعد : ',
                        ),

                        TextSpan(
                          text:
                          _formatTimer(_secondsLeft),

                          style: theme
                              .textTheme.bodyMedium
                              ?.copyWith(
                            color: cs.primary,
                            fontWeight:
                            FontWeight.w700,
                            decoration:
                            TextDecoration
                                .underline,
                            decorationColor:
                            cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Gap(16.h),


              ],
            ),
          ),
        ),
      ),
    );
  }
}