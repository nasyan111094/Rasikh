import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/features/Lawyer/lawyer-appointments/widgets/weekly_repeat_switch.dart';
import 'package:size_config/size_config.dart';

import 'date_picker_field.dart';
import 'dropdown_field.dart';

class SessionSettingsWidget extends StatefulWidget {
  const SessionSettingsWidget({
    super.key,
    this.initialStart,
    this.initialEnd,
    this.initialDuration,
    this.initialGap,
    this.initialRepeatsWeekly,
    this.onChanged,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;
  final int? initialDuration;
  final int? initialGap;
  final bool? initialRepeatsWeekly;
  final ValueChanged<SessionSettings>? onChanged;

  @override
  State<SessionSettingsWidget> createState() => _SessionSettingsWidgetState();
}

class _SessionSettingsWidgetState extends State<SessionSettingsWidget> {
  // ── State owned here — initialised once in initState ─────────────────────
  DateTime? _startDate;
  DateTime? _endDate;
  late int _sessionDuration;
  late int _sessionGap;
  late bool _isWeeklyRepeat;

  // ── Time validation ───────────────────────────────────────────────────────
  String? _timeError;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
    _sessionDuration = widget.initialDuration ?? 30;
    _sessionGap = widget.initialGap ?? 10;
    _isWeeklyRepeat = widget.initialRepeatsWeekly ?? false;
  }

  /// If the parent re-renders with new initial values (async prefill from
  /// cached slot data), absorb those values.
  @override
  void didUpdateWidget(SessionSettingsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool changed = false;

    if (widget.initialStart != oldWidget.initialStart &&
        widget.initialStart != null) {
      _startDate = widget.initialStart;
      changed = true;
    }
    if (widget.initialEnd != oldWidget.initialEnd &&
        widget.initialEnd != null) {
      _endDate = widget.initialEnd;
      changed = true;
    }
    if (widget.initialDuration != oldWidget.initialDuration &&
        widget.initialDuration != null) {
      _sessionDuration = widget.initialDuration!;
      changed = true;
    }
    if (widget.initialGap != oldWidget.initialGap &&
        widget.initialGap != null) {
      _sessionGap = widget.initialGap!;
      changed = true;
    }
    if (widget.initialRepeatsWeekly != oldWidget.initialRepeatsWeekly &&
        widget.initialRepeatsWeekly != null) {
      _isWeeklyRepeat = widget.initialRepeatsWeekly!;
      changed = true;
    }

    if (changed) setState(() {});
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _validateTimes(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (!end.isAfter(start)) {
      return 'يجب أن يكون وقت النهاية بعد وقت البداية';
    }
    return null;
  }

  void _notify() {
    widget.onChanged?.call(SessionSettings(
      startDate: _startDate,
      endDate: _endDate,
      sessionDuration: _sessionDuration,
      gap: _sessionGap,
      repeatsWeekly: _isWeeklyRepeat,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Start / End time row ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  label: 'إختر وقت البداية *',
                  value: _startDate,
                  onSelect: (d) {
                    setState(() {
                      _startDate = d;
                      _timeError = _validateTimes(_startDate, _endDate);
                    });
                    _notify();
                  },
                ),
              ),
              Gap(12.w),
              Expanded(
                child: DatePickerField(
                  label: 'إختر وقت النهاية *',
                  value: _endDate,
                  onSelect: (d) {
                    setState(() {
                      _endDate = d;
                      _timeError = _validateTimes(_startDate, _endDate);
                    });
                    _notify();
                  },
                ),
              ),
            ],
          ),

          // ── Inline time error ───────────────────────────────────────────
          if (_timeError != null) ...[
            Gap(6.h),
            Row(
              children: [
                Icon(Icons.error_outline,
                    color: theme.colorScheme.error, size: 14.sp),
                Gap(4.w),
                Text(
                  _timeError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],



/*          // ── Session duration / gap row ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: DropdownField<int>(
                  label: 'مدة الجلسة *',
                  value: _sessionDuration,
                  items: const [15, 30, 45, 60],
                  unit: 'دقيقة',
                  onChanged: (v) {
                    setState(() => _sessionDuration = v!);
                    _notify();
                  },
                ),
              ),
              Gap(12.w),
              Expanded(
                child: DropdownField<int>(
                  label: 'الفاصل بين الجلسات *',
                  value: _sessionGap,
                  items: const [5, 10, 15, 20],
                  unit: 'دقائق',
                  onChanged: (v) {
                    setState(() => _sessionGap = v!);
                    _notify();
                  },
                ),
              ),
            ],
          ),*/

          Gap(40.h),

          // ── Weekly repeat ───────────────────────────────────────────────
          WeeklyRepeatSwitch(
            value: _isWeeklyRepeat,
            onChanged: (v) {
              setState(() => _isWeeklyRepeat = v);
              _notify();
            },
          ),
        ],
      ),
    );
  }
}

// ── Value object ──────────────────────────────────────────────────────────────

class SessionSettings {
  final DateTime? startDate;
  final DateTime? endDate;
  final int sessionDuration;
  final int gap;
  final bool repeatsWeekly;

  const SessionSettings({
    required this.startDate,
    required this.endDate,
    required this.sessionDuration,
    required this.gap,
    required this.repeatsWeekly,
  });
}