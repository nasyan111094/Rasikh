// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/lawyer_Settings/screens/lawyer_specializations_screen.dart
//
// تعديل تخصصات المحامي — نفس شكل ومنطق شاشة التسجيل تماماً عبر
// SpecializationBookingForm المشترك:
//  • تخصص رئيسي (اختياري — متعدد؛ عند تركه فارغاً تُعرض كل الفرعية والدعاوى)
//  • تخصص فرعي (اختياري — متعدد)
//  • نوع دعوى (اختياري — متعدد)
//
// عند الحفظ يُرسل فقط ما تغيّر فعلاً:
//  • لم تتغيّر الأقسام        → لا يُرسل mainSpecializations إطلاقاً
//  • مسح المستخدم كل الأقسام  → يُرسل mainSpecializations: []
//  • غيّر الأقسام             → تُرسل القيم الجديدة
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import 'package:rasikh/Shared/widgets/lawyer_specializations_selector.dart';
import 'package:rasikh/Shared/widgets/specialization_booking_form.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/features/User/application/widgets/consultation_flow_widgets.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../bloc/Profile_cubit/lawyer_cubit.dart';
import '../bloc/Specializations_cubit/specializations_cubit.dart';
import '../bloc/Specializations_cubit/specializations_state.dart';

class LawyerSpecializationsScreen extends StatefulWidget {
  const LawyerSpecializationsScreen({Key? key}) : super(key: key);

  @override
  State<LawyerSpecializationsScreen> createState() =>
      _LawyerSpecializationsScreenState();
}

class _LawyerSpecializationsScreenState
    extends State<LawyerSpecializationsScreen> {
  late final SpecializationsCubit _cubit = getIt<SpecializationsCubit>();

  bool _ready = false;
  String? _loadError;

  /// الأقسام الرئيسية كما كانت عند فتح الشاشة — تُقارن عند الحفظ للتفرقة
  /// بين "لم يغيّر الأقسام" و"مسحها بالكامل".
  List<String> _initialMainIds = const [];
  Map<String, Set<String>> _initialSubsByMain = const {};
  Map<String, Set<String>> _initialLawsuitsBySub = const {};
  LawyerSpecSelection? _selection;

  /// هل تغيّر أي من الاختيارات عن الحالة الأصلية؟
  /// القائمة الفارغة وحدها لا تكفي للحكم — قد تعني "لم يتغيّر شيء" أو
  /// "مسح المستخدم كل اختياراته عمداً"، ولذلك نقارن بالحالة الأصلية.
  bool _sameSelection(List<String> initial, List<String> current) {
    final a = initial.toSet();
    final b = current.toSet();
    return a.length == b.length && a.containsAll(b);
  }

  bool get _mainIdsChanged =>
      !_sameSelection(_initialMainIds, _selection?.mainIds ?? const []);

  bool get _lawsuitIdsChanged =>
      _mainIdsChanged ||
      !_sameSelection(
        _initialLawsuitsBySub.values.expand((s) => s).toList(),
        _selection?.lawsuitIds ?? const [],
      );

  // الفرعية تُرسل أيضاً عند تغيّر الرئيسية أو الدعاوى: الـ API يتحقق من
  // التسلسل الهرمي داخل نفس الطلب (كل دعوى تتبع فرعياً، وكل فرعي يتبع
  // رئيسياً مُرسلاً معه)، فلا يجوز إرسال دعوى بلا فرعيها.
  bool get _subIdsChanged =>
      _mainIdsChanged ||
      _lawsuitIdsChanged ||
      !_sameSelection(
        _initialSubsByMain.values.expand((s) => s).toList(),
        _selection?.subIds ?? const [],
      );

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _cubit.loadSpecializations();
    if (!mounted) return;
    final state = _cubit.state;
    if (state is SpecializationsError) {
      setState(() {
        _loadError = state.message;
        _ready = true;
      });
      return;
    }
    _prefillFromProfile();
    setState(() {
      _loadError = null;
      _ready = true;
    });
  }

  void _prefillFromProfile() {
    final cached = context.read<LawyerProfileCubit>().cachedProfile;
    if (cached == null) return;

    final catalogById = {for (final c in _cubit.catalog) c.id: c};

    // ── الأقسام الرئيسية المحفوظة (متعددة) ────────────────────────────────
    final savedMainIds = <String>[];
    final savedSubIds = <String>[];

    for (final main in cached.specializationsByMain) {
      if (!catalogById.containsKey(main.id)) continue;
      savedMainIds.add(main.id);
      savedSubIds.addAll([
        for (final sub in main.selectedSubSpecializations) sub.id,
      ]);
    }

    // توافق مع الشكل القديم: قائمة رئيسية واحدة لكل سجل مع قائمة فرعية مسطّحة.
    if (savedMainIds.isEmpty && cached.mainSpecializations.isNotEmpty) {
      for (final main in cached.mainSpecializations) {
        if (!catalogById.containsKey(main.id)) continue;
        savedMainIds.add(main.id);
      }
      if (savedMainIds.isNotEmpty) {
        savedSubIds.addAll([
          for (final sub in cached.subSpecializations) sub.id,
        ]);
      }
    }

    _initialMainIds = savedMainIds;

    // ── الأقسام الفرعية الصالحة ضمن الأقسام الرئيسية المحفوظة ────────────
    final validSubIds = <String>{};
    for (final mainId in savedMainIds) {
      final main = catalogById[mainId];
      if (main == null) continue;
      validSubIds.addAll(main.subSpecializations.map((sub) => sub.id));
    }

    final selectedSubs = {
      for (final id in savedSubIds)
        if (validSubIds.contains(id)) id,
    };

    // ── أنواع الدعاوى محسوبة على كل الأقسام الرئيسية المحفوظة ────────────
    final lawsuitsBySub = <String, Set<String>>{};
    for (final lawsuitId in cached.lawsuitTypeIds) {
      for (final mainId in savedMainIds) {
        final main = catalogById[mainId];
        if (main == null) continue;
        for (final sub in main.subSpecializations) {
          if (!selectedSubs.contains(sub.id)) continue;
          if (sub.lawsuitTypes.any((l) => l.id == lawsuitId)) {
            lawsuitsBySub
                .putIfAbsent(sub.id, () => <String>{})
                .add(lawsuitId);
            break;
          }
        }
      }
    }

    _initialSubsByMain = {
      for (final mainId in savedMainIds) mainId: Set.of(selectedSubs),
    };
    _initialLawsuitsBySub = lawsuitsBySub;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  void _save() {
    // نرسل فقط ما تغيّر فعلاً:
    //   لم يتغيّر  → null (يُحذف الحقل من الطلب)
    //   مُسح كلياً → [] (مسح صريح)
    _cubit.saveSpecializations(
      mainSpecializationIds:
          _mainIdsChanged ? (_selection?.mainIds ?? const []) : null,
      subSpecializationIds:
          _subIdsChanged ? (_selection?.subIds ?? const []) : null,
      lawsuitTypeIds:
          _lawsuitIdsChanged ? (_selection?.lawsuitIds ?? const []) : null,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  List<LawyerSpecMain> get _catalog => _cubit.catalog
      .map((c) => LawyerSpecMain(
            id: c.id,
            name: c.name,
            subs: c.subSpecializations
                .map((s) => LawyerSpecSub(
                      id: s.id,
                      name: s.name,
                      lawsuits: s.lawsuitTypes
                          .map((l) => LawyerSpecLawsuit(
                              id: l.id, name: l.name))
                          .toList(),
                    ))
                .toList(),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SpecializationsCubit, SpecializationsState>(
        listener: (context, state) {
          if (state is SaveSpecializationsSuccess) {
            context.read<LawyerProfileCubit>().getProfile();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ التخصصات بنجاح')),
            );
            Navigator.of(context).pop();
          } else if (state is SaveSpecializationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: GeneralAppBar(
              title: 'إختر التخصص',
              backIcon: Icons.arrow_back,
              backIconSize: 22,
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ConsultationFlowSpacing.horizontal,
              ),
              child: Column(
                children: [
                  Expanded(child: _buildBody(theme)),
                  BlocBuilder<SpecializationsCubit, SpecializationsState>(
                    builder: (context, state) {
                      final isLoading =
                          state is SaveSpecializationsLoading;
                      final lawsuitCount =
                          _selection?.lawsuitCount ?? 0;
                      return ConsultationBottomButton(
                        text: lawsuitCount > 0
                            ? 'حفظ ($lawsuitCount دعوى)'
                            : 'حفظ',
                        isLoading: isLoading,
                        onPressed: !isLoading ? _save : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (!_ready) return const _FieldsShimmer();

    if (_loadError != null && _cubit.catalog.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 48, color: theme.colorScheme.error),
            const Gap(12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            const Gap(12),
            TextButton.icon(
              onPressed: () {
                setState(() => _ready = false);
                _initialize();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_cubit.catalog.isEmpty) {
      return Center(
        child: Text(
          'لم يتم العثور على تخصصات نشطة',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return SingleChildScrollView(
      child: SpecializationBookingForm(
        catalog: _catalog,
        initialMainIds: _initialMainIds,
        initialSubIds: _initialSubsByMain.values
            .expand((s) => s)
            .toSet(),
        initialLawsuitsBySub: _initialLawsuitsBySub,
        onChanged: (sel) => setState(() => _selection = sel),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton (3 حقول بنفس مقاس SpecialtySelectionField)
// ─────────────────────────────────────────────────────────────────────────────

class _FieldsShimmer extends StatelessWidget {
  const _FieldsShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(ConsultationFlowSpacing.titleToContent),
          for (int i = 0; i < 3; i++) ...[
            Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Gap(15.h),
            Container(
              height: ConsultationFlowSpacing.buttonHeight,
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.5),
                borderRadius:
                    BorderRadius.circular(ConsultationFlowSpacing.radius),
              ),
            ),
            Gap(ConsultationFlowSpacing.fieldGap),
          ],
        ],
      ),
    );
  }
}
