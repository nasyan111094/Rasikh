// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/specializations/presentation/screens/
//   lawyer_specializations_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../../../../core/get_it_service/get_it_service.dart';
import '../bloc/Profile_cubit/lawyer_cubit.dart';
import '../bloc/Specializations_cubit/specializations_cubit.dart';
import '../bloc/Specializations_cubit/specializations_state.dart';
import '../models/specialization_catalog_model.dart';

class LawyerSpecializationsScreen extends StatefulWidget {
  const LawyerSpecializationsScreen({Key? key}) : super(key: key);

  @override
  State<LawyerSpecializationsScreen> createState() =>
      _LawyerSpecializationsScreenState();
}

class _LawyerSpecializationsScreenState
    extends State<LawyerSpecializationsScreen> {
  late final SpecializationsCubit _cubit = getIt<SpecializationsCubit>();

  final Map<String, Set<String>> _selections = {};
  final Set<String> _expandedIds = {};
  final TextEditingController _searchController = TextEditingController();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cubit.loadSpecializations();
    _prefillFromProfile();
  }

  void _prefillFromProfile() {
    final cached = context.read<LawyerProfileCubit>().cachedProfile;
    if (cached == null) return;

    if (cached.specializationsByMain.isNotEmpty) {
      for (final main in cached.specializationsByMain) {
        _selections[main.id] = {
          for (final sub in main.selectedSubSpecializations) sub.id,
        };
        _expandedIds.add(main.id);
      }
    } else {
      if (cached.mainSpecializations.isNotEmpty) {
        final mainId = cached.mainSpecializations.first.id;
        _selections[mainId] = {
          for (final sub in cached.subSpecializations) sub.id,
        };
        _expandedIds.add(mainId);
      }
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────────────────

  bool get _canProceed =>
      _selections.isNotEmpty &&
          _selections.values.every((subs) => subs.isNotEmpty);

  List<SpecializationCatalogModel> _filtered(
      List<SpecializationCatalogModel> all) {
    final q = _searchController.text.trim();
    if (q.isEmpty) return all;
    return all
        .where((cat) =>
    cat.name.contains(q) ||
        cat.subSpecializations.any((s) => s.name.contains(q)))
        .toList();
  }

  // ── Selection helpers ──────────────────────────────────────────────────────

  bool _isMainSelected(String mainId) => _selections.containsKey(mainId);

  bool _isSubSelected(String mainId, String subId) =>
      _selections[mainId]?.contains(subId) ?? false;

  void _toggleMain(String mainId) {
    setState(() {
      if (_isMainSelected(mainId)) {
        _selections.remove(mainId);
        _expandedIds.remove(mainId);
      } else {
        _selections[mainId] = {};
        _expandedIds.add(mainId);
      }
    });
  }

  void _toggleSub(String mainId, String subId) {
    setState(() {
      _selections.putIfAbsent(mainId, () => {});
      if (_selections[mainId]!.contains(subId)) {
        _selections[mainId]!.remove(subId);
      } else {
        _selections[mainId]!.add(subId);
      }
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String _) {
    _cubit.loadSpecializations(search: _searchController.text.trim());
    setState(() {});
  }

  /// Pull-to-refresh: clears search and reloads from scratch.
  Future<void> _onRefresh() async {
    _searchController.clear();
    await _cubit.loadSpecializations();
  }

  void _save() {
    if (!_canProceed) return;
    _cubit.saveSpecializations(
      mainSpecializationIds: _selections.keys.toList(),
      subSpecializationIds: _selections.values.expand((s) => s).toList(),
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
                  _buildSearchBar(theme),
                  const Gap(8),
                  if (_selections.isNotEmpty) _buildSelectionSummary(theme),
                  if (_selections.isNotEmpty) const Gap(8),
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

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildSelectionSummary(ThemeData theme) {
    final mainCount = _selections.length;
    final subCount = _selections.values.fold<int>(0, (s, v) => s + v.length);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              size: 16, color: theme.colorScheme.primary),
          const Gap(6),
          Text(
            '$mainCount ${mainCount == 1 ? 'تخصص رئيسي' : 'تخصصات رئيسية'}'
                ' · $subCount فرعي',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (_selections.values.any((s) => s.isEmpty))
            Tooltip(
              message: 'اختر تخصصًا فرعيًا لكل تخصص رئيسي محدد',
              child: Icon(Icons.warning_amber_rounded,
                  size: 16, color: theme.colorScheme.error),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return BlocBuilder<SpecializationsCubit, SpecializationsState>(
      builder: (context, state) {
        // ── Shimmer skeleton on first load ───────────────────────────────────
        if (state is SpecializationsLoading) {
          return _SpecializationsShimmer(theme: theme);
        }

        // ── Error ────────────────────────────────────────────────────────────
        if (state is SpecializationsError) {
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
                      Text(state.message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.error)),
                      const Gap(12),
                      TextButton.icon(
                        onPressed: () =>
                            _cubit.loadSpecializations(),
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

        final filtered = _filtered(_cubit.catalog);

        // ── Empty ────────────────────────────────────────────────────────────
        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: theme.colorScheme.primary,
            child: ListView(
              children: [
                SizedBox(height: 120.h),
                Center(
                  child: Text(
                    'لم يتم العثور على نتائج',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        // ── Data list with pull-to-refresh ───────────────────────────────────
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: theme.colorScheme.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _buildCategoryTile(theme, filtered[i]),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'ادخل كلمة مفتاحية مثل تنفيذ أو أموال ...',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildCategoryTile(
      ThemeData theme, SpecializationCatalogModel category) {
    final isSelected = _isMainSelected(category.id);
    final isExpanded = _expandedIds.contains(category.id);
    final subSelectedCount = _selections[category.id]?.length ?? 0;
    final isHighlighted = isSelected || isExpanded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? theme.colorScheme.primary.withOpacity(0.6)
              : theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(category.id),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) {
                _expandedIds.add(category.id);
              } else {
                _expandedIds.remove(category.id);
              }
            });
          },
          trailing: Checkbox(
            value: isSelected,
            tristate: false,
            activeColor: theme.colorScheme.primary,
            side: BorderSide(
              color:
              isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
            onChanged: (_) => _toggleMain(category.id),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isHighlighted
                        ? theme.colorScheme.primary.withOpacity(0.6)
                        : theme.dividerColor,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Picture(
                  getAssetIcon('chat.svg'),
                  width: 40.h,
                  height: 40.h,
                  color: isHighlighted
                      ? theme.colorScheme.primary.withOpacity(0.6)
                      : theme.dividerColor,
                ),
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHighlighted
                        ? theme.colorScheme.primary
                        : theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: isSelected && subSelectedCount > 0
                ? Text(
              'تم اختيار $subSelectedCount تخصص فرعي',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            )
                : Text(
              '${category.subSpecializationsCount} تخصص فرعي',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor),
            ),
          ),
          children: [
            if (category.subSpecializations.isNotEmpty)
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
                      children: category.subSpecializations.map((sub) {
                        final selected = _isSubSelected(category.id, sub.id);
                        return GestureDetector(
                          onTap: () => _toggleSub(category.id, sub.id),
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

  Widget _buildSaveButton(ThemeData theme) {
    return BlocBuilder<SpecializationsCubit, SpecializationsState>(
      builder: (context, state) {
        final isLoading = state is SaveSpecializationsLoading;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_canProceed && !isLoading) ? _save : null,
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
// Shimmer skeleton — mirrors the real tile layout exactly
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
        itemBuilder: (_, __) => _ShimmerTile(),
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Circle icon placeholder ──────────────────────────────────────
          Container(
            width: 50.h,
            height: 50.h,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(12),
          // ── Title + subtitle placeholders ────────────────────────────────
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
          const Gap(12),
          // ── Checkbox placeholder ─────────────────────────────────────────
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}