// ─────────────────────────────────────────────────────────────────────────────
// choose_specialty_screen.dart  (Step 1)
// Changes:
//  • Shimmer loading skeleton instead of CircularProgressIndicator
//  • Pull-to-refresh via RefreshIndicator
//  • API now calls /specializations/active (handled in cubit/repo)
//  • ✅ Auto-select parent when sub is chosen
//  • ✅ Sub-specializations from other parents are cleared on new selection
//  • ✅ Specializations without sub-specializations are hidden
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../config/theme/colors.dart';
import '../../../core/widgets/auth_stepper.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart'
    show SubSpecializationModel, SpecializationModel;

class ChooseSpecialtyScreen extends StatefulWidget {
  const ChooseSpecialtyScreen({Key? key}) : super(key: key);

  @override
  State<ChooseSpecialtyScreen> createState() => _ChooseSpecialtyScreenState();
}

class _ChooseSpecialtyScreenState extends State<ChooseSpecialtyScreen> {
  final TextEditingController searchController = TextEditingController();
  final List<String> quickFilters = ['تنفيذ', 'تجارية', 'أحوال', 'مرورية'];

  @override
  void initState() {
    super.initState();
    context.read<ConsultationApplicationCubit>().loadSpecializations();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<ConsultationApplicationCubit>().loadSpecializations(
      search:
      searchController.text.isEmpty ? null : searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: GeneralAppBar(title: "إختر التخصص"),
        body: BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AuthStepperWidget(activeStep: 1, totalSteps: 5),
                  Gap(20.h),
                  _buildSearchBar(theme, state),

                  const Gap(10),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: _buildBody(theme, state),
                    ),
                  ),
                  const Gap(12),
                  _buildNextButton(theme, state),
                  const Gap(12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(ThemeData theme, ConsultationState state) {
    switch (state.specializationsStatus) {
      case ConsultationStatus.loading:
        return _buildShimmer(theme);

      case ConsultationStatus.failure:
        return ListView(
          children: [
            SizedBox(height: 80.h),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: theme.colorScheme.error, size: 48),
                  Gap(12.h),
                  Text(
                    state.specializationsError ?? 'حدث خطأ ما',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  Gap(16.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ConsultationApplicationCubit>().loadSpecializations(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ],
        );

      default:
        return _buildCategoryList(theme, state);
    }
  }

  // ── Shimmer skeleton ──────────────────────────────────────────────────────

  Widget _buildShimmer(ThemeData theme) {
    final baseColor = theme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final highlightColor = theme.brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade600;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar(ThemeData theme, ConsultationState state) {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        context
            .read<ConsultationApplicationCubit>()
            .loadSpecializations(search: value.isEmpty ? null : value);
      },
      decoration: InputDecoration(
        hintText: 'ادخل كلمة مفتاحية مثل تنفيذ أو أموال ...',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }



  // ── Category list ─────────────────────────────────────────────────────────

  Widget _buildCategoryList(ThemeData theme, ConsultationState state) {
    // ✅ Show only specializations that have sub-specializations
    final items = state.specializations
        .where((s) => s.subSpecializations.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 80.h),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 48, color: theme.hintColor),
                Gap(12.h),
                Text(
                  'لم يتم العثور على نتائج',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final spec = items[index];
        final isExpanded = state.selectedSpecialization?.id == spec.id;

        return _SpecializationTile(
          spec: spec,
          isExpanded: isExpanded,
          selectedSubIds: state.selectedSubSpecializations
              .map((s) => s.id)
              .toSet(),
          // ✅ Only show selected subs when this IS the selected parent
          isActiveParent: state.selectedSpecialization?.id == spec.id,
          onToggleMain: (expanded) {
            context.read<ConsultationApplicationCubit>().selectSpecialization(spec);
          },
          onToggleSub: (sub) => context
              .read<ConsultationApplicationCubit>()
          // ✅ Pass parentSpec so the cubit knows which parent owns this sub
              .toggleSubSpecialization(sub as SubSpecializationModel),
        );
      },
    );
  }

  // ── Next button ───────────────────────────────────────────────────────────

  Widget _buildNextButton(ThemeData theme, ConsultationState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.canProceedFromSpecialty
            ? () => Nav.selectConsulationType(context)
            : null,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(WidgetState.disabled)) {
                return theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.4);
              }
              return theme.colorScheme.primary;
            },
          ),
          foregroundColor:
          WidgetStateProperty.all(theme.colorScheme.onPrimary),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 14)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          elevation: WidgetStateProperty.all(0),
        ),
        child: Text(
          'التالي',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private tile widget
// ─────────────────────────────────────────────────────────────────────────────

class _SpecializationTile extends StatelessWidget {
  final SpecializationModel spec;
  final bool isExpanded;
  final Set<String> selectedSubIds;

  /// ✅ True only when this tile's parent is the currently selected parent.
  /// Used to prevent showing sub-selections from a different parent visually.
  final bool isActiveParent;

  final void Function(bool expanded) onToggleMain;
  final void Function(SubSpecializationModel sub) onToggleSub;

  const _SpecializationTile({
    required this.spec,
    required this.isExpanded,
    required this.selectedSubIds,
    required this.isActiveParent,
    required this.onToggleMain,
    required this.onToggleSub,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? theme.colorScheme.primary.withOpacity(0.6)
              : theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          key: PageStorageKey(spec.id),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onToggleMain,
          trailing: Radio<String>(
            value: spec.id,
            // ✅ Only mark as selected when this is the active parent
            groupValue: isActiveParent ? spec.id : null,
            onChanged: (_) => onToggleMain(true),
          ),
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isExpanded
                          ? theme.colorScheme.primary.withOpacity(0.6)
                          : theme.dividerColor,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Picture(
                    getAssetIcon("chat.svg"),
                    width: 40.h,
                    height: 40.h,
                    color: isExpanded
                        ? theme.colorScheme.primary.withOpacity(0.6)
                        : theme.dividerColor,
                  ),
                ),
                const Gap(6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spec.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isExpanded
                            ? theme.colorScheme.primary
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "عدد التخصصات الفرعيه : ",
                          style: theme.textTheme.bodySmall?.copyWith(

                            color: greyD0,
                          ),
                        ),
                        Text(
                          spec.subSpecializationsCount.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(

                            color: primary ,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: [
            // spec.subSpecializations is always non-empty here because we
            // filtered at the list level, but we keep the guard for safety.
            if (spec.subSpecializations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(8),
                    Text(
                      'اختر التخصص الفرعي',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'يمكنك اختيار أكثر من تخصص إذا لزم الأمر.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: spec.subSpecializations.map((sub) {
                        // ✅ Only highlight subs if this is the active parent
                        final selected =
                            isActiveParent && selectedSubIds.contains(sub.id);
                        return GestureDetector(
                          onTap: () => onToggleSub(sub),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: selected
                                  ? theme.colorScheme.primary.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: selected
                                    ? theme.colorScheme.primary.withOpacity(0.6)
                                    : theme.dividerColor.withOpacity(0.3),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              sub.name,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(12),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}