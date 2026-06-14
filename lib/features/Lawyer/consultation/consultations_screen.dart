// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/presentation/screens/consultations_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/features/Lawyer/consultation/widgets/consultation_shimmer.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/bloc/Profile_cubit/lawyer_cubit.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/widgets/app_bar_without_icon_button.dart';
import '../../../../core/widgets/general_divider.dart';
import '../../../../core/widgets/gradiant_button.dart';
import '../../../config/navigation/nav.dart';
import 'Bloc/consultation_details_cubit.dart';
import 'Bloc/consultations_cubit.dart';
import 'Bloc/consultations_states.dart';
import 'consultation_details_screen.dart';
import 'models/consultation_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class LawerConsultationsScreen extends StatefulWidget {
  const LawerConsultationsScreen({super.key});

  @override
  State<LawerConsultationsScreen> createState() =>
      _LawerConsultationsScreenState();
}

class _LawerConsultationsScreenState extends State<LawerConsultationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ConsultationsCubit>().fetchConsultations();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll listener: trigger pagination near the bottom ──────────────────

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<ConsultationsCubit>().loadMoreConsultations();
    }
  }

  Future<void> _onRefresh() =>
      context.read<ConsultationsCubit>().refreshConsultations();

  void _openFilterSheet(ConsultationStatus current) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(
        selected: current,
        onApply: (status) {
          Navigator.pop(context);
          context.read<ConsultationsCubit>().applyFilter(status);
        },
      ),
    );
  }

  void _navigateToDetails(BuildContext context, ConsultationModel item) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ConsultationDetailsCubit(
            repo: context.read<ConsultationsCubit>().repo,
          ),
          child: LawyerConsultationDetailsScreen(consultationId: item.id),
        ),
      ),
    );
  }

  // ── State helpers ─────────────────────────────────────────────────────────

  ConsultationStatus _resolveStatus(ConsultationsState state) {
    if (state is ConsultationsLoaded) return state.selectedStatus;
    if (state is ConsultationsRefreshing) return state.selectedStatus;
    if (state is ConsultationsPaginating) return state.selectedStatus;
    if (state is ConsultationsEmpty) return state.selectedStatus;
    if (state is ConsultationsError) return state.selectedStatus;
    return ConsultationStatus.none;
  }

  List<ConsultationModel> _resolveConsultations(ConsultationsState state) {
    if (state is ConsultationsLoaded) return state.consultations;
    if (state is ConsultationsRefreshing) return state.currentConsultations;
    if (state is ConsultationsPaginating) return state.currentConsultations;
    return [];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarWithoutBackIconButton(theme: theme, title: 'إستشاراتي'),
            // Filter header always reflects the active status chip.
            BlocBuilder<ConsultationsCubit, ConsultationsState>(
              builder: (context, state) {
                final status = _resolveStatus(state);
                return _FilterHeader(
                  selectedStatus: status,
                  onFilterTap: () => _openFilterSheet(status),
                );
              },
            ),
            GeneralDivider(height: 10.h),
            Expanded(
              child: BlocBuilder<ConsultationsCubit, ConsultationsState>(
                builder: (context, state) =>
                    _buildBody(context, state, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ConsultationsState state,
      ThemeData theme,
      ) {
    if (state is ConsultationsLoading) {
      return const ConsultationsListShimmer();
    }

    if (state is ConsultationsError) {
      return _ErrorView(
        message: state.message,
        onRetry: () =>
            context.read<ConsultationsCubit>().fetchConsultations(),
      );
    }

    if (state is ConsultationsEmpty) {
      return _EmptyView(status: state.selectedStatus);
    }

    final consultations = _resolveConsultations(state);
    final isPaginating = state is ConsultationsPaginating;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: consultations.length + (isPaginating ? 1 : 0),
        itemBuilder: (context, index) {
          // Last slot: pagination shimmer card.
          if (index == consultations.length) {
            return const ConsultationCardShimmer();
          }
          final item = consultations[index];
          return _ConsultationCard(
            consultation: item,
            onTap: ()
            {
              if(item.isActive == true)
                {
                  if(item.type == "written")
                    {
                      Nav.chat(context, consultationId: item.id , clientId: item.client?.id , lawyerId: getIt<LawyerProfileCubit>().cachedProfile?.id , lawyerName: getIt<LawyerProfileCubit>().cachedProfile?.fullName , lawyerPhotoUrl: getIt<LawyerProfileCubit>().cachedProfile?.photoUrl  ) ;
                    }
                  else
                    {
                     Nav.videoCallScreen(context, consultationId: item.id , clientId: item.client?.id , lawyerId: getIt<LawyerProfileCubit>().cachedProfile?.id , lawyerName: getIt<LawyerProfileCubit>().cachedProfile?.fullName , lawyerPhotoUrl: getIt<LawyerProfileCubit>().cachedProfile?.photoUrl  ) ;
                    }
                }
              else
                {
                  _navigateToDetails(context, item) ;
                }
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Header
// ─────────────────────────────────────────────────────────────────────────────

class _FilterHeader extends StatelessWidget {
  final ConsultationStatus selectedStatus;
  final VoidCallback onFilterTap;

  const _FilterHeader({
    required this.selectedStatus,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
              children: [
                const TextSpan(text: 'تصفية حسب : '),
                TextSpan(
                  text: selectedStatus.label,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/filter.svg',
                  width: 20.w,
                  height: 20.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Consultation Card
// ─────────────────────────────────────────────────────────────────────────────

class _ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;
  final VoidCallback onTap;

  const _ConsultationCard({
    required this.consultation,
    required this.onTap,
  });

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _typeLabel(String type) {
    switch (type) {
      case 'instant':
        return 'إستشارة فورية';
      case 'scheduled':
        return 'إستشارة مجدولة';
      case 'written':
        return 'إستشارة كتابيه';
      default:
        return type;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal(); // ✅ حوّل لتوقيت الجهاز
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'مساءً' : 'صباحًا';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    final startDt = consultation.effectiveStartDateTime;
    final periodLabel = consultation.durationMin != null
        ? '${consultation.durationMin} دقيقه'
        : '—';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.w),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: type label + status badge ─────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeLabel(consultation.type),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          if (consultation.specialization != null) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  'التخصص: ',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Text(
                                  consultation.specialization!.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      _StatusBadge(status: consultation.status),
                    ],
                  ),
                  GeneralDivider(height: 20.h),

                  // ── Client info ───────────────────────────────────────
                  if (consultation.client != null &&
                      !consultation.hideClientFromLawyer)
                    _ClientInfoRow(client: consultation.client!),

                  // ── Consultation title ────────────────────────────────
                  if (consultation.title.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      consultation.title,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],

                  GeneralDivider(height: 20.h),

                  // ── Date / time / duration row ─────────────────────────
                  _TimePriceRow(
                    date: _formatDate(startDt),
                    time: _formatTime(startDt),
                    period: periodLabel,
                    textColor: textColor,
                  ),
                  SizedBox(height: 10.h),
                  GeneralDivider(height: 0),
                ],
              ),
            ),

            // ── Bottom action ─────────────────────────────────────────
            if (consultation.isUpcoming)
              _UpcomingSessionButton(
                consultation: consultation,
                onEnter: onTap,
              )
            else
              SizedBox(
                width: double.infinity,
                child: GradiantButton(
                  text: consultation.isActive ? 'أدخل الجلسه' : 'عرض التفاصيل',
                  onTap: onTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming Session Countdown Button (card variant)
//
// • Counts down to [effectiveStartDateTime] using epoch-ms arithmetic,
//   which is completely timezone-safe regardless of device locale.
// • Once the countdown reaches zero the gradient "أدخل الجلسه" button becomes
//   tappable; before that it shows a live HH:MM:SS (or MM:SS) ticker.
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingSessionButton extends StatefulWidget {
  final ConsultationModel consultation;
  final VoidCallback onEnter;

  const _UpcomingSessionButton({
    required this.consultation,
    required this.onEnter,
  });

  @override
  State<_UpcomingSessionButton> createState() => _UpcomingSessionButtonState();
}

class _UpcomingSessionButtonState extends State<_UpcomingSessionButton> {
  Timer? _timer;

  /// `null`  → no start time available, enable button immediately.
  /// Zero    → countdown finished, enable button.
  /// Positive → still counting down.
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _tick();
    });
  }

  void _tick() {
    final dt = widget.consultation.effectiveStartDateTime;
    if (dt == null) {
      setState(() => _remaining = null);
      _timer?.cancel();
      return;
    }

    // ✅ استخدم UTC في الطرفين عشان يتطابقوا
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final startMs = dt.toUtc().millisecondsSinceEpoch;
    final diffMs = startMs - nowMs;

    if (diffMs <= 0) {
      setState(() => _remaining = Duration.zero);
      _timer?.cancel();
    } else {
      setState(() => _remaining = Duration(milliseconds: diffMs));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _sessionStarted =>
      _remaining == null || _remaining == Duration.zero;

  /// Formats a duration as `HH:MM:SS` when >= 1 hour, otherwise `MM:SS`.
  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionStarted) {
      return SizedBox(
        width: double.infinity,
        child: GradiantButton(text: 'أدخل الجلسه', onTap: widget.onEnter),
      );
    }

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(14),
        bottomRight: Radius.circular(14),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        color: primaryColor.withOpacity(0.07),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تبدأ الجلسة خلال',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 16.sp, color: primaryColor),
                SizedBox(width: 6.w),
                Text(
                  _formatCountdown(_remaining!),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client Info Row
// ─────────────────────────────────────────────────────────────────────────────

class _ClientInfoRow extends StatelessWidget {
  final ConsultationClient client;

  const _ClientInfoRow({required this.client});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Row(
      children: [
        CircleAvatar(
          radius: 22.w,
          backgroundColor: Colors.grey.shade200,
          child: Text(
            client.fullName.isNotEmpty ? client.fullName[0] : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 16.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.fullName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            if (client.city != null)
              Text(
                client.city!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final ConsultationStatus status;

  const _StatusBadge({required this.status});

  Color get _bgColor {
    switch (status) {
      case ConsultationStatus.active:
        return Colors.green.withOpacity(0.1);
      case ConsultationStatus.upcoming:
        return Colors.blue.withOpacity(0.1);
      case ConsultationStatus.completed:
        return Colors.grey.withOpacity(0.1);
      case ConsultationStatus.cancelled:
        return Colors.red.withOpacity(0.1);
      case ConsultationStatus.disputes:
        return Colors.orange.withOpacity(0.1);
      case ConsultationStatus.none:
        return Colors.black.withOpacity(0.1);
    }
  }

  Color get _textColor {
    switch (status) {
      case ConsultationStatus.active:
        return Colors.green.shade700;
      case ConsultationStatus.upcoming:
        return Colors.blue.shade700;
      case ConsultationStatus.completed:
        return Colors.grey.shade700;
      case ConsultationStatus.cancelled:
        return Colors.red.shade700;
      case ConsultationStatus.disputes:
        return Colors.orange.shade700;
      case ConsultationStatus.none:
        return Colors.black;
    }
  }

  String get _label => status.label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(50.w),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time / Date / Duration Row
// ─────────────────────────────────────────────────────────────────────────────

class _TimePriceRow extends StatelessWidget {
  final String date;
  final String time;
  final String period;
  final Color textColor;

  const _TimePriceRow({
    required this.date,
    required this.time,
    required this.period,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _InfoCell(label: 'التاريخ', value: date, valueColor: textColor),
        _Divider(),
        _InfoCell(label: 'وقت البدء', value: time, valueColor: textColor),
        _Divider(),
        _InfoCell(
          label: 'مدة الجلسه',
          value: period,
          valueColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: Colors.grey, fontSize: 12.sp),
        ),
        Gap(5.h),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      width: 2.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50.w),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBottomSheet extends StatefulWidget {
  final ConsultationStatus selected;
  final void Function(ConsultationStatus) onApply;

  const _FilterBottomSheet({
    required this.selected,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ConsultationStatus _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
              Text(
                'تصفية حسب',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Status options
          ...ConsultationStatus.values.map((s) => _StatusOption(
            status: s,
            isSelected: _selected == s,
            onTap: () => setState(() => _selected = s),
          )),

          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: GradiantButton(
              text: 'تطبيق التصفية',
              onTap: () => widget.onApply(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final ConsultationStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? activeColor : null,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15.sp,
              ),
            ),
            // Radio indicator
            Container(
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error View
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56.w, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: 16.h),
            GradiantButton(text: 'إعادة المحاولة', onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty View
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final ConsultationStatus status;

  const _EmptyView({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64.w, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'لا توجد استشارات ${status.label}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}