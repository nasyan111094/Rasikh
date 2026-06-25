// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/presentation/screens/reschedule_consultation_screen.dart
//
// Reschedule consultation screen — UI matches AddingWorkAppointmentScreen,
// logic preserved from original RescheduleConsultationScreen.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:size_config/size_config.dart';

import '../../Lawyer/consultation/Bloc/consultations_cubit.dart';
import '../../Lawyer/consultation/Bloc/consultations_states.dart';
import '../../Lawyer/consultation/models/consultation_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class RescheduleConsultationScreen extends StatefulWidget {
  const RescheduleConsultationScreen({
    super.key,
    required this.consultation,
  });

  /// The consultation to be rescheduled.
  final ConsultationModel consultation;

  @override
  State<RescheduleConsultationScreen> createState() =>
      _RescheduleConsultationScreenState();
}

class _RescheduleConsultationScreenState
    extends State<RescheduleConsultationScreen> {
  // ── Form state ────────────────────────────────────────────────────────────

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // ── Validation ────────────────────────────────────────────────────────────

  bool _showDateError = false;
  bool _showTimeError = false;

  // ── Saving guard ──────────────────────────────────────────────────────────

  bool _isSaving = false;

  // ── Prefill from existing consultation ────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final existing = widget.consultation.effectiveStartDateTime;
    if (existing != null) {
      final local = existing.toLocal();
      _selectedDate = DateTime(local.year, local.month, local.day);
      _selectedTime = TimeOfDay(hour: local.hour, minute: local.minute);
    }
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ar'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _showDateError = false;
      });
    }
  }

  // ── Time picker ───────────────────────────────────────────────────────────

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _showTimeError = false;
      });
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    final hasDate = _selectedDate != null;
    final hasTime = _selectedTime != null;

    if (!hasDate) setState(() => _showDateError = true);
    if (!hasTime) setState(() => _showTimeError = true);

    if (!hasDate || !hasTime) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                !hasDate
                    ? 'يرجى اختيار تاريخ الموعد الجديد'
                    : 'يرجى اختيار وقت الموعد الجديد',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

    // Build the new start DateTime (local) and convert to UTC for the API.
    final newStartLocal = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Must be in the future.
    if (!newStartLocal.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('يجب أن يكون الموعد الجديد في المستقبل'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (_isSaving) return; // prevent double-tap
    setState(() => _isSaving = true);

    final cubit = context.read<ConsultationsCubit>();

    // Listen for the next terminal reschedule state before calling the cubit
    // so we never miss an emission.
    final futureState = cubit.stream.firstWhere(
          (s) =>
      s is ConsultationRescheduled || s is ConsultationRescheduleError,
    );

    await cubit.rescheduleConsultation(
      consultationId: widget.consultation.id,
      newStartTime: newStartLocal,
    );

    final resultState = await futureState;
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (resultState is ConsultationRescheduled) {
      await _showSuccessDialog();
    } else if (resultState is ConsultationRescheduleError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(resultState.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ── Success dialog (matches AddingWorkAppointmentScreen._showSuccessDialog) ─

  Future<void> _showSuccessDialog() async {
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Auto-close after 2 seconds then pop both dialog and this screen.
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted) Navigator.pop(dialogContext);
          if (mounted) Navigator.pop(context);
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Check icon ───────────────────────────────────────────
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
                  'تم إعادة الجدولة بنجاح',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFAE895D),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'يمكنك مراجعة تفاصيل الاستشارة في أي وقت من صفحة الاستشارات.',
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String _formatTime(TimeOfDay t) {
    final hour = t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'مساءً' : 'صباحًا';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'instant':
        return 'استشارة فورية';
      case 'scheduled':
        return 'استشارة مجدولة';
      case 'written':
        return 'استشارة كتابية';
      default:
        return type;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'مساءً' : 'صباحًا';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}  $displayHour:$minute $period';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final hintColor = Colors.grey.shade500;
    final errorColor = theme.colorScheme.error;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: GeneralAppBar(title: 'إعادة جدولة الاستشارة'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(24.h),

              // ── Section title (matches AddingWorkAppointmentScreen style) ─
              Text(
                'اختر موعداً جديداً *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(16.h),

              // ── Date picker tile (styled like AddingWorkAppointmentScreen inputs) ─
              _PickerTile(
                icon: Icons.calendar_today_outlined,
                label: 'التاريخ',
                value: _selectedDate != null
                    ? _formatDate(_selectedDate!)
                    : null,
                placeholder: 'اختر التاريخ',
                hasError: _showDateError,
                errorColor: errorColor,
                primaryColor: primaryColor,
                hintColor: hintColor,
                borderColor: borderColor,
                onTap: _pickDate,
                theme: theme,
              ),

              Gap(12.h),

              // ── Time picker tile ─
              _PickerTile(
                icon: Icons.access_time_outlined,
                label: 'الوقت',
                value: _selectedTime != null
                    ? _formatTime(_selectedTime!)
                    : null,
                placeholder: 'اختر الوقت',
                hasError: _showTimeError,
                errorColor: errorColor,
                primaryColor: primaryColor,
                hintColor: hintColor,
                borderColor: borderColor,
                onTap: _pickTime,
                theme: theme,
              ),

              Gap(32.h),

              // ── Current appointment info (compact, styled like info section) ─
              _CurrentAppointmentInfo(
                consultation: widget.consultation,
                theme: theme,
                primaryColor: primaryColor,
                borderColor: borderColor,
              ),

              const Spacer(),

              // ── Save button (matches AddingWorkAppointmentScreen exactly) ─
              BlocBuilder<ConsultationsCubit, ConsultationsState>(
                buildWhen: (_, s) =>
                s is ConsultationRescheduling ||
                    s is ConsultationRescheduled ||
                    s is ConsultationRescheduleError,
                builder: (context, state) {
                  final loading =
                      _isSaving || state is ConsultationRescheduling;
                  return GradiantButton(
                    text: loading ? 'جاري الحفظ...' : 'تأكيد إعادة الجدولة',
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

// ─────────────────────────────────────────────────────────────────────────────
// Current appointment info — shows what's being rescheduled (compact version)
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentAppointmentInfo extends StatelessWidget {
  final ConsultationModel consultation;
  final ThemeData theme;
  final Color primaryColor;
  final Color borderColor;

  const _CurrentAppointmentInfo({
    required this.consultation,
    required this.theme,
    required this.primaryColor,
    required this.borderColor,
  });

  String _typeLabel(String type) {
    switch (type) {
      case 'instant':
        return 'استشارة فورية';
      case 'scheduled':
        return 'استشارة مجدولة';
      case 'written':
        return 'استشارة كتابية';
      default:
        return type;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'مساءً' : 'صباحًا';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}  $displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final startDt = consultation.effectiveStartDateTime;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14.w),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type label
          Text(
            _typeLabel(consultation.type),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          if (consultation.title.isNotEmpty) ...[
            Gap(4.h),
            Text(
              consultation.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 12.sp,
              ),
            ),
          ],
          Gap(12.h),
          // Current date/time row
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14.sp, color: Colors.grey.shade500),
              Gap(6.w),
              Text(
                'الموعد الحالي:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 12.sp,
                ),
              ),
              Gap(4.w),
              Expanded(
                child: Text(
                  _formatDateTime(startDt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Picker tile — reusable date/time selector row (matches AddingWorkAppointmentScreen style)
// ─────────────────────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final bool hasError;
  final Color errorColor;
  final Color primaryColor;
  final Color hintColor;
  final Color borderColor;
  final VoidCallback onTap;
  final ThemeData theme;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.hasError,
    required this.errorColor,
    required this.primaryColor,
    required this.hintColor,
    required this.borderColor,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder =
    hasError ? errorColor : (value != null ? primaryColor : borderColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: effectiveBorder),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: value != null ? primaryColor : hintColor,
            ),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasError ? errorColor : Colors.grey.shade500,
                      fontSize: 11.sp,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    value ?? placeholder,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null ? null : hintColor,
                      fontWeight: value != null ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: hintColor,
            ),
          ],
        ),
      ),
    );
  }
}