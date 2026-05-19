// ─────────────────────────────────────────────────────────────────────────────
// shared/auth/pages/otp_page.dart
//
// OTP verification screen.
// UI matches OTP_Screen.png 100%.
//
// Design notes from image:
//  • رمز التحقق * label above PIN boxes
//  • 6 rounded-square pin boxes (LTR direction)
//  • "دخول" button (same as login label)
//  • "إعادة إرسال الكود بعد : 1:59 دقيقة" with countdown (underlined link)
//  • "تغيير الرقم" link below (underlined)
//  • Pinned terms footer at bottom
// ─────────────────────────────────────────────────────────────────────────────

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

  /// 1 = came from register flow (7-step), 2 = came from login flow (3-step)
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
      // Controller might already be disposed
    }
    super.dispose();
  }

  // ── format seconds → "1:59 دقيقة" ────────────────────────────────────────
  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s ثانيه ';
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
                  // ── Scrollable area ───────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Gap(16.h),

                            // Step indicator
                            AuthStepperWidget(
                              totalSteps: widget.from == 1 ? 7 : 3,
                              activeStep: 3,
                            ),

                            Gap(24.h),

                            // Logo
                            Align(
                              alignment: Alignment.centerRight,
                              child: Picture(
                                getAssetIcon("no_bg_logo.svg"),
                                width:  120.w,
                                height: 48.h,
                              ),
                            ),

                            Gap(20.h),

                            // Heading
                            Text(
                              'رمز التحقق',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color:      cs.primary,
                              ),
                              textAlign: TextAlign.right,
                            ),

                            Gap(6.h),

                            // Subtitle with masked phone
                            Text(
                              'تم إرسال الرمز الخاص بالتحقق إلى : ${_maskPhone(widget.phoneNumber)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.right,
                            ),

                            Gap(28.h),

                            // OTP label
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'رمز التحقق',
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

                            // ── PIN boxes ─────────────────────────────
                            _buildPinField(theme, cs),

                            Gap(24.h),

                            // Submit button
                            AppButton(
                              isLoading: isVerifying,
                              title: 'دخول',
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

                            // Resend row
                            _buildResendRow(state, theme, cs, isResending),

                            Gap(14.h),

                            // "تغيير الرقم" link
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(
                                  'تغيير الرقم',
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

                  // ── Pinned terms footer ───────────────────────────────
                  _TermsFooter(cs: cs, theme: theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PIN boxes — LTR inside RTL scaffold
  // ─────────────────────────────────────────────────────────────────────────

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
            return 'يرجى إدخال رمز التحقق كاملاً';
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

  // ─────────────────────────────────────────────────────────────────────────
  // Resend row
  //   While counting down: "إعادة إرسال الكود بعد : 1:59 دقيقة"
  //   When can resend:     "إعادة إرسال الكود"  (tappable, underlined)
  // ─────────────────────────────────────────────────────────────────────────

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
      // Can resend — show tappable link
          ? GestureDetector(
        onTap: () => _cubit.resendOtp(phone: widget.phoneNumber),
        child: Text(
          'إعادة إرسال الكود',
          style: theme.textTheme.bodyMedium?.copyWith(
            color:           cs.primary,
            fontWeight:      FontWeight.w600,
            decoration:      TextDecoration.underline,
            decorationColor: cs.primary,
          ),
        ),
      )
      // Counting down — show formatted timer
          : RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
          children: [
            const TextSpan(text: 'إعادة إرسال الكود بعد : '),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Mask phone: show last 2 digits + country code, hide middle with *
  // e.g. "512345678" → "+966*******35"
  // ─────────────────────────────────────────────────────────────────────────

  String _maskPhone(String phone) {
    if (phone.length < 4) return '+966$phone';
    final suffix  = phone.substring(phone.length - 2);
    final stars   = '*' * (phone.length - 2);
    return '$suffix$stars\966';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // State listener
  // ─────────────────────────────────────────────────────────────────────────

  void _handleState(BuildContext context, AuthState state) {
    // Safety check: don't process state changes if widget is being disposed
    if (!mounted) return;
    
    // Verify success
    if (state.verifyOtpStatus == RequestStatus.success) {
      final profileCompleted =
          state.verifyOtpModel!.lawyer.profileCompleted;

      if (state.isRegister || !profileCompleted) {
        Nav.vendorCompletion(
          context,
          vendor: getIt<CacheHelper>().cachedVendorType!,
        );
      } else {
        // Login + profile complete → show user congratulation then go home
        _showUserCongratulationDialog(context);
      }
      _cubit.resetVerifyOtpState();
    }

    // Verify error
    if (state.verifyOtpStatus == RequestStatus.error) {
      SnackBarBuilder.showFeedBackMessage(
        context,
        state.errorMessage,
        isSuccess: false,
      );
      _cubit.resetVerifyOtpState();
    }

    // Resend success
    if (state.resendOtpStatus == RequestStatus.success) {
      SnackBarBuilder.showFeedBackMessage(
        context,
        state.resendOtpModel!.message,
        isSuccess: true,
      );
      _cubit.startOtpTimer();
      _cubit.resetResendOtpState();
    }

    // Resend error
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



// ─────────────────────────────────────────────────────────────────────────────
// _UserCongratulationDialog — matches Congratulation_TO_USER.png
//
// Layout:
//   • Circular avatar (illustrated Saudi man) with gold border
//   • "عزيزي العميل، تهانينا 🎉" — bold primary
//   • "حسابك جاهز للاستخدام. سيتم تحويلك إلى الصفحة الرئيسية خلال لحظات."
//   • Spinner — auto-navigates after 3 s
// ─────────────────────────────────────────────────────────────────────────────

class _UserCongratulationDialog extends StatefulWidget {
  final VoidCallback onDone;
  const _UserCongratulationDialog({required this.onDone});

  @override
  State<_UserCongratulationDialog> createState() =>
      _UserCongratulationDialogState();
}

class _UserCongratulationDialogState
    extends State<_UserCongratulationDialog> {
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
          borderRadius: BorderRadius.circular(24)),
      backgroundColor: cs.surface,
      insetPadding:    EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 36.h, 24.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar ────────────────────────────────────────────────
            Container(
              width:  120.w,
              height: 120.w,
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
                  'assets/images/user_avatar.png',
                  fit:          BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person_rounded,
                    size:  56.sp,
                    color: cs.primary,
                  ),
                ),
              ),
            ),

            Gap(28.h),

            // ── "عزيزي العميل، تهانينا 🎉" ───────────────────────────
            Text(
              'عزيزي العميل، تهانينا 🎉',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color:      cs.primary,
              ),
              textAlign: TextAlign.center,
            ),

            Gap(14.h),

            Text(
              'حسابك جاهز للاستخدام. سيتم تحويلك إلى الصفحة الرئيسية خلال لحظات.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:  cs.onSurfaceVariant,
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),

            Gap(32.h),

            // ── Spinner ───────────────────────────────────────────────
            SizedBox(
              width:  36.w,
              height: 36.w,
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

// ─────────────────────────────────────────────────────────────────────────────
// _TermsFooter — shared pinned footer
// ─────────────────────────────────────────────────────────────────────────────

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
          text:  'من خلال التسجيل، فإنك ',
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
                  'توافق على شروط الخدمة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:           cs.primary,
                    fontWeight:      FontWeight.w700,
                    decoration:      TextDecoration.underline,
                    decorationColor: cs.primary,
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' واتفاقية معالجة البيانات.'),
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
            // Avatar with light blue gradient background + gold border
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
              "عزيزي المحامي، تهانينا 🎉",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color:      cs.primary,
              ),
              textAlign: TextAlign.center,
            ),

            Gap(14.h),

            Text(
              "حسابك جاهز للاستخدام. سيتم تحويلك إلى الصفحة الرئيسية خلال لحظات.",
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