import 'package:rasikh/config/localization/loc_keys.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;
  late int _sessionDuration;
  late int _sessionGap;
  late bool _isWeeklyRepeat;

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


  String? _validateTimes(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (!end.isAfter(start)) {
      return Loc.endTimeMustBeAfterStart();
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  label: Loc.chooseStartTimeRequired(),
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
                  label: Loc.chooseEndTimeRequired(),
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




          Gap(40.h),

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