import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/dialogs/otp_dialog.dart';
import '../../../../config/navigation/nav.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../Lawyer/lawyer_Settings/bloc/Profile_cubit/lawyer_cubit.dart';
import '../../../Lawyer/lawyer_Settings/bloc/Profile_cubit/lawyer_state.dart';


/// 🔹 External interface to show the confirmation dialog.
Future<bool?> showLogoutAndDeletAccountConfirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      required String svgAsset,
      bool isLogout = false,
      String confirmText = 'نعم',
      String cancelText = 'لا',
    }) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<LawyerProfileCubit>(),
      child: _ConfirmDialog(
        title: title,
        message: message,
        svgAsset: svgAsset,
        confirmText: confirmText,
        cancelText: cancelText,
        isLogout: isLogout,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String svgAsset;
  final String confirmText;
  final bool isLogout;
  final String cancelText;

  const _ConfirmDialog({
    super.key,
    this.isLogout = true,
    required this.title,
    required this.message,
    required this.svgAsset,
    this.confirmText = 'نعم',
    this.cancelText = 'لا',
  });

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _scaleAnimation;

  /// Mirrors the OTP text typed inside OtpDialog.
  /// We use a ValueNotifier<String> (not a TextEditingController) so there
  /// is nothing to dispose that could be shared across widget lifetimes.
  final ValueNotifier<String> _otpNotifier = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _otpNotifier.dispose();
    super.dispose();
  }

  // ── Deletion flow ─────────────────────────────────────────────────────────

  void _startDeletionFlow(BuildContext context) {
    context.read<LawyerProfileCubit>().sendDeletionOtp();
  }

  /// Opens the OTP dialog.
  ///
  /// KEY FIX: the cubit is captured here — while [outerContext] is still
  /// active — into a plain Dart variable [cubit]. Every subsequent call
  /// (onSubmit, onResend) uses [cubit] directly instead of calling
  /// context.read() on a context that may have been deactivated.
  void _showOtpDialog(BuildContext outerContext, String maskedPhone) {
    _otpNotifier.value = '';

    // ✅ Capture the cubit NOW, before _ConfirmDialog is popped.
    final cubit = outerContext.read<LawyerProfileCubit>();

    // Fresh controller owned and disposed by OtpDialog itself.
    final localController = TextEditingController();
    localController.addListener(() {
      _otpNotifier.value = localController.text;
    });

    showDialog(
      context: outerContext,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: cubit, // use captured cubit, not context.read()
        child: BlocConsumer<LawyerProfileCubit, LawyerProfileState>(
          buildWhen: (_, s) =>
          s is DeleteAccountRequestLoading ||
              s is DeleteAccountRequestSuccess ||
              s is DeleteAccountRequestError,
          listenWhen: (_, s) =>
          s is DeleteAccountRequestSuccess ||
              s is DeleteAccountRequestError,
          listener: (ctx, state) {
            if (state is DeleteAccountRequestSuccess) {
              getIt<LawyerProfileCubit>().cachedProfile = null;
              getIt<CacheHelper>().currentToken = '';
              getIt<CacheHelper>().setUserToken('');
              Navigator.of(ctx).popUntil((route) => route.isFirst);
              Nav.account_type_screen(ctx);
            } else if (state is DeleteAccountRequestError) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
              );
            }
          },
          builder: (ctx, state) {
            return OtpDialog(
              phoneNumber: maskedPhone,
              otpController: localController,
              isLoading: state is DeleteAccountRequestLoading,
              onSubmit: () {
                // ✅ Use captured cubit — no context.read() on dead context.
                final otp = _otpNotifier.value.trim();
                if (otp.isEmpty) return;
                cubit.requestAccountDeletion(otp: otp);
              },
              onResend: () {
                _otpNotifier.value = '';
                localController.clear();
                cubit.sendDeletionOtp(); // ✅ same here
              },
              onChangeNumber: () => Navigator.pop(ctx),
            );
          },
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocListener<LawyerProfileCubit, LawyerProfileState>(
      listenWhen: (_, s) =>
      s is DeleteAccountOtpSuccess || s is DeleteAccountOtpError,
      listener: (ctx, state) {
        if (!widget.isLogout) {
          if (state is DeleteAccountOtpSuccess) {
            Navigator.of(ctx).pop();
            _showOtpDialog(ctx, state.phone);
          } else if (state is DeleteAccountOtpError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          }
        }
      },
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 360.w),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 🩶 Main Card
                    Container(
                      width: 380.w,
                      margin: EdgeInsets.only(top: 36.h),
                      decoration: BoxDecoration(
                        color: cs.onPrimary,
                        borderRadius: BorderRadius.circular(12.h),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20.h,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(16.w, 56.h, 16.w, 16.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            widget.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withOpacity(.6),
                              height: 1.5,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              // ✅ Confirm Button
                              Expanded(
                                child: BlocBuilder<LawyerProfileCubit,
                                    LawyerProfileState>(
                                  buildWhen: (_, s) =>
                                  s is DeleteAccountOtpLoading ||
                                      s is DeleteAccountOtpSuccess ||
                                      s is DeleteAccountOtpError,
                                  builder: (ctx, state) {
                                    final isLoading =
                                    state is DeleteAccountOtpLoading;
                                    return ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                        if (widget.isLogout) {
                                          getIt<CacheHelper>()
                                              .currentToken = '';
                                          getIt<CacheHelper>()
                                              .setUserToken('');
                                          Nav.account_type_screen(
                                              context);
                                        } else {
                                          _startDeletionFlow(ctx);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size.fromHeight(48.h),
                                        elevation: 0,
                                        backgroundColor: cs.error,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12.h),
                                        ),
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                        height: 20.h,
                                        width: 20.w,
                                        child:
                                        const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : Text(
                                        widget.confirmText,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 10.w),
                              // ❌ Cancel Button
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: Size.fromHeight(48.h),
                                    side: BorderSide(
                                      color: (cs.outlineVariant ?? cs.outline)
                                          .withOpacity(.35),
                                      width: 1.w,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12.h),
                                    ),

                                  ),
                                  child: Text(
                                    widget.cancelText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: cs.onSurface.withOpacity(.6),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 🔴 Icon Circle
                    Container(
                      decoration: BoxDecoration(
                        color: cs.onPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8.h,
                          ),
                        ],
                      ),
                      child: Container(
                        width: 64.w,
                        height: 64.h,
                        padding: EdgeInsets.all(10.h),
                        decoration: BoxDecoration(
                          color: cs.onPrimary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.all(5.h),
                          decoration: BoxDecoration(
                            color: cs.error.withOpacity(.1),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            widget.svgAsset,
                            width: 35.w,
                            height: 35.h,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              cs.error,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}