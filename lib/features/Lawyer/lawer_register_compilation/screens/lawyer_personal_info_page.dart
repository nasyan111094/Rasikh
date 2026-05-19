// ─────────────────────────────────────────────────────────────────────────────
// lawyer_completion/pages/lawyer_personal_info_page.dart
//
// Step 1 – Personal Data (البيانات الشخصية)
// UI is 100% identical to Sign_Up_Screen__Personal_Data_.png
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/core/widgets/fields/drop_down_field.dart';
import 'package:rasikh/core/widgets/fields/email_field.dart';
import 'package:rasikh/core/widgets/fields/name_field.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/bottom_sheets/terms_conditions_button_sheet.dart';
import '../../../../config/navigation/nav.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../cubit/lawyer_registeration_complation_cubit.dart';
import '../cubit/lawyer_registeration_complation_state.dart';

class LawyerPersonalInfoPage extends StatefulWidget {
  const LawyerPersonalInfoPage({super.key});

  @override
  State<LawyerPersonalInfoPage> createState() =>
      _LawyerPersonalInfoPageState();
}

class _LawyerPersonalInfoPageState extends State<LawyerPersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late final LawyerCompletionCubit _cubit;

  String? _selectedCityKey;
  File?   _profilePhoto;
  final   _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LawyerCompletionCubit>()..fetchCities();
  }

  Future<void> _pickProfilePhoto() async {
    final picked = await _picker.pickImage(
      source:       ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _profilePhoto = File(picked.path));
    }
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

                // ── Progress stepper ──────────────────────────────────────
                const AuthStepperWidget(totalSteps: 7, activeStep: 4),

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

                          // ── Page title ───────────────────────────────────
                          Text(
                            "البيانات الشخصية",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color:      colorScheme.primary,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(4.h),

                          Text(
                            "نحتاج بعض البيانات الشخصية لتفعيل حسابك بالكامل.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(24.h),

                          // ── Profile photo picker ─────────────────────────
                          Center(
                            child: GestureDetector(
                              onTap: _pickProfilePhoto,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Avatar circle
                                  CircleAvatar(
                                    radius:          48.w,
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    backgroundImage: _profilePhoto != null
                                        ? FileImage(_profilePhoto!)
                                        : null,
                                    child: _profilePhoto == null
                                        ? ClipOval(
                                      child: Image.asset(
                                        "assets/images/avatar.png",
                                        width:  96.w,
                                        height: 96.w,
                                        fit:    BoxFit.cover,
                                      ),
                                    )
                                        : null,
                                  ),
                                  // Camera badge
                                  Positioned(
                                    bottom: 0,
                                    right:   0,
                                    child: Container(
                                      width:      28.w,
                                      height:     28.w,
                                      decoration: BoxDecoration(
                                        color:       colorScheme.primary,
                                        shape:       BoxShape.circle,
                                        border: Border.all(
                                          color: colorScheme.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Picture(getAssetIcon("Camera.svg") , color: Colors.white,),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Gap(28.h),

                          // ── Full name ────────────────────────────────────
                          _FieldLabel(label: "الإسم كامل", theme: theme , isRequired: true ,),
                          Gap(10.h),
                          NameField(controller: _cubit.fullNameController),

                          Gap(30.h),

                          // ── Email ────────────────────────────────────────
                          _FieldLabel(label: "البريد الإلكتروني", theme: theme, isRequired: true ,),
                          Gap(10.h),
                          EmailField(controller: _cubit.emailController),

                          Gap(30.h),

                          // ── City dropdown ────────────────────────────────
                          _FieldLabel(label: "إختر المدينة", theme: theme, isRequired: true ,),
                          Gap(6.h),

                          BlocBuilder<LawyerCompletionCubit,
                              LawyerCompletionState>(
                            builder: (context, cityState) {
                              if (cityState is LawyerCityLoading) {
                                return SizedBox(
                                  height: 56.h,
                                  child: Center(
                                    child: SizedBox(
                                      width:  20.w,
                                      height: 20.w,
                                      child:  CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:       colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (cityState is LawyerCityError) {
                                return _CityErrorWidget(
                                  message: cityState.message,
                                  onRetry: _cubit.fetchCities,
                                  colorScheme: colorScheme,
                                  theme:      theme,
                                );
                              }

                              final cities = cityState is LawyerCityLoaded
                                  ? cityState.cities
                                  : <dynamic>[];

                              final displayValues = cities
                                  .map((c) => c.value.toString())
                                  .toList()
                                  .cast<String>();

                              return SearchableDropdown(
                                items:          displayValues,
                                hint:           'إختر المدينة',
                                label:          '',
                                enableSearch:   true ,
                                controller:     TextEditingController(),
                                prefixIconPath: 'City.svg',
                                onChanged: (displayValue) {
                                  final match = cities
                                      .cast<dynamic>()
                                      .firstWhere(
                                        (c) => c.value == displayValue,
                                    orElse: () => null as dynamic,
                                  );
                                  if (match != null) {
                                    _selectedCityKey = match.key;
                                  }
                                },
                                validator: (v) =>
                                v == null ? 'الرجاء اختيار المدينة' : null,
                              );
                            },
                          ),

                          Gap(32.h),

                          // ── Submit button ────────────────────────────────
                          AppButton(
                            title: "التالي",

                            onPressed: () {
                              if (_formKey.currentState!.validate()) {

                               if ( _selectedCityKey == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBarBuilder.showFeedBackMessage(
                                        context,
                                        "يرجي إختيار المدينه",
                                        isSuccess: false,
                                      ));
                                }

                                // Persist photo if picked
                                if (_profilePhoto != null) {
                                  _cubit.formData = _cubit.formData.copyWith(
                                    photo: _profilePhoto,
                                  );
                                }
                                _cubit.savePersonalInfo(
                                  cityKey: _selectedCityKey!,
                                );
                                Nav.licensePracticeScreen(context);
                              }
                            },
                          ),

                          Gap(24.h),

                          // ── Terms note ───────────────────────────────────
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
                                  const TextSpan(
                                      text: "واتفاقية معالجة البيانات."),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final bool isRequired ;
  const _FieldLabel({required this.label, required this.theme , this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color:      theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
        ),
        Gap(5.w) ,
        Text(
          "*",
          style: theme.textTheme.bodyMedium?.copyWith(
            color:      theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _CityErrorWidget extends StatelessWidget {
  final String     message;
  final VoidCallback onRetry;
  final ColorScheme  colorScheme;
  final ThemeData    theme;

  const _CityErrorWidget({
    required this.message,
    required this.onRetry,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: colorScheme.error.withOpacity(0.4)),
        color:        colorScheme.error.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: colorScheme.error, size: 20.sp),
          Gap(8.w),
          Expanded(
            child: Text(
              'تعذر تحميل المدن',
              style:
              theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text('إعادة',
                style:
                theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}