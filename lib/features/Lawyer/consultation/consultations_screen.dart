// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/consultation/consultations_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/features/Lawyer/consultation/widgets/consultation_shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/widgets/app_bar_without_icon_button.dart';
import '../../../../core/widgets/general_divider.dart';
import '../../../../core/widgets/gradiant_button.dart';

import 'Bloc/consultation_details_cubit.dart';
import 'Bloc/consultations_cubit.dart';
import 'Bloc/consultations_states.dart';
import 'consultation_details_screen.dart';
import 'models/consultation_model.dart';

class LawerConsultationsScreen extends StatefulWidget {
  const LawerConsultationsScreen({super.key});

  @override
  State<LawerConsultationsScreen> createState() =>
      _LawerConsultationsScreenState();
}

class _LawerConsultationsScreenState extends State<LawerConsultationsScreen> {
  final ScrollController _scrollController = ScrollController();

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

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (current >= maxScroll - 200) {
      context.read<ConsultationsCubit>().loadMoreConsultations();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<ConsultationsCubit>().refreshConsultations();
  }

  void _openFilterSheet(ConsultationStatus current) {
    showModalBottomSheet(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarWithoutBackIconButton(theme: theme, title: "إستشاراتي"),
            BlocBuilder<ConsultationsCubit, ConsultationsState>(
              builder: (context, state) {
                final status = _resolveStatus(state);
                return _FilterHeader(
                  selectedStatus: status??ConsultationStatus.none,
                  onFilterTap: () => _openFilterSheet(status??ConsultationStatus.none),
                );
              },
            ),
            GeneralDivider(height: 10.h),
            Expanded(
              child: BlocBuilder<ConsultationsCubit, ConsultationsState>(
                builder: (context, state) {
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: consultations.length + (isPaginating ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == consultations.length) {
                          return const ConsultationCardShimmer();
                        }

                        final item = consultations[index];
                        return _ConsultationCard(
                          consultation: item,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => ConsultationDetailsCubit(
                                  repo: context.read<ConsultationsCubit>().repo,
                                ),
                                child: LawyerConsultationDetailsScreen(
                                  consultationId: item.id,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ConsultationStatus? _resolveStatus(ConsultationsState state) {
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
}

// ── Filter Header ─────────────────────────────────────────────────────────────

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
    final highlightColor = theme.colorScheme.secondary;
    final cardColor = theme.cardColor.withOpacity(isDark ? 0.15 : 1);

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
                const TextSpan(text: "تصفية حسب : "),
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

// ── Consultation Card ─────────────────────────────────────────────────────────
// Single unified card that adapts based on the consultation data.

class _ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;
  final VoidCallback onTap;

  const _ConsultationCard({
    required this.consultation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    // Price label: convert halala → SAR string
    final periodLabel = consultation.durationMin != null
        ? '${consultation.durationMin!.toStringAsFixed(0)} ${'دقيقه'}'
        : '—';

    final date = consultation.effectiveStartDateTime;
    final dateLabel = _formatDate(date);
    final timeLabel = _formatTime(date);

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
                  // ── Header row ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Consultation type (instant / scheduled)
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
                            Row(children: [    Text(
                              "التخصص: ",
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            ),
                              Text(
                                "${consultation.specialization!.name}",
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),],) ,
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

                  // ── Time & Price ──────────────────────────────────────
                  _TimePriceRow(
                    date: dateLabel,
                    time: timeLabel,
                    period: periodLabel,
                    textColor: textColor,
                  ),
                  SizedBox(height: 10.h),
                  GeneralDivider(height: 0),
                ],
              ),
            ),

            // ── Bottom action button ──────────────────────────────────
            if (consultation.status == ConsultationStatus.upcoming)
              _UpcomingSessionButton(consultation: consultation, onEnter: onTap)
            else
              SizedBox(
                width: double.infinity,
                child: GradiantButton(
                  text: consultation.status == ConsultationStatus.active
                      ? "أدخل الجلسه"
                      : "عرض التفاصيل",
                  onTap: onTap,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'instant':
        return 'إستشارة فورية';
      case 'scheduled':
        return 'إستشارة مجدولة';
      default:
        return type;
    }
  }

  /// Formats a [DateTime] that is already in local time (no re-parsing needed).
  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
  String _formatTime(DateTime? dt) {
    if (dt == null) return '—';

    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'مساءً' : 'صباحًا';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $period';
  }
}

// ── Upcoming Session Button with Countdown ────────────────────────────────────
// Shows a live countdown and enables "أدخل الجلسه" only when time has come.

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
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    final dt = widget.consultation.effectiveStartDateTime;
    if (dt == null) {
      setState(() => _remaining = null);
      return;
    }
    // Use epoch milliseconds diff — completely timezone-safe.
    // dt is UTC (parsed from "Z" string), DateTime.now() epoch is always absolute.
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final startMs = dt.millisecondsSinceEpoch;
    final diffMs = startMs - nowMs;
    setState(() => _remaining =
    diffMs <= 0 ? Duration.zero : Duration(milliseconds: diffMs));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canEnter => _remaining != null && _remaining! == Duration.zero;

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // Session already started or no time info → always enabled
    if (_remaining == null) {
      return SizedBox(
        width: double.infinity,
        child: GradiantButton(text: "أدخل الجلسه", onTap: widget.onEnter),
      );
    }

    if (_canEnter) {
      return SizedBox(
        width: double.infinity,
        child: GradiantButton(text: "أدخل الجلسه", onTap: widget.onEnter),
      );
    }

    // Countdown mode — button disabled
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(14),
        bottomRight: Radius.circular(14),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.07),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "تبدأ الجلسة خلال",
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
                Icon(Icons.timer_outlined, size: 16.sp, color: primary),
                SizedBox(width: 6.w),
                Text(
                  _fmt(_remaining!),
                  style: TextStyle(
                    color: primary,
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

// ── Client Info Row ───────────────────────────────────────────────────────────

class _ClientInfoRow extends StatelessWidget {
  final ConsultationClient client;

  const _ClientInfoRow({required this.client});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [ CircleAvatar(
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

// ── Status Badge ──────────────────────────────────────────────────────────────

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

  String? get _textLabel{
    switch (status) {
      case ConsultationStatus.active:
        return "نشطه";
      case ConsultationStatus.upcoming:
        return "قادمه";
      case ConsultationStatus.completed:
        return "مكتمله";
      case ConsultationStatus.cancelled:
        return "ملغاه";
      case ConsultationStatus.disputes:
        return "نزاعات";
      default: status.label  ;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(50.w),
      ),
      child: Text(
        _textLabel ?? "غير معروف",
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

// ── Time & Price Row ──────────────────────────────────────────────────────────
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
        Column(
          children: [
            Text(
              "التاريخ",
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey, fontSize: 12.sp),
            ),
            Gap(5.h) ,
            Text(
              date,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),

        Container(
          height: 30.h,
          width: 2.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50.w),
          ),
        ),

        Column(
          children: [
            Text(
              "وقت البدء",
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey, fontSize: 12.sp),
            ),
            Gap(5.h) ,
            Text(
              time,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),

        Container(
          height: 30.h,
          width: 2.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50.w),
          ),
        ),

        Column(
          children: [
            Text(
              "مدة الجلسه",
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey, fontSize: 12.sp),
            ),
            Gap(5.h) ,
            Text(
              period,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────────────────────

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
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
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
                "تصفية حسب",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...ConsultationStatus.values.map(
                (s) => GestureDetector(
              onTap: () => setState(() => _selected = s),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10.h),
                padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.w),
                  border: Border.all(
                    color: _selected == s
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _selected == s
                            ? theme.colorScheme.primary
                            : null,
                        fontWeight: _selected == s
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 15.sp,
                      ),
                    ),
                    Container(
                      width: 22.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selected == s
                              ? theme.colorScheme.primary
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: _selected == s
                          ? Center(
                        child: Container(
                          width: 12.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                          : null,
                    ),

                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: GradiantButton(
              text: "تطبيق التصفية",
              onTap: () => widget.onApply(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

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
            GradiantButton(text: "إعادة المحاولة", onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

// ── Empty View ────────────────────────────────────────────────────────────────

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
            Icon(Icons.inbox_outlined,
                size: 64.w, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              "لا توجد استشارات ${status.label}",
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