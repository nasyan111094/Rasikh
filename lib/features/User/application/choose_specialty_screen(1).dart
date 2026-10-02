import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import '../../../config/navigation/nav.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart' show SubSpecializationModel, SpecializationModel;
import 'widgets/consultation_flow_widgets.dart';
import 'widgets/selection_bottom_sheet.dart';
import 'widgets/specialty_selection_field.dart';

class ChooseSpecialtyScreen extends StatefulWidget {
  const ChooseSpecialtyScreen({Key? key}) : super(key: key);

  @override
  State<ChooseSpecialtyScreen> createState() => _ChooseSpecialtyScreenState();
}

class _ChooseSpecialtyScreenState extends State<ChooseSpecialtyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConsultationApplicationCubit>().resetFlow();
    context.read<ConsultationApplicationCubit>().loadSpecializations();
  }

  void _openMainSpecializationSheet() {
    final cubit = context.read<ConsultationApplicationCubit>();
    showSelectionBottomSheet(
      context: context,
      builder: (_) => BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
        builder: (_, state) => SelectionBottomSheet<SpecializationModel>(
          title: Loc.chooseMainSpecialization(),
          searchHint: Loc.searchMainSpecializationHint(),
          items: state.specializations,
          emptyIcon: Icons.account_balance_outlined,
          emptyTitle: Loc.noSpecializationsAvailable(),
          emptyMessage: Loc.specializationsEmptyMessage(),
          selectedId: state.selectedSpecialization?.id,
          isLoading:
              state.specializationsStatus == ConsultationStatus.loading ||
                  state.specializationsStatus == ConsultationStatus.initial,
          errorMessage:
              state.specializationsStatus == ConsultationStatus.failure
                  ? state.specializationsError ?? Loc.somethingWentWrong()
                  : null,
          onRetry: cubit.loadSpecializations,
          itemId: (s) => s.id,
          itemName: (s) => s.name,
          onConfirm: cubit.selectSpecialization,
        ),
      ),
    );
  }

  void _openSubSpecializationSheet(ConsultationState state) {
    final specialization = state.selectedSpecialization;
    if (specialization == null) return;
    final cubit = context.read<ConsultationApplicationCubit>();
    showSelectionBottomSheet(
      context: context,
      builder: (_) => SelectionBottomSheet<SubSpecializationModel>(
        title: Loc.chooseSubSpecializationAlt(),
        searchHint: Loc.searchSubSpecializationHint(),
        items: specialization.subSpecializations,
        emptyIcon: Icons.account_tree_outlined,
        emptyTitle: Loc.noSubSpecializationsTitle(),
        emptyMessage: Loc.noSubSpecializationsMessage(),
        selectedId: state.selectedSubSpecializations.isEmpty
            ? null
            : state.selectedSubSpecializations.first.id,
        itemId: (s) => s.id,
        itemName: (s) => s.name,
        onConfirm: cubit.selectSubSpecialization,
      ),
    );
  }

  void _openLawsuitTypeSheet(ConsultationState state) {
    if (state.selectedSubSpecializations.isEmpty) return;
    final cubit = context.read<ConsultationApplicationCubit>();
    showSelectionBottomSheet(
      context: context,
      builder: (_) => SelectionBottomSheet<SubSpecializationModel>(
        title: Loc.chooseLawsuitType(),
        searchHint: Loc.searchLawsuitTypeHint(),
        items: state.availableLawsuitTypes,
        emptyIcon: Icons.gavel_rounded,
        emptyTitle: Loc.noLawsuitTypesTitle(),
        emptyMessage: Loc.noLawsuitTypesMessage(),
        selectedId: state.selectedLawsuitType?.id,
        itemId: (s) => s.id,
        itemName: (s) => s.name,
        onConfirm: cubit.selectLawsuitType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: GeneralAppBar(
          title: Loc.chooseSpecialtyTitle(),
          backIcon: Icons.arrow_back,
          backIconSize: 22,
        ),
        body: BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ConsultationFlowSpacing.horizontal,
              ),
              child: Column(
                children: [
                  const ConsultationFlowStepper(activeStep: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SpecialtySelectionField(
                            label: Loc.mainSpecializationLabel(),
                            hint: Loc.chooseMainSpecialization(),
                            value: state.selectedSpecialization?.name,
                            onTap: _openMainSpecializationSheet,
                          ),
                          Gap(ConsultationFlowSpacing.fieldGap),
                          SpecialtySelectionField(
                            label: Loc.subSpecialization(),
                            hint: Loc.chooseSubSpecializationAlt(),
                            value: state.selectedSubSpecializations.isEmpty
                                ? null
                                : state.selectedSubSpecializations.first.name,
                            onTap: () => _openSubSpecializationSheet(state),
                          ),
                          Gap(ConsultationFlowSpacing.fieldGap),
                          SpecialtySelectionField(
                            label: Loc.lawsuitTypeLabel(),
                            hint: Loc.chooseLawsuitType(),
                            value: state.selectedLawsuitType?.name,
                            onTap: () => _openLawsuitTypeSheet(state),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ConsultationBottomButton(
                    text: Loc.next(),
                    onPressed: state.canProceedFromSpecialty
                        ? () => Nav.selectConsulationType(context)
                        : null,
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
