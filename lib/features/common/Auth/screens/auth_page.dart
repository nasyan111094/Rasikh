// ─────────────────────────────────────────────────────────────────────────────
// shared/auth/pages/auth_page.dart
//
// Handles both Login and Register phone-entry screens.
// UI matches Login_Screen.png and Sign_Up_Screen.png 100%.
//
// Layout (top → bottom):
//   • AuthStepperWidget
//   • Logo (right-aligned)
//   • Heading + subtitle
//   • Phone label (رقم الجوال *)
//   • PhoneField
//   • Submit button (دخول / التالي)
//   • Switch link row (ليس لديك حساب؟ / هل لديك حساب؟)
//   • Spacer
//   • Terms footer (pinned to bottom)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/fields/phone_field.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/snack_bar.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/bottom_sheets/terms_conditions_button_sheet.dart';
import '../../../../config/navigation/nav.dart';
import '../../../../core/widgets/auth_stepper.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';


enum AuthViewType { phoneLogin, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with AutomaticKeepAliveClientMixin {
  late final AuthCubit _cubit;

  final _formKey = GlobalKey<FormState>();
  final _phoneController      = TextEditingController();
  final _currentViewNotifier  = ValueNotifier(AuthViewType.phoneLogin);
  final _countryCodeNotifier  = ValueNotifier('SA');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AuthCubit>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _currentViewNotifier.dispose();
    _countryCodeNotifier.dispose();
    super.dispose();
  }

  void _switchView(AuthViewType view) {
    if (_currentViewNotifier.value == view) return;
    _phoneController.clear();
    _formKey.currentState?.reset();
    _currentViewNotifier.value = view;
  }

  void _submit(AuthViewType currentView) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final phone = _phoneController.text.trim();
    if (currentView == AuthViewType.phoneLogin) {
      _cubit.login(phone: phone);
    } else {
      _cubit.register(phone: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      bloc:     _cubit,
      listener: _handleState,
      builder: (context, state) {
        final isLoading = state.sendOtpStatus == RequestStatus.loading;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(

            body: SafeArea(
              child: ValueListenableBuilder<AuthViewType>(
                valueListenable: _currentViewNotifier,
                builder: (_, currentView, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Scrollable content ────────────────────────────
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
                                  totalSteps: currentView == AuthViewType.phoneLogin ? 3 : 7,
                                  activeStep: 2,
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
                                  currentView == AuthViewType.phoneLogin
                                      ? 'تسجيل الدخول إلى حسابك'
                                      : 'إنشاء حساب جديد',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:      cs.primary,
                                  ),
                                  textAlign: TextAlign.right,
                                ),

                                Gap(6.h),

                                Text(
                                  currentView == AuthViewType.phoneLogin
                                      ? 'أدخل رقم هاتفك لتسجيل الدخول .'
                                      : 'أدخل رقم هاتفك لتسجيل حسابك في المنصة .',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                  textAlign: TextAlign.right,
                                ),

                                Gap(28.h),

                                // Phone label
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'رقم الجوال',
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

                                Gap(10.h),

                                // Phone field
                                ValueListenableBuilder<String>(
                                  valueListenable: _countryCodeNotifier,
                                  builder: (_, code, __) {
                                    return PhoneField(
                                      controller:  _phoneController,
                                      showHint:    false,
                                      onValidated: (value) {
                                        final phone = (value ?? '').trim();
                                        if (phone.isEmpty) {
                                          return 'يرجى إدخال رقم الهاتف';
                                        }
                                        if (!RegExp(r'^\d{9,15}$').hasMatch(phone)) {
                                          return 'رقم الهاتف غير صحيح';
                                        }
                                        return null;
                                      },
                                      getChosenPhoneCode: (c) =>
                                      _countryCodeNotifier.value = c,
                                    );
                                  },
                                ),

                                Gap(28.h),

                                // Submit button
                                AppButton(
                                  isLoading: isLoading,
                                  title: currentView == AuthViewType.phoneLogin
                                      ? 'دخول'
                                      : 'التالي',
                                  onPressed: () {
                                    if (isLoading) return;
                                    _submit(currentView);
                                  },
                                ),

                                Gap(20.h),

                                // Switch view row
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      // Static text
                                      Text(
                                        currentView == AuthViewType.phoneLogin
                                            ? 'ليس لديك حساب؟'
                                            : 'هل لديك حساب من قبل؟',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.hintColor,
                                        ),
                                      ),

                                      Gap(6.w),

                                      // Link part
                                      GestureDetector(
                                        onTap: () => _switchView(
                                          currentView == AuthViewType.phoneLogin
                                              ? AuthViewType.register
                                              : AuthViewType.phoneLogin,
                                        ),
                                        child: Text(
                                          currentView == AuthViewType.phoneLogin
                                              ? 'إنشاء حساب'
                                              : 'تسجيل الدخول',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color:      cs.primary,
                                            decoration: TextDecoration.underline,
                                            decorationColor: cs.primary,
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),

                                Gap(40.h),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Pinned terms footer ───────────────────────────
                      _TermsFooter(cs: cs, theme: theme),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state.sendOtpStatus == RequestStatus.success) {
      Nav.registerOtp(
        context:     context,
        from:        state.isRegister ? 1 : 2,
        phoneNumber: _phoneController.text.trim(),
        otpCode:     '',
      );
      _cubit.resetSendOtpState();
    }

    if (state.sendOtpStatus == RequestStatus.error) {
      if (mounted) {
        SnackBarBuilder.showFeedBackMessage(
          context,
          state.errorMessage,
          isSuccess: false,
        );
      }
      _cubit.resetSendOtpState();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TermsFooter — pinned at bottom
// "من خلال التسجيل، فإنك [توافق على شروط الخدمة] واتفاقية معالجة البيانات."
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
                onTap: () => _showTerms(context),
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

  void _showTerms(BuildContext context) {
    showModalBottomSheet(
      context:          context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TermsBottomSheet(),
    );
  }
}