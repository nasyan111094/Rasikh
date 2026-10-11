// ─────────────────────────────────────────────────────────────────────────────
// Shared/widgets/lawyer_specializations_selector.dart
//
// Professional multi-level selector for lawyers:
//  • أكثر من تخصص رئيسي (إضافة عبر SearchableDropdown)
//  • أكثر من تخصص فرعي داخل كل رئيسي (chips متعددة — واحد على الأقل)
//  • أكثر من دعوة داخل كل فرعي مختار (chips متعددة — اختياري،
//    والفرعي الذي لا يحتوي دعاوى يُختار عادي)
//
// Used by:
//  • LawyerSpecializationPage (registration)
//  • LawyerSpecializationsScreen (settings edit)
//
// NOTE: intentionally decoupled from the feature model files (registration &
// settings each define their own Specialization* classes, and mixing
// package:/relative import styles can create duplicate library identities).
// Screens map their own typed models into these primitives.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import 'package:rasikh/core/widgets/fields/drop_down_field.dart';

// ── View-models ──────────────────────────────────────────────────────────────

class LawyerSpecLawsuit {
  final String id;
  final String name;
  const LawyerSpecLawsuit({required this.id, required this.name});
}

class LawyerSpecSub {
  final String id;
  final String name;
  final List<LawyerSpecLawsuit> lawsuits;
  const LawyerSpecSub(
      {required this.id, required this.name, this.lawsuits = const []});
}

class LawyerSpecMain {
  final String id;
  final String name;
  final List<LawyerSpecSub> subs;
  const LawyerSpecMain(
      {required this.id, required this.name, this.subs = const []});
}

/// Snapshot emitted on every change.
class LawyerSpecSelection {
  final List<String> mainIds;
  final List<String> subIds;
  final List<String> lawsuitIds;

  /// subId → selected lawsuit ids (for prefill carry-forward).
  final Map<String, Set<String>> lawsuitsBySub;
  final int subCount;
  final int lawsuitCount;
  final bool isValid;
  final String? validationMessage;

  const LawyerSpecSelection({
    required this.mainIds,
    required this.subIds,
    required this.lawsuitIds,
    this.lawsuitsBySub = const {},
    required this.subCount,
    required this.lawsuitCount,
    required this.isValid,
    this.validationMessage,
  });
}

// ── Selector ─────────────────────────────────────────────────────────────────

class LawyerSpecializationsSelector extends StatefulWidget {
  final List<LawyerSpecMain> catalog;

  /// Prefill (settings edit). Invalid ids (not in catalog) are ignored.
  final List<String> initialMains;
  final Map<String, Set<String>> initialSubsByMain;
  final Map<String, Set<String>> initialLawsuitsBySub;

  final ValueChanged<LawyerSpecSelection> onChanged;

  const LawyerSpecializationsSelector({
    super.key,
    required this.catalog,
    required this.onChanged,
    this.initialMains = const [],
    this.initialSubsByMain = const {},
    this.initialLawsuitsBySub = const {},
  });

  @override
  State<LawyerSpecializationsSelector> createState() =>
      _LawyerSpecializationsSelectorState();
}

class _LawyerSpecializationsSelectorState
    extends State<LawyerSpecializationsSelector> {
  final TextEditingController _addController = TextEditingController();

  /// Ordered selected main ids (multi).
  late List<String> _mains;

  /// mainId → selected sub ids (multi per main).
  late Map<String, Set<String>> _subsByMain;

  /// subId → selected lawsuit ids (multi per sub, optional).
  late Map<String, Set<String>> _lawsuitsBySub;

  /// The single currently expanded card.
  String? _expandedMainId;

  Map<String, LawyerSpecMain> get _byId =>
      {for (final m in widget.catalog) m.id: m};

  @override
  void initState() {
    super.initState();
    final byId = _byId;
    // Keep only ids that still exist in the fresh catalog.
    _mains = widget.initialMains.where((id) => byId.containsKey(id)).toList();
    _subsByMain = {};
    for (final mainId in _mains) {
      final validSubs = byId[mainId]!.subs.map((s) => s.id).toSet();
      _subsByMain[mainId] =
          (widget.initialSubsByMain[mainId] ?? {}).intersection(validSubs);
    }
    _lawsuitsBySub = {};
    for (final entry in widget.initialLawsuitsBySub.entries) {
      if (entry.value.isNotEmpty) {
        _lawsuitsBySub[entry.key] = Set.of(entry.value);
      }
    }
    if (_mains.isNotEmpty) _expandedMainId = _mains.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  // ── Mutations ────────────────────────────────────────────────────────────

  void _emit() {
    final byId = _byId;
    final subIds =
        _subsByMain.values.expand((s) => s).toList(growable: false);
    final activeLawsuits = <String, Set<String>>{
      for (final e in _lawsuitsBySub.entries)
        if (subIds.contains(e.key)) e.key: Set.unmodifiable(e.value),
    };
    final lawsuitIds =
        activeLawsuits.values.expand((e) => e).toList(growable: false);

    String? message;
    if (_mains.isEmpty) {
      message = 'اختر تخصصاً رئيسياً واحداً على الأقل';
    } else {
      final emptyMains = _mains
          .where((id) => (_subsByMain[id]?.isEmpty ?? true))
          .map((id) => byId[id]?.name ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      if (emptyMains.isNotEmpty) {
        message =
            'اختر تخصصاً فرعياً واحداً على الأقل داخل: ${emptyMains.join('، ')}';
      }
    }

    widget.onChanged(LawyerSpecSelection(
      mainIds: List.unmodifiable(_mains),
      subIds: subIds,
      lawsuitIds: lawsuitIds,
      lawsuitsBySub: activeLawsuits,
      subCount: subIds.length,
      lawsuitCount: lawsuitIds.length,
      isValid: message == null,
      validationMessage: message,
    ));
  }

  void _addMainByName(String name) {
    final match = widget.catalog.where((m) => m.name == name).firstOrNull;
    if (match == null) return;
    if (_mains.contains(match.id)) {
      setState(() => _expandedMainId = match.id);
      _addController.clear();
      return;
    }
    setState(() {
      _mains.add(match.id);
      _subsByMain.putIfAbsent(match.id, () => <String>{});
      _expandedMainId = match.id;
      _addController.clear();
    });
    _emit();
  }

  void _removeMain(String mainId) {
    setState(() {
      // Drop subs + their lawsuits as well.
      final subIds = _subsByMain.remove(mainId) ?? <String>{};
      for (final s in subIds) {
        _lawsuitsBySub.remove(s);
      }
      _mains.remove(mainId);
      if (_expandedMainId == mainId) {
        _expandedMainId = _mains.isEmpty ? null : _mains.last;
      }
    });
    _emit();
  }

  void _toggleSub(String mainId, String subId) {
    setState(() {
      final set = _subsByMain.putIfAbsent(mainId, () => <String>{});
      if (set.contains(subId)) {
        set.remove(subId);
        _lawsuitsBySub.remove(subId);
      } else {
        set.add(subId);
      }
    });
    _emit();
  }

  void _toggleLawsuit(String subId, String lawsuitId) {
    setState(() {
      final set = _lawsuitsBySub.putIfAbsent(subId, () => <String>{});
      if (set.contains(lawsuitId)) {
        set.remove(lawsuitId);
        if (set.isEmpty) _lawsuitsBySub.remove(subId);
      } else {
        set.add(lawsuitId);
      }
    });
    _emit();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final byId = _byId;
    final availableToAdd =
        widget.catalog.where((m) => !_mains.contains(m.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1) Add main via searchable dropdown ──────────────────────
        SearchableDropdown(
          items: availableToAdd.map((m) => m.name).toList(),
          hint: _mains.isEmpty
              ? 'ابحث واختر تخصصك الرئيسي'
              : 'ابحث لإضافة تخصص رئيسي آخر',
          label: 'التخصصات الرئيسية * (يمكن اختيار أكثر من تخصص)',
          enableSearch: true,
          controller: _addController,
          showPrefixIcon: false,
          onChanged: _addMainByName,
        ),

        if (_mains.isEmpty) ...[
          Gap(12.h),
          _EmptyHint(theme: Theme.of(context)),
        ],

        if (_mains.isNotEmpty) ...[
          Gap(12.h),
          _SummaryBar(
            mainCount: _mains.length,
            subCount: _subsByMain.values.fold(0, (a, b) => a + b.length),
            lawsuitCount:
                _lawsuitsBySub.values.fold(0, (a, b) => a + b.length),
          ),
          Gap(12.h),
          // ── 2) Selected mains as expandable cards ──────────────────
          ..._mains.map((mainId) {
            final main = byId[mainId];
            if (main == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _MainCard(
                main: main,
                expanded: _expandedMainId == mainId,
                selectedSubs: _subsByMain[mainId] ?? const {},
                lawsuitsBySub: _lawsuitsBySub,
                onHeaderTap: () => setState(() => _expandedMainId =
                    _expandedMainId == mainId ? null : mainId),
                onRemove: () => _removeMain(mainId),
                onToggleSub: (subId) => _toggleSub(mainId, subId),
                onToggleLawsuit: _toggleLawsuit,
              ),
            );
          }),
        ],
      ],
    );
  }
}

// ── Summary bar ──────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int mainCount;
  final int subCount;
  final int lawsuitCount;
  const _SummaryBar(
      {required this.mainCount,
      required this.subCount,
      required this.lawsuitCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
          Gap(8.w),
          Expanded(
            child: Text(
              '$mainCount رئيسي · $subCount فرعي · $lawsuitCount دعوة',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final ThemeData theme;
  const _EmptyHint({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              color: theme.colorScheme.primary.withOpacity(0.7)),
          Gap(10.w),
          Expanded(
            child: Text(
              'استخدم القائمة بالأعلى للبحث وإضافة تخصصك الرئيسي الأول، ويمكنك إضافة المزيد بعد ذلك.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main card (accordion) ────────────────────────────────────────────────────

class _MainCard extends StatelessWidget {
  final LawyerSpecMain main;
  final bool expanded;
  final Set<String> selectedSubs;
  final Map<String, Set<String>> lawsuitsBySub;
  final VoidCallback onHeaderTap;
  final VoidCallback onRemove;
  final ValueChanged<String> onToggleSub;
  final void Function(String subId, String lawsuitId) onToggleLawsuit;

  const _MainCard({
    required this.main,
    required this.expanded,
    required this.selectedSubs,
    required this.lawsuitsBySub,
    required this.onHeaderTap,
    required this.onRemove,
    required this.onToggleSub,
    required this.onToggleLawsuit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final lawsuitCount = selectedSubs.fold<int>(
        0, (a, s) => a + (lawsuitsBySub[s]?.length ?? 0));
    final highlighted = expanded || selectedSubs.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              highlighted ? cs.primary : theme.dividerColor.withOpacity(0.35),
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onHeaderTap,
            child: Padding(
              padding: EdgeInsets.all(14.h),
              child: Row(
                children: [
                  Container(
                    width: 26.w,
                    height: 26.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedSubs.isNotEmpty
                          ? cs.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: selectedSubs.isNotEmpty
                            ? cs.primary
                            : cs.outlineVariant,
                        width: 1.6,
                      ),
                    ),
                    child: selectedSubs.isNotEmpty
                        ? Icon(Icons.check_rounded,
                            size: 15, color: cs.onPrimary)
                        : null,
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          main.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: highlighted
                                ? cs.primary
                                : theme.textTheme.titleSmall?.color,
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          selectedSubs.isEmpty
                              ? '${main.subs.length} تخصص فرعي — اختر واحداً أو أكثر'
                              : '${selectedSubs.length} فرعي محدد'
                                  '${lawsuitCount > 0 ? ' · $lawsuitCount دعوة' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selectedSubs.isEmpty
                                ? theme.hintColor
                                : cs.primary,
                            fontWeight: selectedSubs.isEmpty
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onRemove,
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: theme.hintColor),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: cs.primary,
                  ),
                ],
              ),
            ),
          ),
          // Body
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                            height: 1,
                            color: theme.dividerColor.withOpacity(0.3)),
                        Gap(12.h),
                        Text(
                          'التخصصات الفرعية * (يمكن اختيار أكثر من تخصص)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(8.h),
                        if (main.subs.isEmpty)
                          Text('لا توجد تخصصات فرعية نشطة داخل هذا التخصص.',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.hintColor))
                        else
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: main.subs.map((sub) {
                              final sel = selectedSubs.contains(sub.id);
                              return _Chip(
                                label: sub.name,
                                selected: sel,
                                onTap: () => onToggleSub(sub.id),
                              );
                            }).toList(),
                          ),
                        // Lawsuits under each selected sub (optional)
                        for (final sub in main.subs.where(
                            (s) => selectedSubs.contains(s.id))) ...[
                          Gap(12.h),
                          Text(
                            'دعاوى "${sub.name}" (اختياري — أكثر من دعوة)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                          Gap(6.h),
                          if (sub.lawsuits.isEmpty)
                            Text(
                              'هذا التخصص الفرعي لا يحتوي على دعاوى — تم اختياره بنجاح.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.primary,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: sub.lawsuits.map((l) {
                                final sel =
                                    (lawsuitsBySub[sub.id] ?? const {})
                                        .contains(l.id);
                                return _Chip(
                                  label: l.name,
                                  selected: sel,
                                  small: true,
                                  onTap: () =>
                                      onToggleLawsuit(sub.id, l.id),
                                );
                              }).toList(),
                            ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

// ── Chip ─────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool small;
  final VoidCallback onTap;
  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.small = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: small ? 12.w : 16.w,
          vertical: small ? 6.h : 7.h,
        ),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? cs.primary : theme.dividerColor.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected && small) ...[
              Icon(Icons.check_rounded, size: 13, color: cs.onPrimary),
              Gap(4.w),
            ],
            Text(
              label,
              style: (small
                      ? theme.textTheme.bodySmall
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                color: selected ? cs.onPrimary : cs.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
