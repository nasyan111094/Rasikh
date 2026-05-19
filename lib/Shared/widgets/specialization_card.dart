import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

import '../../features/Lawyer/lawer_register_compilation/cubit/lawyer_registeration_complation_cubit.dart';
import '../../features/Lawyer/lawer_register_compilation/cubit/lawyer_registeration_complation_state.dart';
import '../../features/Lawyer/lawer_register_compilation/models/lawyer_registeration_complation_model.dart';

import 'package:rasikh/core/widgets/picture.dart';

class SpecializationCard extends StatelessWidget {
  final SpecializationModel        spec;
  final LawyerSpecializationLoaded state;
  final LawyerCompletionCubit      cubit;

  const SpecializationCard({
    required this.spec,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final cs         = theme.colorScheme;

    // A card is "selected" when the user has chosen ≥1 sub from it.
    final isSelected = state.isMainSelected(spec.id);
    // A card is "expanded" when the sub-chip panel is open.
    final isExpanded = state.expandedMainId == spec.id;

    return GestureDetector(
      onTap: () => cubit.toggleExpanded(spec.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve:    Curves.easeInOut,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : borderColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ③ Square icon (rightmost in RTL)
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerLowest,
                      border: Border.all(
                        color: cs.outline,
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: Picture(
                        "https://www.jlandess.com/wp-content/uploads/2023/06/BUSINESS-LITIGATION-800x800.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),


                  Gap(12.w),

                  // ② Text block (center, expands)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spec.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        if (spec.subSpecializations.isNotEmpty) ...[
                          Gap(3.h),
                          Text(
                            _desc(spec),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:  theme.hintColor,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.right,
                            maxLines:  2,
                            overflow:  TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Gap(12.w),

                  // ① Indicator dot (leftmost in RTL)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: _RadioDot(isSelected: isSelected, cs: cs),
                  ),
                ],
              ),
            ),

            // ── Sub-spec section (only when this card is expanded) ───
            if (isExpanded && spec.subSpecializations.isNotEmpty)
              _SubSpecSection(
                spec:  spec,
                state: state,
                cubit: cubit,
              ),
          ],
        ),
      ),
    );
  }

  String _desc(SpecializationModel s) {
    final names = s.subSpecializations.take(3).map((x) => x.name).join('، ');
    return 'قضايا ومعاملات: $names وحماية الحقوق التجارية.';
  }

  IconData _icon(String name) {
    if (name.contains('تجار'))   return Icons.business_center_rounded;
    if (name.contains('أسرة') || name.contains('عائل'))
      return Icons.family_restroom_rounded;
    if (name.contains('جنائ') || name.contains('جزائ'))
      return Icons.gavel_rounded;
    if (name.contains('عمال') || name.contains('عمل'))
      return Icons.work_outline_rounded;
    if (name.contains('عقار'))   return Icons.home_work_outlined;
    if (name.contains('إدار'))   return Icons.account_balance_outlined;
    return Icons.person_outline_rounded;
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _RadioDot  — custom radio circle matching the design exactly
// ─────────────────────────────────────────────────────────────────────────────

class _RadioDot extends StatelessWidget {
  final bool        isSelected;
  final ColorScheme cs;
  const _RadioDot({required this.isSelected, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width:    22.w,
      height:   22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? cs.primary : cs.outlineVariant,
          width: 1.8,
        ),
      ),
      child: isSelected
          ? Center(
        child: Container(
          width:      12.w,
          height:     12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primary,
          ),
        ),
      )
          : null,
    );
  }
}




// ─────────────────────────────────────────────────────────────────────────────
// _SubSpecSection
//
// Appears inside the expanded card, below a divider.
// Layout:
//   [Radio dot]  [إختر التخصص الفرعي  /  subtitle]
//   [Chip wrap — selected chips filled primary, others outlined]
//
// Each chip is keyed to (mainId, subId) so selections from different mains
// are fully independent.
// ─────────────────────────────────────────────────────────────────────────────

class _SubSpecSection extends StatelessWidget {
  final SpecializationModel        spec;
  final LawyerSpecializationLoaded state;
  final LawyerCompletionCubit      cubit;

  const _SubSpecSection({
    required this.spec,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final cs        = theme.colorScheme;
    // anySubSel: true when this particular main has ≥1 sub chosen.
    final anySubSel = state.isMainSelected(spec.id);

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Gap(12.h),

          // ── Label row ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio dot (leftmost in RTL)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: _RadioDot(isSelected: anySubSel, cs: cs),
              ),
              Gap(12.w),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "إختر التخصص الفرعي",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:      cs.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Gap(2.h),
                    Text(
                      "يمكنك اختيار أكثر من تخصص إذا لزم الأمر.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),

          Gap(12.h),

          // ── Chips ──────────────────────────────────────────────────
          Wrap(
            spacing:    8.w,
            runSpacing: 8.h,
            alignment:  WrapAlignment.start,
            children: spec.subSpecializations.map((sub) {
              final sel = state.isSubSelected(spec.id, sub.id);
              return GestureDetector(
                // Pass both mainId and subId so the cubit can store them
                // under the correct parent.
                onTap: () => cubit.toggleSub(spec.id, sub.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical:   7.h,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: sel ? cs.primary : cs.outlineVariant,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    sub.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:      sel ? cs.onPrimary : cs.onSurface,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
