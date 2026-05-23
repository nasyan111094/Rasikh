// ─────────────────────────────────────────────────────────────────────────────
// user_completion/pages/user_completion_page.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/core/widgets/fields/drop_down_field.dart';
import 'package:rasikh/core/widgets/fields/email_field.dart';
import 'package:rasikh/core/widgets/fields/name_field.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/snack_bar.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/models/city_model.dart';
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

  /// The Arabic display value chosen in the dropdown (e.g. "الرياض").
  /// This is sent directly to the API — no key mapping required.
  String? _selectedCityDisplayValue;

  /// Stable controller for the city dropdown so it isn't recreated on every
  /// build.  Disposed in [dispose].
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<UserCompletionCubit>()..fetchCities();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Extracts the city list from whichever state is current.
  /// Returns an empty list for states that carry no cities (e.g. CityLoading).
  List<CityEnumModel> _citiesFrom(UserCompletionState state) {
    if (state is CityLoaded)       return state.cities;
    if (state is ProfileSubmitting) return state.cities;
    if (state is ProfileError)      return state.cities;
    return const [];
  }

  void _onSubmit() {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    if (_selectedCityDisplayValue == null) {
      SnackBarBuilder.showFeedBackMessage(
        context,
        'يرجى اختيار المدينة',
        isSuccess: false,
      );
      return;
    }

    _cubit.completeProfile(cityDisplayValue: _selectedCityDisplayValue!);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<UserCompletionCubit, UserCompletionState>(
        // ── Side-effects ───────────────────────────────────────────────────
        listenWhen: (_, current) =>
        current is ProfileCompleted || current is ProfileError,
        listener: (context, state) {
          if (state is ProfileCompleted) {
            Nav.account_type_screen(context);
          } else if (state is ProfileError) {
            SnackBarBuilder.showFeedBackMessage(
              context,
              state.message,
              isSuccess: false,
            );
          }
        },
        // ── UI ─────────────────────────────────────────────────────────────
        builder: (context, state) {
          final isSubmitting = state is ProfileSubmitting;

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(40.h),
                    Picture(getAssetIcon('no_bg_logo.svg'),
                        width: 120.w, height: 50.h),
                    Gap(20.h),
                    Text(
                      'أكمل ملفك الشخصي',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize:   18.sp,
                        color:      colorScheme.primary,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      'نحتاج بعض البيانات لتفعيل حسابك بالكامل.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color:    theme.hintColor,
                      ),
                    ),
                    Gap(8.h),
                    const AuthStepperWidget(totalSteps: 3, activeStep: 3),
                    Gap(24.h),

                    // ── Scrollable form ────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full name
                              _FieldLabel(
                                  label: 'الإسم الكامل',
                                  theme: theme,
                                  isRequired: true),
                              Gap(8.h),
                              NameField(controller: _cubit.fullNameController),

                              Gap(16.h),

                              // Email
                              _FieldLabel(
                                  label: 'البريد الإلكتروني',
                                  theme: theme,
                                  isRequired: true),
                              Gap(8.h),
                              EmailField(controller: _cubit.emailController),

                              Gap(16.h),

                              // City dropdown
                              _FieldLabel(
                                  label: 'اختر المدينة',
                                  theme: theme,
                                  isRequired: true),
                              Gap(6.h),
                              _CityDropdown(
                                state:          state,
                                cities:         _citiesFrom(state),
                                cityController: _cityController,
                                colorScheme:    colorScheme,
                                theme:          theme,
                                selectedValue:  _selectedCityDisplayValue,
                                onCitySelected: (displayValue) {
                                  setState(() {
                                    _selectedCityDisplayValue = displayValue;
                                  });
                                },
                                onRetry: _cubit.fetchCities,
                              ),

                              Gap(32.h),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Submit button ──────────────────────────────────────
                    GradiantButton(
                      processing: isSubmitting,
                      text:       'إكمال التسجيل',
                      onTap:      _onSubmit,
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

// ─────────────────────────────────────────────────────────────────────────────
// City dropdown — extracted widget for clarity
// ─────────────────────────────────────────────────────────────────────────────

class _CityDropdown extends StatelessWidget {
  final UserCompletionState      state;
  final List<CityEnumModel>      cities;
  final TextEditingController    cityController;
  final ColorScheme              colorScheme;
  final ThemeData                theme;
  final String?                  selectedValue;
  final ValueChanged<String>     onCitySelected;
  final VoidCallback             onRetry;

  const _CityDropdown({
    required this.state,
    required this.cities,
    required this.cityController,
    required this.colorScheme,
    required this.theme,
    required this.selectedValue,
    required this.onCitySelected,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // ── Loading spinner ────────────────────────────────────────────────────
    if (state is CityLoading) {
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

    // ── Error with retry ───────────────────────────────────────────────────
    if (state is CityError) {
      return _CityErrorWidget(
        message:     (state as CityError).message,
        onRetry:     onRetry,
        colorScheme: colorScheme,
        theme:       theme,
      );
    }

    // ── Dropdown (CityLoaded | ProfileSubmitting | ProfileError) ───────────
    //
    // The cubit always injects the cached city list into ProfileSubmitting and
    // ProfileError, so `cities` is never empty once loading has succeeded.
    final displayValues =
    cities.map((c) => c.value.toString()).toList(growable: false);

    return SearchableDropdown(
      items:          displayValues,
      hint:           'اختر المدينة',
      label:          '',
      enableSearch:   true,
      controller:     cityController,
      prefixIconPath: 'City.svg',
      onChanged: (displayValue) {
        // The API accepts the Arabic city name directly; no key lookup needed.
        if (displayValue != null && displayValue.isNotEmpty) {
          onCitySelected(displayValue);
        }
      },
      validator: (v) =>
      (v == null || v.isEmpty) ? 'الرجاء اختيار المدينة' : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String    label;
  final ThemeData theme;
  final bool      isRequired;

  const _FieldLabel({
    required this.label,
    required this.theme,
    this.isRequired = false,
  });

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
        if (isRequired) ...[
          Gap(4.w),
          Text(
            '*',
            style: theme.textTheme.bodyMedium?.copyWith(
              color:      theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _CityErrorWidget extends StatelessWidget {
  final String       message;
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
        border: Border.all(color: colorScheme.error.withOpacity(0.4)),
        color:  colorScheme.error.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: colorScheme.error, size: 20.sp),
          Gap(8.w),
          Expanded(
            child: Text(
              'تعذر تحميل المدن',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'إعادة المحاولة',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}