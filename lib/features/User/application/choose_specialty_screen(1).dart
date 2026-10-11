// ─────────────────────────────────────────────────────────────────────────────
// choose_specialty_screen.dart  (Step 1)
//
// New flow (per /specializations/active):
//  • SearchableDropdown #1 → تخصص رئيسي واحد (single — مطلوب)
//  • SearchableDropdown #2 → تخصص فرعي واحد (single, تابع للرئيسي — اختياري)
//  • Chips متعددة → الدعاوى (lawsuitTypes التابعة للفرعي، multi — اختياري)
//  • التالي مفعّل عند اختيار الرئيسي فقط
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/fields/drop_down_field.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../core/widgets/auth_stepper.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/general_app_bar.dart';
import '../../../core/widgets/no_data_widget.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart'
    show SpecializationModel, SubSpecializationModel;

class ChooseSpecialtyScreen extends StatefulWidget {
  const ChooseSpecialtyScreen({Key? key}) : super(key: key);

  @override
  State<ChooseSpecialtyScreen> createState() => _ChooseSpecialtyScreenState();
}

class _ChooseSpecialtyScreenState extends State<ChooseSpecialtyScreen> {
  final TextEditingController _mainController = TextEditingController();
  final TextEditingController _subController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ConsultationApplicationCubit>().resetFlow();
    context.read<ConsultationApplicationCubit>().loadSpecializations();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _subController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<ConsultationApplicationCubit>().loadSpecializations();
  }

  /// All mains are visible — sub-specializations are optional so mains
  /// without subs must stay selectable.
  List<SpecializationModel> _visibleMains(ConsultationState state) =>
      List.of(state.specializations);

  void _syncControllers(ConsultationState state) {
    final mainName = state.selectedSpecialization?.name ?? '';
    if (_mainController.text != mainName) _mainController.text = mainName;
    final subName = state.selectedSubSpecialization?.name ?? '';
    if (_subController.text != subName) _subController.text = subName;
  }

  void _onMainChanged(String name, List<SpecializationModel> mains) {
    final cubit = context.read<ConsultationApplicationCubit>();
    final match = mains.firstWhere(
      (s) => s.name == name,
      orElse: () => mains.first,
    );
    final hadSub =
        cubit.state.selectedSubSpecializations.isNotEmpty;
    // Selecting a main clears sub + lawsuits (handled in cubit).
    cubit.selectSpecialization(match);
    setState(() => _subController.clear());
    if (hadSub && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم تغيير التخصص الرئيسي — أعد اختيار الفرعي والدعاوى')),
      );
    }
  }

  void _onSubChanged(String name, SpecializationModel main) {
    final cubit = context.read<ConsultationApplicationCubit>();
    final match = main.subSpecializations.firstWhere(
      (s) => s.name == name,
      orElse: () => main.subSpecializations.first,
    );
    cubit.selectSubSpecialization(match);
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
            _syncControllers(state);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AuthStepperWidget(activeStep: 1, totalSteps: 5),
                  Gap(20.h),
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
            SizedBox(
              height: 500.h,
              child: ErrorStateWidget(
                title: state.specializationsError ?? 'حدث خطأ ما',
                actionLabel: "إعادة المحاوله",
                onAction: () => context
                    .read<ConsultationApplicationCubit>()
                    .loadSpecializations(),
              ),
            ),
          ],
        );
      default:
        return _buildDropdowns(theme, state);
    }
  }

  Widget _buildDropdowns(ThemeData theme, ConsultationState state) {
    final mains = _visibleMains(state);

    if (mains.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          const NoDataWidget(
            icon: Icons.search_off_rounded,
            title: 'لم يتم العثور على نتائج',
            message: 'لا توجد تخصصات نشطة حالياً',
          ),
        ],
      );
    }

    final selectedMain = state.selectedSpecialization;
    // Re-resolve main from fresh list so subs/lawsuits stay in sync.
    final resolvedMain = selectedMain == null
        ? null
        : mains.where((m) => m.id == selectedMain.id).firstOrNull;
    final subs = resolvedMain?.subSpecializations ?? const <SubSpecializationModel>[];
    final lawsuits = state.availableLawsuitTypes;
    final selectedLawsuits = state.selectedLawsuitTypeIds.toSet();
    final hasSub = state.selectedSubSpecialization != null;
    // Sub-specializations and lawsuits are optional — the step is
    // complete as soon as the main specialization is chosen.
    final step = resolvedMain == null ? 0 : 3;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _StepsHeader(currentStep: step),
        Gap(14.h),

        // ── 1) التخصص الرئيسي (واحد) ───────────────────────────────
        _StepCard(
          number: 1,
          title: 'التخصص الرئيسي',
          subtitle: 'اختر تخصصاً واحداً فقط',
          done: resolvedMain != null,
          child: SearchableDropdown(
            items: mains.map((m) => m.name).toList(),
            hint: 'ابحث واختر التخصص الرئيسي',
            label: '',
            enableSearch: true,
            controller: _mainController,
            showPrefixIcon: false,
            onChanged: (v) => _onMainChanged(v, mains),
          ),
        ),

        // ── 2) التخصص الفرعي (واحد) ────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: resolvedMain == null
              ? const SizedBox(width: double.infinity, height: 0)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(12.h),
                    _StepCard(
                      number: 2,
                      title: 'التخصص الفرعي داخل "${resolvedMain.name}"',
                      subtitle: 'اختر تخصصاً واحداً فقط (اختياري)',
                      done: hasSub,
                      child: SearchableDropdown(
                        items: subs.map((s) => s.name).toList(),
                        hint: 'ابحث واختر التخصص الفرعي',
                        label: '',
                        enableSearch: true,
                        controller: _subController,
                        showPrefixIcon: false,
                        onChanged: (v) => _onSubChanged(v, resolvedMain),
                      ),
                    ),
                  ],
                ),
        ),

        // ── 3) الدعاوى (أكثر من واحدة) ─────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: !hasSub
              ? const SizedBox(width: double.infinity, height: 0)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(12.h),
                    _StepCard(
                      number: 3,
                      title:
                          'الدعاوى داخل "${state.selectedSubSpecialization!.name}"',
                      subtitle: lawsuits.isEmpty
                          ? 'لا توجد دعاوى — يمكنك المتابعة'
                          : 'يمكن اختيار أكثر من دعوة (اختياري)',
                      done: true,
                      trailing: lawsuits.isEmpty
                          ? null
                          : _CountBadge(
                              selected: selectedLawsuits.length,
                              total: lawsuits.length),
                      child: lawsuits.isEmpty
                          ? Text(
                              'لا توجد دعاوى مضافة لهذا التخصص الفرعي — يمكنك المتابعة مباشرة.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: lawsuits.map((lawsuit) {
                                final selected =
                                    selectedLawsuits.contains(lawsuit.id);
                                return GestureDetector(
                                  onTap: () => context
                                      .read<
                                          ConsultationApplicationCubit>()
                                      .toggleLawsuitType(lawsuit.id),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: selected
                                            ? theme.colorScheme.primary
                                            : theme.dividerColor
                                                .withOpacity(0.3),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (selected) ...[
                                          Icon(Icons.check_rounded,
                                              size: 13,
                                              color: theme.colorScheme
                                                  .onPrimary),
                                          Gap(4.w),
                                        ],
                                        Text(
                                          lawsuit.name,
                                          style: theme
                                              .textTheme.labelLarge
                                              ?.copyWith(
                                            color: selected
                                                ? theme.colorScheme.onPrimary
                                                : theme.colorScheme.onSurface,
                                            fontWeight: selected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
        ),

        // ── Validation hint ─────────────────────────────────────────
        if (!state.canProceedFromSpecialty) ...[
          Gap(8.h),
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 15, color: theme.colorScheme.error),
              Gap(6.w),
              Expanded(
                child: Text(
                  _validationMessage(
                      resolvedMain != null, hasSub, lawsuits, selectedLawsuits),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
        Gap(8.h),
      ],
    );
  }

  String _validationMessage(bool hasMain, bool hasSub,
      List<dynamic> lawsuits, Set<String> selectedLawsuits) {
    if (!hasMain) return 'اختر تخصصك الرئيسي من القائمة بالأعلى';
    return '';
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
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
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
          padding:
              WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
// Step widgets (same guided language as the lawyer selector)
// ─────────────────────────────────────────────────────────────────────────────

class _StepsHeader extends StatelessWidget {
  /// 0 = main, 1 = sub, 2 = lawsuits, 3 = complete.
  final int currentStep;
  const _StepsHeader({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['الرئيسي', 'الفرعي', 'الدعاوى'];
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          Expanded(
              child: _StepPill(
                  index: i, label: labels[i], currentStep: currentStep)),
          if (i < labels.length - 1) Gap(6.w),
        ],
      ],
    );
  }
}

class _StepPill extends StatelessWidget {
  final int index;
  final String label;
  final int currentStep;
  const _StepPill(
      {required this.index, required this.label, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = currentStep > index;
    final active = currentStep == index;
    final bg = done
        ? cs.primary
        : active
            ? cs.primary.withOpacity(0.12)
            : Theme.of(context).dividerColor.withOpacity(0.15);
    final fg = done
        ? cs.onPrimary
        : active
            ? cs.primary
            : Theme.of(context).hintColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (done || active)
              ? cs.primary
              : Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done)
            Icon(Icons.check_rounded, size: 14, color: fg)
          else
            Text('${index + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                    )),
          Gap(4.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final bool done;
  final Widget? trailing;
  final Widget child;
  const _StepCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done ? cs.primary : theme.dividerColor.withOpacity(0.35),
          width: done ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? cs.primary : Colors.transparent,
                  border: Border.all(
                    color: done ? cs.primary : cs.outlineVariant,
                    width: 1.6,
                  ),
                ),
                child: done
                    ? Icon(Icons.check_rounded, size: 15, color: cs.onPrimary)
                    : Text('$number',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.hintColor,
                        )),
              ),
              Gap(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: done
                              ? cs.primary
                              : theme.textTheme.titleSmall?.color,
                        )),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        )),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          Gap(12.h),
          child,
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int selected;
  final int total;
  const _CountBadge({required this.selected, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$selected / $total',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
