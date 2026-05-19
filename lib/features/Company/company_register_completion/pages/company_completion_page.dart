// ─────────────────────────────────────────────────────────────────────────────
// company_completion/pages/company_completion_page.dart
//
// Entry page for the company (law firm) profile-completion flow.
// Add more steps / pages as needed following the lawyer pattern.
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
import '../bloc/company_completion_cubit.dart';
import '../bloc/company_completion_state.dart';

class CompanyCompletionPage extends StatefulWidget {
  const CompanyCompletionPage({super.key});

  @override
  State<CompanyCompletionPage> createState() =>
      _CompanyCompletionPageState();
}

class _CompanyCompletionPageState extends State<CompanyCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  late final CompanyCompletionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CompanyCompletionCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CompanyCompletionCubit, CompanyCompletionState>(
        listener: (context, state) {
          if (state is CompanyProfileCompleted) {
            Nav.layout(context);
          } else if (state is CompanyCompletionError) {
            SnackBarBuilder.showFeedBackMessage(
                context, state.message, isSuccess: false);
          }
        },
        builder: (context, state) {
          final isLoading = state is CompanyProfileSubmitting;

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
                      "بيانات شركة المحاماة",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize:   18.sp,
                        color:      colorScheme.primary,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      "نحتاج بيانات الشركة لتفعيل حسابك بالكامل.",
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
                              // ── Company name ───────────────────────
                              Text("اسم الشركة",
                                  style: theme.textTheme.bodyMedium),
                              Gap(8.h),
                              NameField(
                                  controller:
                                  _cubit.companyNameController),

                              Gap(16.h),

                              // ── Representative ─────────────────────
                              Text("اسم المفوّض",
                                  style: theme.textTheme.bodyMedium),
                              Gap(8.h),
                              NameField(
                                  controller: _cubit
                                      .representativeNameController),

                              Gap(16.h),

                              // ── Commercial reg ─────────────────────
                              Text("رقم السجل التجاري",
                                  style: theme.textTheme.bodyMedium),
                              Gap(8.h),
                              TextFormField(
                                controller:   _cubit.commercialRegController,
                                keyboardType: TextInputType.number,
                                validator: (v) => v!.isEmpty
                                    ? 'أدخل رقم السجل التجاري'
                                    : null,
                                decoration: const InputDecoration(
                                  hintText: 'رقم السجل التجاري',
                                ),
                              ),

                              Gap(16.h),

                              // ── Email ──────────────────────────────
                              Text("البريد الإلكتروني",
                                  style: theme.textTheme.bodyMedium),
                              Gap(8.h),
                              EmailField(
                                  controller:
                                  _cubit.emailController),

                              // TODO: add more company-specific fields
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