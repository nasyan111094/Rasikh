// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/presentation/screens/change_phone_number_screen.dart
//
// Step 1 → enter new phone → request OTP
// Step 2 → enter OTP      → verify & update phone
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/navigation/nav.dart';
import '../../../../core/widgets/fields/phone_field.dart';
import '../../../../core/widgets/gradiant_button.dart';
import '../../../Lawyer/lawyer_Settings/bloc/Profile_cubit/lawyer_cubit.dart';
import '../../../Lawyer/lawyer_Settings/bloc/Profile_cubit/lawyer_state.dart';

import '../widgets/header_capsule_appbar_widget.dart';

class ChangePhoneNumber extends StatefulWidget {
  const ChangePhoneNumber({super.key});

  @override
  State<ChangePhoneNumber> createState() => _ChangePhoneNumberState();
}

class _ChangePhoneNumberState extends State<ChangePhoneNumber> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false; // true → show OTP step

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ── Step 1 ─────────────────────────────────────────────────────────────────
  void _requestOtp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LawyerProfileCubit>().requestPhoneChange(
      phone: _phoneCtrl.text.trim(),
    );
  }

  // ── Step 2 ─────────────────────────────────────────────────────────────────
  void _verifyOtp() {
    if (_otpCtrl.text.trim().length < 4) return;
    context.read<LawyerProfileCubit>().verifyPhoneChange(
      phone: _phoneCtrl.text.trim(),
      code: _otpCtrl.text.trim(),
    );
  }

  Future<void> showOrderConfirmedDialog2(BuildContext context) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Green Check Icon
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2E7D32), // green background
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ Title
                Text(
                  "تحديث البيانات",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFAE895D),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // ✅ Subtitle
                Text(
                  "تم تحديث بياناتك بنجاح !",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),


              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LawyerProfileCubit, LawyerProfileState>(
      listener: (context, state) {
        if (state is ChangePhoneRequestSuccess) {
          setState(() => _otpSent = true);
          _showSnack(context, state.message, theme.colorScheme.primary,
              theme.colorScheme.onPrimary);
        } else if (state is ChangePhoneRequestError) {
          _showSnack(context, state.message, theme.colorScheme.error,
              theme.colorScheme.onError);
        } else if (state is ChangePhoneVerifySuccess) {
          showOrderConfirmedDialog2(context);
          Future.delayed(Duration(seconds: 1) , ()
          {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          }) ;
        } else if (state is ChangePhoneVerifyError) {
          _showSnack(context, state.message, theme.colorScheme.error,
              theme.colorScheme.onError);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: const HeaderCapsuleAppBar(title: 'تعديل رقم الجوال'),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(40.h),

                    // ── Phone field ─────────────────────────────────────────
                    PhoneField(controller: _phoneCtrl),

                    // ── OTP field (shown after step 1) ──────────────────────
                    if (_otpSent) ...[
                      Gap(24.h),
                      _OtpSentHint(phone: _phoneCtrl.text.trim()),
                      Gap(16.h),
                      _OtpField(controller: _otpCtrl),
                    ],
                  ],
                ),
              ),
            ),
          ),

          bottomNavigationBar:
          BlocBuilder<LawyerProfileCubit, LawyerProfileState>(
            buildWhen: (p, c) =>
            c is ChangePhoneRequestLoading ||
                c is ChangePhoneRequestSuccess ||
                c is ChangePhoneRequestError ||
                c is ChangePhoneVerifyLoading ||
                c is ChangePhoneVerifySuccess ||
                c is ChangePhoneVerifyError,
            builder: (context, state) {
              final isLoading = state is ChangePhoneRequestLoading ||
                  state is ChangePhoneVerifyLoading;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AppButton(
                  title: isLoading
                      ? ''
                      : _otpSent
                      ? 'تأكيد'
                      : 'إرسال الرمز',
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : _otpSent
                      ? _verifyOtp
                      : _requestOtp,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSnack(
      BuildContext ctx, String msg, Color bg, Color textColor) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: Theme.of(ctx)
              .textTheme
              .bodyMedium
              ?.copyWith(color: textColor),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.h)),
      ),
    );
  }
}

// ── OTP sent hint ─────────────────────────────────────────────────────────────

class _OtpSentHint extends StatelessWidget {
  final String phone;
  const _OtpSentHint({required this.phone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.h),
        border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18.sp, color: theme.colorScheme.primary),
          Gap(8.w),
          Expanded(
            child: Text(
              'تم إرسال رمز التحقق إلى +966$phone',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OTP Field ─────────────────────────────────────────────────────────────────

class _OtpField extends StatelessWidget {
  final TextEditingController controller;
  const _OtpField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: theme.textTheme.titleLarge?.copyWith(
        letterSpacing: 8,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '• • • • • •',
        hintStyle: theme.textTheme.titleLarge?.copyWith(
          letterSpacing: 8,
          color: cs.onSurface.withOpacity(0.3),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.primary, width: 1.4),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.error, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
      ),
      validator: (v) =>
      (v == null || v.length < 4) ? 'من فضلك أدخل رمز التحقق' : null,
    );
  }
}