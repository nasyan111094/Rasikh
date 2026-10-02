
import 'package:rasikh/config/localization/loc_keys.dart';
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
                            Loc.qualificationsAndExperience(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color:      colorScheme.primary,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(4.h),

                          Text(
                            Loc.qualificationsSubtitle(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(28.h),


                          Gap(6.h),
                          GeneralField(
                            controller:     _cubit.qualificationsController,
                            hintText:       Loc.writeHereAlt(),
                            textInputType:  TextInputType.multiline,
                            iconPath:       "",
                            label:          Loc.qualificationsAndExperience(),
                            showPreFixIcon: false,
                            maxLines:       6,
                            fieldValidator: (v) =>
                            v!.trim().isEmpty
                                ? Loc.pleaseWriteQualifications()
                                : null,
                          ),

                          Gap(20.h),


                          Gap(6.h),
                          GeneralField(
                            controller:     _cubit.experienceYearsController,
                            hintText:       Loc.tenYearsHint(),
                            textInputType:  TextInputType.number,
                            iconPath:       "Calendar.svg",
                            label:          Loc.yearsOfExperienceRequired(),
                            fieldValidator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return Loc.pleaseWriteYearsOfExperience();
                              }
                              final years = int.tryParse(v.trim());
                              if (years == null || years <= 0) {
                                return Loc.pleaseEnterValidYears();
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

                AppButton(
                  title: Loc.next(),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _cubit.saveQualifications();
                      Nav.registerLawyerSpecialization(context);
                    }
                  },
                ),

                Gap(20.h),

                Center(
                  child: Text.rich(
                    TextSpan(
                      text: Loc.byRegisteringYou(),
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
                          text: Loc.agreeToTermsOfServiceTrailing(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:      colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: Loc.andDataProcessingAgreement()),
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