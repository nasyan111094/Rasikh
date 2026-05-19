// ─────────────────────────────────────────────────────────────────────────────
// lawyer_completion/pages/lawyer_qualifications_page.dart
//
// Step 3 – Qualifications & Experience (المؤهلات والخبرات)
// UI is 100% identical to Sign_Up_Screen__Qualifications_And_Experience_.png
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/core/widgets/fields/gender_field.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/bottom_sheets/terms_conditions_button_sheet.dart';
import '../../../../config/navigation/nav.dart';
import '../cubit/lawyer_registeration_complation_cubit.dart';

class LawyerQualificationsPage extends StatefulWidget {
  const LawyerQualificationsPage({super.key});

  @override
  State<LawyerQualificationsPage> createState() =>
      _LawyerQualificationsPageState();
}

class _LawyerQualificationsPageState extends State<LawyerQualificationsPage> {
  final _formKey = GlobalKey<FormState>();
  late final LawyerCompletionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LawyerCompletionCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(

        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gap(16.h),

                // ── Stepper ─────────────────────────────────────────────
                const AuthStepperWidget(totalSteps: 7, activeStep: 6),

                Gap(16.h),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Logo ────────────────────────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: Picture(
                              getAssetIcon("no_bg_logo.svg"),
                              width:  120.w,
                              height: 48.h,
                            ),
                          ),

                          Gap(12.h),

                          Text(
                            "المؤهلات والخبرات",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color:      colorScheme.primary,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(4.h),

                          Text(
                            "نحتاج المؤهلات والخبرات لتفعيل حسابك بالكامل.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(28.h),

                          // ── Qualifications multiline field ───────────────

                          Gap(6.h),
                          GeneralField(
                            controller:     _cubit.qualificationsController,
                            hintText:       "أكتب هنا ...",
                            textInputType:  TextInputType.multiline,
                            iconPath:       "",
                            label:          "المؤهلات والخبرات",
                            showPreFixIcon: false,
                            maxLines:       6,
                            fieldValidator: (v) =>
                            v!.trim().isEmpty
                                ? "يرجى كتابة مؤهلاتك"
                                : null,
                          ),

                          Gap(20.h),

                          // ── Years of experience ──────────────────────────

                          Gap(6.h),
                          GeneralField(
                            controller:     _cubit.experienceYearsController,
                            hintText:       "10 سنوات",
                            textInputType:  TextInputType.number,
                            iconPath:       "Calendar.svg",
                            label:          "سنوات الخبرة *",
                            fieldValidator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "يرجى كتابة سنوات الخبرة";
                              }
                              final years = int.tryParse(v.trim());
                              if (years == null || years <= 0) {
                                return "يرجى إدخال عدد سنوات صحيح";
                              }
                              return null;
                            },
                          ),

                          Gap(40.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Next button ──────────────────────────────────────────
                AppButton(
                  title: "التالي",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _cubit.saveQualifications();
                      Nav.registerLawyerSpecialization(context);
                    }
                  },
                ),

                Gap(20.h),

                // ── Terms note ───────────────────────────────────────────
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "من خلال التسجيل، فإنك ",
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
                          text: "توافق على شروط الخدمة ",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:      colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: "واتفاقية معالجة البيانات."),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Gap(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Field label helper ────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String    label;
  final ThemeData theme;
  const _FieldLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color:      theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.right,
    );
  }
}