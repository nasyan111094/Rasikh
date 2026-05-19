// ─────────────────────────────────────────────────────────────────────────────
// user_completion/pages/user_completion_page.dart
//
// Entry page for the user profile-completion flow.
// Replace the TODO sections with your real user form fields.
// The shell (stepper, layout, button) follows the same pattern as the
// lawyer completion pages so the UI stays consistent.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/core/widgets/fields/email_field.dart';
import 'package:rasikh/core/widgets/fields/name_field.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/snack_bar.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/navigation/nav.dart';
import '../bloc/user_completion_cubit.dart';
import '../bloc/user_completion_state.dart';

class UserCompletionPage extends StatefulWidget {
  const UserCompletionPage({super.key});

  @override
  State<UserCompletionPage> createState() => _UserCompletionPageState();
}

class _UserCompletionPageState extends State<UserCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  late final UserCompletionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<UserCompletionCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<UserCompletionCubit, UserCompletionState>(
        listener: (context, state) {
          if (state is UserProfileCompleted) {
            Nav.layout(context);
          } else if (state is UserCompletionError) {
            SnackBarBuilder.showFeedBackMessage(
                context, state.message, isSuccess: false);
          }
        },
        builder: (context, state) {
          final isLoading = state is UserProfileSubmitting;

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(40.h),
                    Picture(getAssetIcon("no_bg_logo.svg"),
                        width: 120.w, height: 50.h),
                    Gap(20.h),
                    Text(
                      "أكمل ملفك الشخصي",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize:   18.sp,
                        color:      colorScheme.primary,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      "نحتاج بعض البيانات لتفعيل حسابك بالكامل.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color:    theme.hintColor,
                      ),
                    ),
                    Gap(8.h),
                    const AuthStepperWidget(totalSteps: 3, activeStep: 3),
                    Gap(24.h),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Full name ──────────────────────────
                              Text("الاسم الكامل",
                                  style: theme.textTheme.bodyMedium),
                              Gap(8.h),
                              NameField(
                                  controller:
                                  _cubit.fullNameController),

                              Gap(16.h),

                              // ── Email ──────────────────────────────
                              Text("البريد الإلكتروني",
                                  style: theme.textTheme.bodyMedium),
                              Gap(8.h),
                              EmailField(
                                  controller:
                                  _cubit.emailController),

                              // TODO: add more user-specific fields here
                            ],
                          ),
                        ),
                      ),
                    ),
                    GradiantButton(
                      processing: isLoading,
                      text:       "إكمال التسجيل",
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          _cubit.completeProfile();
                        }
                      },
                    ),
                    Gap(20.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}