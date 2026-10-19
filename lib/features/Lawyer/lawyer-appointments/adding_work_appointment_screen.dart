import 'package:rasikh/config/localization/loc_keys.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:size_config/size_config.dart';

import 'bloc/lawyer_appointments_cubit.dart';
import 'bloc/lawyer_appointments_state.dart';
import 'models/availability_slot_model.dart';
import 'widgets/day_selection_section.dart';
import 'widgets/session_settings_widget.dart';

class AddingWorkAppointmentScreen extends StatefulWidget {
  const AddingWorkAppointmentScreen({
    super.key,
    this.slotId,
    this.initialSlot,
    this.dayIndex,
  });

  final String? slotId;

  final AvailabilitySlot? initialSlot;

  final int? dayIndex;

  @override
  State<AddingWorkAppointmentScreen> createState() =>
      _AddingWorkAppointmentScreenState();
}

class _AddingWorkAppointmentScreenState
    extends State<AddingWorkAppointmentScreen> {
  final Set<int> _selectedDayIndexes = {};
  late SessionSettings _sessionSettings;

  bool _showDayError = false;

  bool _isSaving = false;
  // Manual subscription (if ever used) is cancelled in dispose;
  // the BlocListener below auto-cancels on widget disposal.
  StreamSubscription<LawyerAppointmentsState>? _slotSub;

  @override
  void initState() {
    super.initState();
    _sessionSettings = const SessionSettings(
      startDate: null,
      endDate: null,
      sessionDuration: 30,
      gap: 10,
      repeatsWeekly: false,
    );

    if (widget.initialSlot != null && widget.dayIndex != null) {
      _prefillFromSlot(widget.initialSlot!, widget.dayIndex!);
    } else if (widget.slotId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromCache());
    }
  }

  void _prefillFromSlot(AvailabilitySlot slot, int serverDayIndex) {
    final upcomingIndex = _upcomingIndexForServerDay(serverDayIndex);

    _selectedDayIndexes
      ..clear()
      ..addAll(upcomingIndex != null ? {upcomingIndex} : <int>{});

    _sessionSettings = SessionSettings(
      startDate: _parseTime(slot.startTime),
      endDate: _parseTime(slot.endTime),
      sessionDuration: slot.sessionDurationMinutes,
      gap: slot.gapMinutes,
      repeatsWeekly: slot.repeatsWeekly,
    );
  }

  int? _upcomingIndexForServerDay(int serverDayIndex) {
    for (int i = 0; i < 7; i++) {
      final d = DateTime.now().add(Duration(days: i));
      if ((d.weekday + 1) % 7 == serverDayIndex) return i;
    }
    return null;
  }

  DateTime? _parseTime(String t) {
    try {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, h, m);
    } catch (_) {
      return null;
    }
  }

  void _prefillFromCache() {
    if (!mounted) return;
    final cubit = context.read<LawyerAppointmentsCubit>();
    final cached = cubit.cachedWeeklyData;
    if (cached == null) return;

    AvailabilitySlot? found;
    int? serverDayIndex;
    for (final day in cached.days) {
      for (final s in day.slots) {
        if (s.id == widget.slotId) {
          found = s;
          serverDayIndex = day.dayIndex;
        }
      }
    }
    if (found == null || serverDayIndex == null) return;

    setState(() => _prefillFromSlot(found!, serverDayIndex!));
  }


  Future<void> _onSave() async {
    final hasDay = _selectedDayIndexes.isNotEmpty;
    final hasStart = _sessionSettings.startDate != null;
    final hasEnd = _sessionSettings.endDate != null;
    final timesValid = hasStart &&
        hasEnd &&
        _sessionSettings.endDate!.isAfter(_sessionSettings.startDate!);

    if (!hasDay) {
      setState(() => _showDayError = true);
    }

    if (!hasDay || !hasStart || !hasEnd || !timesValid) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                !hasDay
                    ? Loc.pleaseSelectAtLeastOneDay()
                    : !hasStart || !hasEnd
                    ? Loc.pleaseSetStartAndEndTime()
                    : Loc.endTimeMustBeAfterStart(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

    // Reject only when EVERY selected day is already in the past.
    //
    // [startDate] is a wall-clock time packed into TODAY's date (the picker
    // only returns hours/minutes), while the real calendar day comes from the
    // selected weekday offsets. Comparing it against `now` directly would
    // reject valid slots — picking 09:00 for tomorrow while it is 10:00 today
    // looked "past" even though tomorrow 09:00 is still ahead.
    if (!_hasUpcomingOccurrence(_sessionSettings.startDate!)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(Loc.newAppointmentMustBeInFuture()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

    if (_isSaving) return;

    // TODO(backend-contract): dayIndex mapping ((weekday+1)%7) and the
    // duration/gap payload shape are server contracts — do not change.
    final daysOfWeek = _selectedDayIndexes.map((i) {
      final date = DateTime.now().add(Duration(days: i));
      return (date.weekday + 1) % 7;
    }).toList();

    final startTime = _formatTime(_sessionSettings.startDate!);
    final endTime = _formatTime(_sessionSettings.endDate!);

    // Validate against existing cachedWeeklyData.days[].slots for overlap
    // on the same daysOfWeek.
    final overlap = _hasOverlap(daysOfWeek, startTime, endTime);
    if (overlap) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              // TODO(l10n): add Loc key for overlapping slot error
              content: Text('الموعد يتداخل مع موعد موجود في نفس الأيام'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

    setState(() => _isSaving = true);

    final request = SlotRequestModel(
      daysOfWeek: daysOfWeek,
      startTime: startTime,
      endTime: endTime,
      repeatsWeekly: _sessionSettings.repeatsWeekly,
    );

    final cubit = context.read<LawyerAppointmentsCubit>();

    // Result is delivered via the BlocListener in build (no manual
    // stream.firstWhere — avoids leaked subscriptions).
    if (widget.slotId == null) {
      await cubit.createSlot(request: request);
    } else {
      await cubit.updateSlot(slotId: widget.slotId!, request: request);
    }
  }

  int _toMinutes(String t) {
    final parts = t.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  bool _hasOverlap(List<int> daysOfWeek, String start, String end) {
    final cached = context.read<LawyerAppointmentsCubit>().cachedWeeklyData;
    if (cached == null) return false;
    final s = _toMinutes(start);
    final e = _toMinutes(end);
    for (final day in cached.days) {
      if (!daysOfWeek.contains(day.dayIndex)) continue;
      if (widget.slotId != null &&
          day.slots.length == 1 &&
          day.slots.first.id == widget.slotId) {
        continue; // editing the only slot of that day — not an overlap
      }
      for (final slot in day.slots) {
        if (widget.slotId != null && slot.id == widget.slotId) continue;
        try {
          final os = _toMinutes(slot.startTime);
          final oe = _toMinutes(slot.endTime);
          if (s < oe && os < e) return true;
        } catch (_) {
          continue;
        }
      }
    }
    return false;
  }

  String _formatTime(DateTime dt) {
    dt = dt .toLocal() ;
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}';
  }

  /// Builds the real timestamp of the slot for one selected day offset
  /// ([dayIndex] = 0 is today, 1 is tomorrow, ...), using [timeOfDay] only
  /// for its hour/minute — the calendar date comes from the day offset.
  DateTime _occurrenceOnDay(int dayIndex, DateTime timeOfDay) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day)
        .add(Duration(days: dayIndex));
    return DateTime(
        date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }

  /// True when at least one selected day still has a start time ahead of now.
  bool _hasUpcomingOccurrence(DateTime timeOfDay) {
    final now = DateTime.now();
    return _selectedDayIndexes
        .map((i) => _occurrenceOnDay(i, timeOfDay))
        .any((occurrence) => occurrence.isAfter(now));
  }


  Future<void> _showSuccessDialog(String title) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted) Navigator.pop(dialogContext);
          if (mounted) Navigator.pop(context);
        });

        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2E7D32),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFAE895D),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  Loc.reviewAppointmentDetailsAnytime(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.slotId != null;

    return BlocListener<LawyerAppointmentsCubit, LawyerAppointmentsState>(
      listener: (context, state) async {
        if (state is SlotCreatedSuccess || state is SlotUpdatedSuccess) {
          if (!mounted) return;
          setState(() => _isSaving = false);
          final msg = state is SlotCreatedSuccess
              ? state.message
              : (state as SlotUpdatedSuccess).message;
          await _showSuccessDialog(msg);
        } else if (state is SlotMutationError) {
          if (!mounted) return;
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: Scaffold(
      appBar: GeneralAppBar(
        title: isEdit ? Loc.editWorkAppointment() : Loc.addWorkAppointment(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(24.h),

              Row(
                children: [
                  Text(
                    Loc.chooseDayOrDaysRequired(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_showDayError) ...[
                    Gap(8.w),
                    Text(
                      Loc.requiredInParentheses(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              Gap(12.h),

              DaySelectionSection(
                initialSelected: _selectedDayIndexes,
                onChanged: (s) {
                  setState(() {
                    _showDayError = s.isEmpty;
                    _selectedDayIndexes
                      ..clear()
                      ..addAll(s);
                  });
                },
              ),

              Gap(40.h),

              Expanded(
                child: SessionSettingsWidget(
                  initialStart: _sessionSettings.startDate,
                  initialEnd: _sessionSettings.endDate,
                  initialDuration: _sessionSettings.sessionDuration,
                  initialGap: _sessionSettings.gap,
                  initialRepeatsWeekly: _sessionSettings.repeatsWeekly,
                  onChanged: (s) => _sessionSettings = s,
                ),
              ),

              Gap(20.h),

              BlocBuilder<LawyerAppointmentsCubit, LawyerAppointmentsState>(
                buildWhen: (_, s) =>
                s is SlotMutationLoading || s is SlotCreatedSuccess ||
                    s is SlotUpdatedSuccess || s is SlotMutationError ||
                    s is LawyerAppointmentsLoaded,
                builder: (context, state) {
                  final loading =
                      _isSaving || state is SlotMutationLoading;
                  return GradiantButton(
                    text: loading
                        ? Loc.saving()
                        : isEdit
                        ? Loc.saveChanges()
                        : Loc.saveAppointment(),
                    onTap: loading ? () {} : _onSave,
                  );
                },
              ),

              Gap(16.h),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  void dispose() {
    _slotSub?.cancel();
    super.dispose();
  }
}