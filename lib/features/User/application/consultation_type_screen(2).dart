// ─────────────────────────────────────────────────────────────────────────────
// consultation_type_screen.dart  (Step 2)
// UI unchanged — now driven by ConsultationCubit
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../../core/widgets/auth_stepper.dart';
import '../../../core/widgets/general_option_card.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart';

class ConsultationTypeScreen extends StatelessWidget {
  const ConsultationTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(title: "إختر نوع الإستشارة"),
      body: SafeArea(
        child: BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
          builder: (context, state) {
            final selectedType = state.selectedConsultationType;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child:
                    AuthStepperWidget(activeStep: 2, totalSteps: 5),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        OptionCard(
                          value: ConsultationType.instant.value,
                          icon: Picture(
                            getAssetIcon("Immediately.svg"),
                            width: 20.h,
                            height: 20.h,
                            color: selectedType == ConsultationType.instant
                                ? colorScheme.primary
                                : theme.dividerColor,
                          ),
                          title: 'استشارات فورية',
                          subtitle:
                          'ادفع الآن وسيتم توصيلك بأقرب محامٍ متاح في تخصصك.',
                          isSelected:
                          selectedType == ConsultationType.instant,
                          onTap: () => context
                              .read<ConsultationApplicationCubit>()
                              .selectConsultationType(
                              ConsultationType.instant),
                        ),
                        OptionCard(
                          value: ConsultationType.written.value,
                          icon: Picture(
                            getAssetIcon("chat.svg"),
                            width: 20.h,
                            height: 20.h,
                            color: selectedType == ConsultationType.written
                                ? colorScheme.primary
                                : theme.dividerColor,
                          ),
                          title: 'استشارات كتابية',
                          subtitle:
                          'اكتب تفاصيلك وأرفق مستنداتك، ويتواصل معك المحامي في المحادثة.',
                          isSelected:
                          selectedType == ConsultationType.written,
                          onTap: () => context
                              .read<ConsultationApplicationCubit>()
                              .selectConsultationType(
                              ConsultationType.written),
                        ),
                        OptionCard(
                          value: ConsultationType.scheduled.value,
                          icon: Picture(
                            getAssetIcon("Calendar.svg"),
                            width: 20.h,
                            height: 20.h,
                            color:
                            selectedType == ConsultationType.scheduled
                                ? colorScheme.primary
                                : theme.dividerColor,
                          ),
                          title: 'استشارات مجدولة',
                          subtitle:
                          'اختر موعدًا محددًا للتواصل صوتيًا أو بالفيديو.',
                          isSelected:
                          selectedType == ConsultationType.scheduled,
                          onTap: () => context
                              .read<ConsultationApplicationCubit>()
                              .selectConsultationType(
                              ConsultationType.scheduled),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0.w),
                    child: SizedBox(
                      height: 48.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.h),
                          ),
                        ),
                        onPressed: () {
                          // Load pricing for the selected type
                          context
                              .read<ConsultationApplicationCubit>()
                              .loadPricingPlans();
                          Nav.consultationDetailsScreen(context);
                        },
                        child: Text(
                          'التالي',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}