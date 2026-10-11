// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/specializations/presentation/screens/
//   lawyer_specializations_screen.dart
//
// Professional flow:
//  • أكثر من تخصص رئيسي عبر SearchableDropdown (إضافة)
//  • أكثر من تخصص فرعي داخل كل رئيسي (chips)
//  • أكثر من دعوة داخل كل فرعي مختار (chips)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/Shared/widgets/lawyer_specializations_selector.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

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
  int _selectorKey = 0;

  List<String> _initialMains = const [];
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
    setState(() => _ready = true);
  }

  void _prefillFromProfile() {
    final cached = context.read<LawyerProfileCubit>().cachedProfile;
    if (cached == null) return;

    // Multi-main: keep every still-active saved main.
    final activeMainIds = _cubit.catalog.map((cat) => cat.id).toSet();
    final mains = <String>[];
    final subsByMain = <String, Set<String>>{};

    void collect(String mainId, List<String> savedSubIds) {
      if (!activeMainIds.contains(mainId) || mains.contains(mainId)) return;
      final activeMain = _cubit.catalog.firstWhere((cat) => cat.id == mainId);
      final activeSubIds =
          activeMain.subSpecializations.map((sub) => sub.id).toSet();
      mains.add(mainId);
      subsByMain[mainId] = {
        for (final id in savedSubIds)
          if (activeSubIds.contains(id)) id,
      };
    }

    if (cached.specializationsByMain.isNotEmpty) {
      for (final main in cached.specializationsByMain) {
        collect(main.id, [
          for (final sub in main.selectedSubSpecializations) sub.id
        ]);
      }
    } else if (cached.mainSpecializations.isNotEmpty) {
      for (final main in cached.mainSpecializations) {
        collect(main.id,
            [for (final sub in cached.subSpecializations) sub.id]);
      }
    }

    if (mains.isEmpty) return;

    // Map each saved lawsuit id to its sub via the fresh catalog, so
    // re-opening edit shows previously saved lawsuits as selected.
    final lawsuitsBySub = <String, Set<String>>{};
    for (final lawsuitId in cached.lawsuitTypeIds) {
      for (final cat in _cubit.catalog) {
        bool found = false;
        for (final sub in cat.subSpecializations) {
          if (sub.lawsuitTypes.any((l) => l.id == lawsuitId)) {
            lawsuitsBySub
                .putIfAbsent(sub.id, () => <String>{})
                .add(lawsuitId);
            found = true;
            break;
          }
        }
        if (found) break;
      }
    }

    _initialMains = mains;
    _initialSubsByMain = subsByMain;
    _initialLawsuitsBySub = lawsuitsBySub;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Pull-to-refresh: reloads catalog, keeps still-valid selections.
  Future<void> _onRefresh() async {
    await _cubit.loadSpecializations();
    if (!mounted) return;
    final state = _cubit.state;
    if (state is SpecializationsError) {
      setState(() => _loadError = state.message);
      return;
    }
    // Carry current selection forward as new prefill, rebuild selector.
    if (_selection != null && _selection!.mainIds.isNotEmpty) {
      _initialMains = List.of(_selection!.mainIds);
      final catalogById = {for (final c in _cubit.catalog) c.id: c};
      _initialSubsByMain = {
        for (final mainId in _selection!.mainIds)
          if (catalogById.containsKey(mainId))
            mainId: _selection!.subIds
                .where((subId) => catalogById[mainId]!
                    .subSpecializations
                    .any((s) => s.id == subId))
                .toSet(),
      };
      _initialLawsuitsBySub = {
        for (final e in _selection!.lawsuitsBySub.entries)
          e.key: Set.of(e.value),
      };
    }
    setState(() {
      _loadError = null;
      _selectorKey++;
    });
  }

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
            appBar: GeneralAppBar(title: 'إختر التخصص'),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Gap(8),
                  Expanded(child: _buildBody(theme)),
                  const Gap(12),
                  _buildSaveButton(theme),
                  const Gap(12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (!_ready) return _SpecializationsShimmer(theme: theme);

    if (_loadError != null && _cubit.catalog.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.colorScheme.primary,
        child: ListView(
          children: [
            SizedBox(height: 120.h),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 48, color: theme.colorScheme.error),
                  const Gap(12),
                  Text(_loadError!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error)),
                  const Gap(12),
                  TextButton.icon(
                    onPressed: _initialize,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_cubit.catalog.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.colorScheme.primary,
        child: ListView(
          children: [
            SizedBox(height: 120.h),
            Center(
              child: Text(
                'لم يتم العثور على تخصصات نشطة',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: theme.colorScheme.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          LawyerSpecializationsSelector(
            key: ValueKey(_selectorKey),
            catalog: _cubit.catalog
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
                .toList(),
            initialMains: _initialMains,
            initialSubsByMain: _initialSubsByMain,
            initialLawsuitsBySub: _initialLawsuitsBySub,
            onChanged: (sel) => setState(() => _selection = sel),
          ),
          if (_selection?.validationMessage != null &&
              (_selection?.mainIds.isNotEmpty ?? false)) ...[
            Gap(8.h),
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: theme.colorScheme.error),
                Gap(6.w),
                Expanded(
                  child: Text(
                    _selection!.validationMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return BlocBuilder<SpecializationsCubit, SpecializationsState>(
      builder: (context, state) {
        final isLoading = state is SaveSpecializationsLoading;
        final canSave =
            (_selection?.isValid ?? false) && !isLoading;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSave ? _save : null,
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
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
              elevation: WidgetStateProperty.all(0),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    'حفظ',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _SpecializationsShimmer extends StatelessWidget {
  const _SpecializationsShimmer({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Container(
                width: 50.h,
                height: 50.h,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      height: 11,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
