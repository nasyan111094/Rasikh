// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/lawyer_Settings/screens/lawyer_specializations_screen.dart
//
// تعديل تخصصات المحامي — نفس شكل ومنطق شاشة التسجيل تماماً عبر
// SpecializationBookingForm المشترك:
//  • تخصص رئيسي واحد فقط (مطلوب)
//  • تخصص فرعي (اختياري — متعدد)
//  • نوع دعوى (اختياري — متعدد)
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

  String? _initialMainId;
  Map<String, Set<String>> _initialSubsByMain = const {};
  Map<String, Set<String>> _initialLawsuitsBySub = const {};
  LawyerSpecSelection? _selection;

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

    final activeMainIds = _cubit.catalog.map((cat) => cat.id).toSet();

    // التخصص الرئيسي واحد فقط — نأخذ أول تخصص رئيسي صالح.
    String? mainId;
    List<String> savedSubIds = const [];

    if (cached.specializationsByMain.isNotEmpty) {
      for (final main in cached.specializationsByMain) {
        if (activeMainIds.contains(main.id)) {
          mainId = main.id;
          savedSubIds = [
            for (final sub in main.selectedSubSpecializations) sub.id
          ];
          break;
        }
      }
    } else if (cached.mainSpecializations.isNotEmpty) {
      for (final main in cached.mainSpecializations) {
        if (activeMainIds.contains(main.id)) {
          mainId = main.id;
          savedSubIds = [
            for (final sub in cached.subSpecializations) sub.id
          ];
          break;
        }
      }
    }

    if (mainId == null) return;

    final activeMain =
        _cubit.catalog.firstWhere((cat) => cat.id == mainId);
    final activeSubIds =
        activeMain.subSpecializations.map((sub) => sub.id).toSet();
    final selectedSubs = {
      for (final id in savedSubIds)
        if (activeSubIds.contains(id)) id,
    };

    final lawsuitsBySub = <String, Set<String>>{};
    for (final lawsuitId in cached.lawsuitTypeIds) {
      for (final sub in activeMain.subSpecializations) {
        if (sub.lawsuitTypes.any((l) => l.id == lawsuitId)) {
          lawsuitsBySub
              .putIfAbsent(sub.id, () => <String>{})
              .add(lawsuitId);
          break;
        }
      }
    }
    lawsuitsBySub.removeWhere((subId, _) => !selectedSubs.contains(subId));

    _initialMainId = mainId;
    _initialSubsByMain = {mainId: selectedSubs};
    _initialLawsuitsBySub = lawsuitsBySub;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  void _save() {
    final sel = _selection;
    if (sel == null || !sel.isValid) return;
    _cubit.saveSpecializations(
      mainSpecializationIds: sel.mainIds,
      subSpecializationIds: sel.subIds,
      lawsuitTypeIds: sel.lawsuitIds,
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
                        onPressed: ((_selection?.isValid ?? false) &&
                                !isLoading)
                            ? _save
                            : null,
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
        initialMainId: _initialMainId,
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
