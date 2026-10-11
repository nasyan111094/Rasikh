
import 'package:rasikh/config/localization/loc_keys.dart';
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

  String? _selectedCityDisplayValue;

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
        Loc.pleaseChooseCityAlt2(),
        isSuccess: false,
      );
      return;
    }

    _cubit.completeProfile(cityDisplayValue: _selectedCityDisplayValue!);
  }


  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<UserCompletionCubit, UserCompletionState>(
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
                      Loc.completeYourProfileTitle(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize:   18.sp,
                        color:      colorScheme.primary,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      Loc.completeProfileSubtitle(),
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
                              _FieldLabel(
                                  label: Loc.fullNameAlt2(),
                                  theme: theme,
                                  isRequired: true),
                              Gap(8.h),
                              NameField(controller: _cubit.fullNameController),

                              Gap(16.h),

                              _FieldLabel(
                                  label: Loc.email(),
                                  theme: theme,
                                  isRequired: true),
                              Gap(8.h),
                              EmailField(controller: _cubit.emailController),

                              Gap(16.h),

                              _FieldLabel(
                                  label: Loc.chooseCityLabel(),
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

                    GradiantButton(
                      processing: isSubmitting,
                      text:       Loc.completeRegistration(),
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

    if (state is CityError) {
      return _CityErrorWidget(
        message:     (state as CityError).message,
        onRetry:     onRetry,
        colorScheme: colorScheme,
        theme:       theme,
      );
    }

    final displayValues =
    cities.map((c) => c.value.toString()).toList(growable: false);

    return SearchableDropdown(
      items:          displayValues,
      hint:           Loc.chooseCityLabel(),
      label:          '',
      enableSearch:   true,
      controller:     cityController,
      prefixIconPath: 'City.svg',
      onChanged: (displayValue) {
        if (displayValue != null && displayValue.isNotEmpty) {
          onCitySelected(displayValue);
        }
      },
      validator: (v) =>
      (v == null || v.isEmpty) ? Loc.pleaseChooseCity() : null,
    );
  }
}


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
              Loc.unableToLoadCities(),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              Loc.retryAgain(),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}