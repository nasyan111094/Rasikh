import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../../core/widgets/general_option_card.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart';
import 'widgets/consultation_flow_widgets.dart';

class ConsultationTypeScreen extends StatefulWidget {
  const ConsultationTypeScreen({super.key});

  @override
  State<ConsultationTypeScreen> createState() => _ConsultationTypeScreenState();
}

class _ConsultationTypeScreenState extends State<ConsultationTypeScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ConsultationApplicationCubit>();
    cubit.selectConsultationType(ConsultationType.instant);


  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(
        title: Loc.chooseConsultationType(),
        backIcon: Icons.arrow_back,
        backIconSize: 22,
      ),
      body: SafeArea(
        child: BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
          builder: (context, state) {
            final selectedType = state.selectedConsultationType;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ConsultationFlowSpacing.horizontal,
              ),
              child: Column(
                children: [
                  const ConsultationFlowStepper(activeStep: 2),
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
                          title: Loc.instantConsultations(),
                          subtitle:
                          Loc.instantConsultationsDescription(),
                          subtitleMaxLines: null,
                          isSelected: selectedType == ConsultationType.instant,
                          onTap: () => context
                              .read<ConsultationApplicationCubit>()
                              .selectConsultationType(ConsultationType.instant),
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
                          title: Loc.writtenConsultations(),
                          subtitle:
                          Loc.writtenConsultationsDescription(),
                          subtitleMaxLines: null,
                          isSelected: selectedType == ConsultationType.written,
                          onTap: () => context
                              .read<ConsultationApplicationCubit>()
                              .selectConsultationType(ConsultationType.written),
                        ),
                        OptionCard(
                          value: ConsultationType.scheduled.value,
                          icon: Picture(
                            getAssetIcon("Calendar.svg"),
                            width: 20.h,
                            height: 20.h,
                            color: selectedType == ConsultationType.scheduled
                                ? colorScheme.primary
                                : theme.dividerColor,
                          ),
                          title: Loc.scheduledConsultations(),
                          subtitle: Loc.scheduledConsultationsDescription(),
                          subtitleMaxLines: null,
                          isSelected: selectedType == ConsultationType.scheduled,
                          onTap: () => context
                              .read<ConsultationApplicationCubit>()
                              .selectConsultationType(ConsultationType.scheduled),
                        ),
                      ],
                    ),
                  ),
                  ConsultationBottomButton(
                    text: Loc.next(),
                    onPressed: () {
                      context
                          .read<ConsultationApplicationCubit>()
                          .loadPricingPlans();
                      Nav.consultationDetailsScreen(context);
                    },
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