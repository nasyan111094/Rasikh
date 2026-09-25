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

  /// Non-null when editing an existing slot.
  final String? slotId;

  /// The slot being edited, passed straight from the list item that was
  /// tapped. When present, prefill is instant and 100% reliable — it does
  /// NOT depend on the cubit's cached weekly data still being warm.
  final AvailabilitySlot? initialSlot;

  /// Server day index (0=Sat … 6=Fri) the slot above belongs to.
  final int? dayIndex;

  @override
  State<AddingWorkAppointmentScreen> createState() =>
      _AddingWorkAppointmentScreenState();
}

class _AddingWorkAppointmentScreenState
    extends State<AddingWorkAppointmentScreen> {
  // ── Form state ────────────────────────────────────────────────────────────
  final Set<int> _selectedDayIndexes = {};
  late SessionSettings _sessionSettings;

  // ── Validation ────────────────────────────────────────────────────────────
  bool _showDayError = false;

  // ── Saving guard ──────────────────────────────────────────────────────────
  bool _isSaving = false;

  // ── Prefill (edit mode) ───────────────────────────────────────────────────

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
      // Preferred path: data was handed to us directly by the list item,
      // so we fill the form synchronously before the very first frame.
      _prefillFromSlot(widget.initialSlot!, widget.dayIndex!);
    } else if (widget.slotId != null) {
      // Legacy fallback for any call site that still only passes a slotId.
      // Best-effort only — if the cache isn't warm yet, the form simply
      // stays empty and the user fills it in manually (no silent corruption
      // of data, no crash).
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromCache());
    }
  }

  /// Fills the form straight from the slot the user tapped — no cache,
  /// no race condition, no flash of an empty form.
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

  /// Maps a server day index (0=Sat … 6=Fri) to its "upcoming day" index
  /// (0 = today … 6 = six days from now) — the same convention the day
  /// picker UI uses.
  int? _upcomingIndexForServerDay(int serverDayIndex) {
    for (int i = 0; i < 7; i++) {
      final d = DateTime.now().add(Duration(days: i));
      if ((d.weekday + 1) % 7 == serverDayIndex) return i;
    }
    return null;
  }

  /// Parses an "HH:mm" string into a [DateTime] (date portion = today, only
  /// hour/minute are meaningful).
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

  /// Legacy fallback: looks the slot up in whatever weekly data happens to
  /// already be cached in the cubit. Only used when the caller didn't pass
  /// [initialSlot] directly.
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

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    // ── Validation ──────────────────────────────────────────────────────────
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
                    ? 'يرجى اختيار يوم واحد على الأقل'
                    : !hasStart || !hasEnd
                    ? 'يرجى تحديد وقت البداية والنهاية'
                    : 'يجب أن يكون وقت النهاية بعد وقت البداية',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

    if (_isSaving) return; // prevent double-tap
    setState(() => _isSaving = true);

    // ── Build API day list ───────────────────────────────────────────────────
    // API expects 0=Saturday … 6=Friday.  weekday: Mon=1 … Sun=7 → (weekday+1)%7
    final daysOfWeek = _selectedDayIndexes.map((i) {
      final date = DateTime.now().add(Duration(days: i));
      return (date.weekday + 1) % 7;
    }).toList();

    final startTime = _formatTime(_sessionSettings.startDate!);
    final endTime = _formatTime(_sessionSettings.endDate!);

    final request = SlotRequestModel(
      daysOfWeek: daysOfWeek,
      startTime: startTime,
      endTime: endTime,
      repeatsWeekly: _sessionSettings.repeatsWeekly,
    );

    final cubit = context.read<LawyerAppointmentsCubit>();

    // Listen for the next terminal mutation state before calling the cubit
    // so we never miss an emission.
    final futureState = cubit.stream.firstWhere(
          (s) =>
      s is SlotCreatedSuccess ||
          s is SlotUpdatedSuccess ||
          s is SlotMutationError,
    );

    if (widget.slotId == null) {
      await cubit.createSlot(request: request);
    } else {
      await cubit.updateSlot(slotId: widget.slotId!, request: request);
    }

    final resultState = await futureState;
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (resultState is SlotCreatedSuccess) {
      await _showSuccessDialog(resultState.message);
    } else if (resultState is SlotUpdatedSuccess) {
      await _showSuccessDialog(resultState.message);
    }
    // SlotMutationError — the listener in LawyerAppointmentsScreen shows a snackbar.
    // We just stay on-screen so the user can correct and retry.
  }

  String _formatTime(DateTime dt) {
    dt = dt .toLocal() ;
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}';
  }

  // ── Success dialog ────────────────────────────────────────────────────────

  Future<void> _showSuccessDialog(String title) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Auto-close after 2 seconds
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
                // ── Check icon ────────────────────────────────────────────
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
                  'يمكنك مراجعة تفاصيل الموعد في أي وقت من صفحة المواعيد.',
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.slotId != null;

    return Scaffold(
      appBar: GeneralAppBar(
        title: isEdit ? 'تعديل موعد العمل' : 'إضافة موعد عمل',
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(24.h),

              // ── Day selection header ────────────────────────────────────
              Row(
                children: [
                  Text(
                    'إختر اليوم أو الأيام *',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_showDayError) ...[
                    Gap(8.w),
                    Text(
                      '(مطلوب)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              Gap(12.h),

              // ── Day picker ──────────────────────────────────────────────
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

              // ── Session settings ────────────────────────────────────────
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

              // ── Save button ─────────────────────────────────────────────
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
                        ? 'جاري الحفظ...'
                        : isEdit
                        ? 'حفظ التعديلات'
                        : 'حفظ الموعد',
                    onTap: loading ? () {} : _onSave,
                  );
                },
              ),

              Gap(16.h),
            ],
          ),
        ),
      ),
    );
  }
}