// ─────────────────────────────────────────────────────────────────────────────
// Multi-select city field shared by the lawyer registration flow
// (lawyer_personal_info_page) and the lawyer profile-edit screen
// (lawyer_edit_profile). A lawyer serves one OR MORE cities, so this replaces
// the single-value SearchableDropdown / DropdownButtonFormField that only
// allowed one.
//
// Cities are identified by their KEY while selecting (stable against label
// changes) but the value handed back to the caller — and sent to the backend —
// is the DISPLAY value, matching what the profile-edit flow already sent.
//
// Cities are fetched from GET /api/v1/enums/cities through
// LawyerCompletionRepo, with loading / error / retry handled internally so
// both call sites stay trivial.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:size_config/size_config.dart';

import 'package:rasikh/Shared/bottom_sheets/multi_selection_bottom_sheet.dart';
import 'package:rasikh/Shared/models/city_model.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/features/Lawyer/lawer_register_compilation/Repo/lawyer_register_complation_repo.dart';

class CitiesMultiSelectField extends StatefulWidget {
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  const CitiesMultiSelectField({
    super.key,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  State<CitiesMultiSelectField> createState() =>
      _CitiesMultiSelectFieldState();
}

class _CitiesMultiSelectFieldState extends State<CitiesMultiSelectField> {
  List<CityEnumModel> _cities = const [];
  bool _loading = true;
  String? _error;

  /// Selection is tracked by city KEY; the parent only deals with values.
  final Set<String> _selectedKeys = {};

  @override
  void initState() {
    super.initState();
    _restoreSelection();
    _loadCities();
  }

  @override
  void didUpdateWidget(CitiesMultiSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.selectedValues, widget.selectedValues)) {
      _restoreSelection();
    }
  }

  /// Maps the incoming display values back onto city keys so the sheet can
  /// restore the previous choice. Values that don't match any city yet (list
  /// still loading) are kept as-is rather than dropped.
  void _restoreSelection() {
    _selectedKeys
      ..clear()
      ..addAll(widget.selectedValues.map(_keyFor).where((k) => k != null).cast<String>());
  }

  String? _keyFor(String value) {
    for (final c in _cities) {
      if (c.value == value || c.key == value) return c.key;
    }
    return _cities.isEmpty ? value : null;
  }

  String _nameFor(String key) {
    for (final c in _cities) {
      if (c.key == key) return c.value;
    }
    return key;
  }

  Future<void> _loadCities() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await LawyerCompletionRepo().getCities();
      if (!mounted) return;
      result.fold(
        (err) => setState(() {
          _error = err.isEmpty ? Loc.unableToLoadCities() : err;
          _loading = false;
        }),
        (list) => setState(() {
          _cities = list;
          _loading = false;
          // Now that cities are known, re-resolve keys against real data.
          _restoreSelection();
        }),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openSheet() {
    if (_loading || _error != null || _cities.isEmpty) return;
    showMultiSelectionBottomSheet(
      context: context,
      builder: (_) => MultiSelectionBottomSheet<CityEnumModel>(
        title: Loc.chooseCity(),
        searchHint: Loc.searchCity(),
        items: _cities,
        emptyIcon: Icons.location_city_outlined,
        emptyTitle: Loc.noCitiesAvailable(),
        selectedIds: _selectedKeys,
        confirmText: Loc.confirm(),
        itemId: (c) => c.key,
        itemName: (c) => c.value,
        onConfirm: (picked) {
          setState(() {
            _selectedKeys
              ..clear()
              ..addAll(picked.map((c) => c.key));
          });
          widget.onChanged(picked.map((c) => c.value).toList());
        },
      ),
    );
  }

  String get _displayText {
    if (_selectedKeys.isEmpty) return '';
    final names = _selectedKeys.map(_nameFor).toList();
    if (names.length <= 2) return names.join('، ');
    return '${names.take(2).join('، ')} +${names.length - 2}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return SizedBox(
        height: 56.h,
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline,
                color: theme.colorScheme.error, size: 20.w),
            Gap(8.w),
            Expanded(
              child: Text(
                Loc.unableToLoadCities(),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: _loadCities,
              child: Text(Loc.retryAgain()),
            ),
          ],
        ),
      );
    }

    final hasSelection = _selectedKeys.isNotEmpty;

    return GestureDetector(
      onTap: _openSheet,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasSelection
                ? theme.colorScheme.primary.withOpacity(0.5)
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12.h),
          color: hasSelection
              ? theme.colorScheme.primary.withOpacity(0.03)
              : null,
        ),
        child: Row(
          children: [
            Picture(
              getAssetIcon('City.svg'),
              width: 22.w,
              height: 22.w,
              color: hasSelection
                  ? theme.colorScheme.primary
                  : theme.hintColor,
            ),
            Gap(10.w),
            Expanded(
              child: Text(
                hasSelection ? _displayText : Loc.chooseCity(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: hasSelection ? Colors.black : theme.hintColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.expand_more_rounded, color: theme.hintColor, size: 20.sp),
          ],
        ),
      ),
    );
  }
}