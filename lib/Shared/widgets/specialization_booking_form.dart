// ─────────────────────────────────────────────────────────────────────────────
// Shared/widgets/specialization_booking_form.dart
//
// فورم اختيار التخصصات الموحّد:
//  • تخصص رئيسي (اختياري — متعدد عبر MultiSelectionBottomSheet)
//  • تخصص فرعي (اختياري — متعدد عبر MultiSelectionBottomSheet)
//  • نوع دعوى (اختياري — متعدد عبر MultiSelectionBottomSheet)
//
// مستخدم في:
//  • LawyerSpecializationPage (التسجيل)
//  • LawyerSpecializationsScreen (تعديل التخصصات)
// أي تعديل هنا ينعكس على الشاشتين معاً.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import 'package:rasikh/features/User/application/widgets/consultation_flow_widgets.dart';
import 'package:rasikh/features/User/application/widgets/specialty_selection_field.dart';

import '../bottom_sheets/multi_selection_bottom_sheet.dart';
import 'lawyer_specializations_selector.dart'
    show LawyerSpecMain, LawyerSpecSelection;

class _SubOption {
  final String id;
  final String name;
  final String parentName;
  const _SubOption({
    required this.id,
    required this.name,
    required this.parentName,
  });
}

class _LawsuitOption {
  final String id;
  final String name;
  final String parentName;
  final String subId;
  const _LawsuitOption({
    required this.id,
    required this.name,
    required this.parentName,
    required this.subId,
  });
}

class SpecializationBookingForm extends StatefulWidget {
  final List<LawyerSpecMain> catalog;

  /// Prefill (تعديل التخصصات / الرجوع في التسجيل).
  final List<String> initialMainIds;
  final Set<String> initialSubIds;
  final Map<String, Set<String>> initialLawsuitsBySub;

  final ValueChanged<LawyerSpecSelection> onChanged;

  const SpecializationBookingForm({
    super.key,
    required this.catalog,
    required this.onChanged,
    this.initialMainIds = const [],
    this.initialSubIds = const {},
    this.initialLawsuitsBySub = const {},
  });

  @override
  State<SpecializationBookingForm> createState() =>
      _SpecializationBookingFormState();
}

class _SpecializationBookingFormState extends State<SpecializationBookingForm> {
  late Set<String> _selectedMainIds;
  late Set<String> _selectedSubIds;
  late Map<String, Set<String>> _lawsuitsBySub;

  Map<String, LawyerSpecMain> get _byMainId =>
      {for (final m in widget.catalog) m.id: m};

  @override
  void initState() {
    super.initState();
    final byId = _byMainId;
    // القسم الرئيسي اختياري ومتعدد
    _selectedMainIds = widget.initialMainIds
        .where((id) => byId.containsKey(id))
        .toSet();

    // عند عدم اختيار قسم رئيسي، تُعرض كل الأقسام الفرعية المتاحة
    final validSubs = _subs.map((s) => s.id).toSet();
    _selectedSubIds = widget.initialSubIds.intersection(validSubs);

    _lawsuitsBySub = {
      for (final e in widget.initialLawsuitsBySub.entries)
        if (_selectedSubIds.contains(e.key) && e.value.isNotEmpty)
          e.key: Set.of(e.value),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  /// الأقسام الفرعية المتاحة:
  ///  • لا قسم رئيسي مختار → كل الأقسام الفرعية في الكتالوج
  ///  • يوجد أقسام مختارة → الأقسام الفرعية التابعة لها فقط
  static List<_SubOption> _availableSubs({
    required List<LawyerSpecMain> catalog,
    required Set<String> mainIds,
  }) {
    final mains = mainIds.isEmpty
        ? catalog
        : catalog.where((m) => mainIds.contains(m.id));
    return [
      for (final m in mains)
        for (final s in m.subs)
          _SubOption(id: s.id, name: s.name, parentName: m.name),
    ];
  }

  List<_SubOption> get _subs => _availableSubs(
        catalog: widget.catalog,
        mainIds: _selectedMainIds,
      );

  /// أنواع الدعاوى المتاحة لكل الأقسام الفرعية المعروضة حالياً.
  /// لا تُحجب أي دعوى بسبب عدم اختيار قسم رئيسي.
  List<_LawsuitOption> get _lawsuits {
    final mainsInPlay = _selectedMainIds.isEmpty
        ? widget.catalog
        : widget.catalog.where((m) => _selectedMainIds.contains(m.id));
    return [
      for (final m in mainsInPlay)
        for (final s in m.subs)
          for (final l in s.lawsuits)
            _LawsuitOption(
              id: l.id,
              name: l.name,
              parentName: s.name,
              subId: s.id,
            ),
    ];
  }

  List<String> get _flatLawsuitIds =>
      _lawsuitsBySub.values.expand((e) => e).toList(growable: false);

  void _emit() {
    final subIds = _subs
        .where((s) => _selectedSubIds.contains(s.id))
        .map((s) => s.id)
        .toList(growable: false);
    final activeLawsuits = <String, Set<String>>{
      for (final e in _lawsuitsBySub.entries)
        if (subIds.contains(e.key)) e.key: Set.unmodifiable(e.value),
    };
    final lawsuitIds =
        activeLawsuits.values.expand((e) => e).toList(growable: false);

    // كل الحقول اختيارية الآن — لا يوجد تحقق إجباري على القسم الرئيسي.
    widget.onChanged(LawyerSpecSelection(
      mainIds: _selectedMainIds.toList(growable: false),
      subIds: subIds,
      lawsuitIds: lawsuitIds,
      lawsuitsBySub: activeLawsuits,
      subCount: subIds.length,
      lawsuitCount: lawsuitIds.length,
      isValid: true,
    ));
  }

  // ── Mutations ────────────────────────────────────────────────────────────

  static bool _sameIds(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  void _applyMains(List<LawyerSpecMain> selected) {
    final newIds = {for (final s in selected) s.id};
    if (_sameIds(newIds, _selectedMainIds)) return;

    // الأقسام الفرعية تبقى كما هي: عند عدم وجود أقسام رئيسية تظل كل
    // الأقسام الفرعية متاحة، ومع وجودها يُستبعد فقط غير التابع لها.
    final validSubs = _availableSubs(
      catalog: widget.catalog,
      mainIds: newIds,
    ).map((s) => s.id).toSet();

    final filteredSubs = _selectedSubIds.intersection(validSubs);

    setState(() {
      _selectedMainIds = newIds;
      _selectedSubIds = filteredSubs;
      _lawsuitsBySub.removeWhere((subId, _) => !filteredSubs.contains(subId));
    });
    _emit();
  }

  void _applySubs(List<_SubOption> selected) {
    final ids = {for (final s in selected) s.id};
    setState(() {
      _selectedSubIds = ids;
      _lawsuitsBySub.removeWhere((subId, _) => !ids.contains(subId));
    });
    _emit();
  }

  void _applyLawsuits(List<_LawsuitOption> selected) {
    final map = <String, Set<String>>{};
    for (final l in selected) {
      map.putIfAbsent(l.subId, () => <String>{}).add(l.id);
    }
    setState(() {
      _lawsuitsBySub = map;
      // اختيار دعوى يحدد قسمها الفرعي تلقائياً، حتى يبقى الاختيار ظاهراً
      // ولا يُسقطه التسلسل الهرمي عند الإرسال.
      _selectedSubIds.addAll(map.keys);
    });
    _emit();
  }

  /// مسح الأقسام الرئيسية فقط — الفرعية والدعاوى تبقى كما هي لأنها صارت
  /// مستقلة عنها (تُعرض كلها عند عدم وجود قسم رئيسي مختار).
  void _clearMains() {
    setState(() => _selectedMainIds = {});
    _emit();
  }

  void _clearSubs() {
    setState(() {
      _selectedSubIds = {};
      _lawsuitsBySub = {};
    });
    _emit();
  }

  void _clearLawsuits() {
    setState(() => _lawsuitsBySub = {});
    _emit();
  }

  void _removeSub(String id) {
    setState(() {
      _selectedSubIds.remove(id);
      _lawsuitsBySub.remove(id);
    });
    _emit();
  }

  void _removeLawsuit(String subId, String lawsuitId) {
    setState(() {
      _lawsuitsBySub[subId]?.remove(lawsuitId);
      if (_lawsuitsBySub[subId]?.isEmpty ?? false) {
        _lawsuitsBySub.remove(subId);
      }
    });
    _emit();
  }

  // ── Sheets ───────────────────────────────────────────────────────────────

  void _openMainsSheet() {
    showMultiSelectionBottomSheet(
      context: context,
      builder: (_) => MultiSelectionBottomSheet<LawyerSpecMain>(
        title: 'اختر التخصص الرئيسي',
        searchHint: 'ابحث عن التخصص الرئيسي',
        items: widget.catalog,
        emptyIcon: Icons.account_balance_outlined,
        emptyTitle: 'لا توجد تخصصات متاحة',
        emptyMessage: 'لم يتم العثور على تخصصات نشطة',
        selectedIds: _selectedMainIds,
        allowEmpty: true,
        confirmText: 'تأكيد',
        itemId: (m) => m.id,
        itemName: (m) => m.name,
        onConfirm: _applyMains,
      ),
    );
  }

  void _openSubsSheet() {
    showMultiSelectionBottomSheet(
      context: context,
      builder: (_) => MultiSelectionBottomSheet<_SubOption>(
        title: 'اختر التخصص الفرعي',
        searchHint: 'ابحث عن التخصص الفرعي',
        items: _subs,
        emptyIcon: Icons.account_tree_outlined,
        emptyTitle: 'لا توجد تخصصات فرعية',
        emptyMessage: _selectedMainIds.isEmpty
            ? 'جميع الأقسام الفرعية متاحة للاختيار'
            : 'التخصصات المختارة لا تحتوي على تخصصات فرعية',
        selectedIds: _selectedSubIds,
        allowEmpty: true,
        confirmText: 'تأكيد',
        itemId: (s) => s.id,
        itemName: (s) => s.name,
        itemSubtitle: (s) => s.parentName,
        onConfirm: _applySubs,
      ),
    );
  }

  void _openLawsuitsSheet() {
    showMultiSelectionBottomSheet(
      context: context,
      builder: (_) => MultiSelectionBottomSheet<_LawsuitOption>(
        title: 'اختر نوع الدعوى',
        searchHint: 'ابحث عن نوع الدعوى',
        items: _lawsuits,
        emptyIcon: Icons.gavel_rounded,
        emptyTitle: 'لا توجد دعاوى',
        emptyMessage: 'لا توجد أنواع دعاوى متاحة',
        selectedIds: _flatLawsuitIds.toSet(),
        allowEmpty: true,
        confirmText: 'تأكيد',
        itemId: (l) => l.id,
        itemName: (l) => l.name,
        itemSubtitle: (l) => l.parentName,
        onConfirm: _applyLawsuits,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  String? _joinNames(List<String> names) {
    if (names.isEmpty) return null;
    if (names.length <= 2) return names.join('، ');
    return '${names.take(2).join('، ')} +${names.length - 2}';
  }

  String? get _mainsValue {
    if (_selectedMainIds.isEmpty) return null;
    final names = [
      for (final id in _selectedMainIds)
        if (_byMainId[id] != null) _byMainId[id]!.name,
    ];
    return _joinNames(names);
  }

  String? get _subsValue {
    final names = [
      for (final s in _subs)
        if (_selectedSubIds.contains(s.id)) s.name,
    ];
    final seen = <String>{};
    return _joinNames(names.where((n) => seen.add(n)).toList());
  }

  String? get _lawsuitsValue {
    final byLawsuitName = <String, String>{};
    for (final m in widget.catalog) {
      for (final s in m.subs) {
        for (final l in s.lawsuits) {
          byLawsuitName[l.id] = l.name;
        }
      }
    }
    final names = <String>[];
    for (final entry in _lawsuitsBySub.entries) {
      for (final id in entry.value) {
        final name = byLawsuitName[id];
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    final seen = <String>{};
    return _joinNames(names.where((n) => seen.add(n)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final subChips = [
      for (final s in _subs)
        if (_selectedSubIds.contains(s.id))
          _DeletableChip(
            label: s.name,
            onDeleted: () => _removeSub(s.id),
          ),
    ];
    final lawsuitChips = [
      for (final entry in _lawsuitsBySub.entries)
        for (final id in entry.value)
          _LawsuitChip(
            catalog: widget.catalog,
            lawsuitId: id,
            onDeleted: () => _removeLawsuit(entry.key, id),
          ),
    ];

    return Column(
      children: [
        Gap(ConsultationFlowSpacing.titleToContent),
        SpecialtySelectionField(
          label: 'التخصص الرئيسي (اختياري)',
          hint: 'اختر التخصص الرئيسي (يمكن اختيار أكثر من تخصص)',
          value: _mainsValue,
          isRequired: false,
          onTap: _openMainsSheet,
          onClear: _selectedMainIds.isEmpty ? null : _clearMains,
        ),
        Gap(ConsultationFlowSpacing.fieldGap),
        SpecialtySelectionField(
          label: 'التخصص الفرعي (اختياري)',
          hint: 'اختر التخصص الفرعي (يمكن اختيار أكثر من تخصص)',
          value: _subsValue,
          isRequired: false,
          onTap: _openSubsSheet,
          onClear: _selectedSubIds.isEmpty ? null : _clearSubs,
        ),
        if (subChips.isNotEmpty) ...[
          Gap(8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: subChips,
          ),
        ],
        Gap(ConsultationFlowSpacing.fieldGap),
        SpecialtySelectionField(
          label: 'نوع الدعوى (اختياري)',
          hint: 'اختر نوع الدعوى (يمكن اختيار أكثر من دعوى)',
          value: _lawsuitsValue,
          isRequired: false,
          onTap: _openLawsuitsSheet,
          onClear: _flatLawsuitIds.isEmpty ? null : _clearLawsuits,
        ),
        if (lawsuitChips.isNotEmpty) ...[
          Gap(8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: lawsuitChips,
          ),
        ],
        Gap(12.h),
      ],
    );
  }
}

class _LawsuitChip extends StatelessWidget {
  final List<LawyerSpecMain> catalog;
  final String lawsuitId;
  final VoidCallback onDeleted;

  const _LawsuitChip({
    required this.catalog,
    required this.lawsuitId,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    String name = '';
    for (final m in catalog) {
      for (final s in m.subs) {
        for (final l in s.lawsuits) {
          if (l.id == lawsuitId) name = l.name;
        }
      }
    }
    if (name.isEmpty) return const SizedBox.shrink();
    return _DeletableChip(label: name, small: true, onDeleted: onDeleted);
  }
}

class _DeletableChip extends StatelessWidget {
  final String label;
  final bool small;
  final VoidCallback onDeleted;

  const _DeletableChip({
    required this.label,
    required this.onDeleted,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: small ? 10.w : 12.w,
        end: 6.w,
      ),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: (small
                    ? theme.textTheme.bodySmall
                    : theme.textTheme.bodyMedium)
                ?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(4.w),
          InkWell(
            onTap: onDeleted,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.close_rounded,
                size: small ? 13 : 15,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
