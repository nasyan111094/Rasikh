// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/presentation/screens/consultations_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/features/Lawyer/consultation/widgets/consultation_shimmer.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/bloc/Profile_cubit/lawyer_cubit.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/widgets/app_bar_without_icon_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/general_divider.dart';
import '../../../../core/widgets/gradiant_button.dart';
import '../../../../core/widgets/no_data_widget.dart';
import '../../../config/app_config.dart';
import '../../../config/navigation/nav.dart';
import '../../User/application/appointment_booking_screen(3.3).dart';
import 'Bloc/consultation_details_cubit.dart';
import 'Bloc/consultations_cubit.dart';
import 'Bloc/consultations_states.dart';
import 'consultation_details_screen.dart';
import 'models/consultation_model.dart';
import 'package:rasikh/core/widgets/picture.dart';

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
    if (state is ConsultationRescheduling) return state.selectedStatus;
    if (state is ConsultationRescheduled) return state.selectedStatus;
    if (state is ConsultationRescheduleError) return state.selectedStatus;
    if (state is ConsultationCancelling) return state.selectedStatus;
    if (state is ConsultationCancelled) return state.selectedStatus;
    if (state is ConsultationCancelError) return state.selectedStatus;
    if (state is ConsultationRatingSubmitting) return state.selectedStatus;
    if (state is ConsultationRatingSubmitted) return state.selectedStatus;
    if (state is ConsultationRatingError) return state.selectedStatus;
    return ConsultationStatus.none;
  }

  List<ConsultationModel> _resolveConsultations(ConsultationsState state) {
    if (state is ConsultationsLoaded) return state.consultations;
    if (state is ConsultationsRefreshing) return state.currentConsultations;
    if (state is ConsultationsPaginating) return state.currentConsultations;
    if (state is ConsultationRescheduling) return state.currentConsultations;
    if (state is ConsultationRescheduled) return state.consultations;
    if (state is ConsultationRescheduleError) return state.currentConsultations;
    if (state is ConsultationCancelling) return state.currentConsultations;
    if (state is ConsultationCancelled) return state.consultations;
    if (state is ConsultationCancelError) return state.currentConsultations;
    if (state is ConsultationRatingSubmitting) return state.currentConsultations;
    if (state is ConsultationRatingSubmitted) return state.consultations;
    if (state is ConsultationRatingError) return state.currentConsultations;
    return [];
  }

  String? _resolveBusyId(ConsultationsState state) {
    if (state is ConsultationRescheduling) return state.consultationId;
    if (state is ConsultationCancelling) return state.consultationId;
    if (state is ConsultationRatingSubmitting) return state.consultationId;
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<ConsultationsCubit, ConsultationsState>(
        listenWhen: (_, curr) =>
        curr is ConsultationRescheduled ||
            curr is ConsultationRescheduleError ||
            curr is ConsultationCancelled ||
            curr is ConsultationCancelError ||
            curr is ConsultationRatingSubmitted ||
            curr is ConsultationRatingError,
        listener: (context, state) {
          if (state is ConsultationRescheduled) {
            _showSnack(context, 'تم إعادة جدولة الاستشارة بنجاح', Colors.green);
          } else if (state is ConsultationRescheduleError) {
            _showSnack(context, state.message, Colors.red);
          } else if (state is ConsultationCancelled) {
            _showSnack(context, 'تم إلغاء الاستشارة بنجاح', Colors.green);
          } else if (state is ConsultationCancelError) {
            _showSnack(context, state.message, Colors.red);
          } else if (state is ConsultationRatingSubmitted) {
            _showSnack(context, 'تم إرسال تقييمك بنجاح', Colors.green);
          } else if (state is ConsultationRatingError) {
            _showSnack(context, state.message, Colors.red);
          }
        },
        child: Directionality(
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
      ),
    );
  }

  void _showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  bool _canEnterSession(ConsultationModel item) {
    if (item.isActive == true) return true;
    if (item.isUpcoming == true) {
      final start = _correctServerTime(item.effectiveStartDateTime);
      if (start == null) return true;
      return !DateTime.now().isBefore(start);
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATED: Full state handling with NoDataWidget & ErrorStateWidget
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBody(
      BuildContext context,
      ConsultationsState state,
      ThemeData theme,
      ) {
    // ── Loading (initial) ─────────────────────────────────────────────────
    if (state is ConsultationsLoading) {
      return const ConsultationsListShimmer();
    }

    // ── Error ───────────────────────────────────────────────────────────────
    if (state is ConsultationsError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          ErrorStateWidget(
            title: 'تعذر تحميل الاستشارات',
            message: state.message,
            actionLabel: 'إعادة المحاولة',
            onAction: () => context.read<ConsultationsCubit>().fetchConsultations(),
          ),
        ],
      );
    }

    // ── Empty ───────────────────────────────────────────────────────────────
    if (state is ConsultationsEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 200.h),
          NoDataWidget(
            icon: Icons.inbox_outlined,
            title: 'لا توجد استشارات ${state.selectedStatus.label}',
            message: 'لم يتم العثور على استشارات في هذا التصنيف',
          ),
        ],
      );
    }

    // ── Success (has data) ────────────────────────────────────────────────
    final consultations = _resolveConsultations(state);
    final isPaginating = state is ConsultationsPaginating;
    final busyId = _resolveBusyId(state);

    // Double-check: if resolved list is empty, show empty state
    if (consultations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          NoDataWidget(
            icon: Icons.inbox_outlined,
            title: 'لا توجد استشارات',
            message: 'لم يتم العثور على استشارات في هذا التصنيف',
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: consultations.length + (isPaginating ? 1 : 0),
        itemBuilder: (context, index) {
          // Last slot: pagination shimmer card
          if (index == consultations.length) {
            return const ConsultationCardShimmer();
          }

          final item = consultations[index];

          return _ConsultationCard(
            consultation: item,
            isBusy: busyId == item.id,
            onTap: () {
              if (_canEnterSession(item)) {
                if (item.type == "written") {
                  Nav.chat(context,
                      consultationId: item.id,
                      clientId: item.client?.id,
                      lawyerId: item.lawyer?.id,
                      lawyerName: item.lawyer?.fullName,
                      lawyerPhotoUrl: getIt<CacheHelper>().currentUser?.avatar);
                } else {
                  Nav.videoCallScreen(context,
                      consultationId: item.id,
                      clientId: item.client?.id,
                      lawyerId: item.lawyer?.id,
                      lawyerName: item.lawyer?.fullName,
                      consultationType: item.type,
                      lawyerPhotoUrl: getIt<CacheHelper>().currentUser?.avatar);
                }
              } else {
                _navigateToDetails(context, item);
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
    final primary = theme.colorScheme.primary;
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

DateTime? _correctServerTime(DateTime? dt) {
  if (dt == null) return null;
  return dt.subtract(const Duration(hours: 0));
}

class _ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;
  final VoidCallback onTap;
  final bool isBusy;

  const _ConsultationCard({
    required this.consultation,
    required this.onTap,
    this.isBusy = false,
  });

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
    final local = dt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'مساءً' : 'صباحًا';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final startDt = _correctServerTime(consultation.effectiveStartDateTime);
    final periodLabel = consultation.durationMin != null
        ? '${consultation.durationMin} دقيقه'
        : '—';

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isBusy ? 0.6 : 1.0,
        child: AbsorbPointer(
          absorbing: isBusy,
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
                      // ── Header: type label + status badge ─────────────
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
                            ],
                          ),
                          _StatusBadge(status: consultation.status),
                        ],
                      ),

                      GeneralDivider(height: 20.h),

                      // ── Client info ───────────────────────────────────
                      if (consultation.client != null &&
                          !consultation.hideClientFromLawyer)
                        _ClientInfoRow(
                            currentUser:
                            getIt<CacheHelper>().cachedVendorType ==
                                VendorType.user
                                ? consultation.lawyer
                                : consultation.client!),

                      GeneralDivider(height: 20.h),

                      // ── Cancelled warning banner ─────────────────────
                      if (consultation.status == ConsultationStatus.cancelled) ...[
                        const _CancelledWarningBanner(),
                        SizedBox(height: 14.h),
                      ],

                      // ── Date / time / duration row ─────────────────────
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

                // ── Bottom action (status-driven) ─────────────────────
                _buildBottomAction(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    switch (consultation.status) {
      case ConsultationStatus.active:
        return SizedBox(
          width: double.infinity,
          child: GradiantButton(text: 'أدخل الجلسه', onTap: onTap),
        );

      case ConsultationStatus.upcoming:
        return _UpcomingSessionButton(
          consultation: consultation,
          onEnter: onTap,
          onReschedule: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AppointmentBookingScreen(
                lawyerId: consultation.lawyer!.id,
                consultationId: consultation.id,
                isRescheduleMode: true,
                onRescheduleConfirmed: (d) {
                  context.read<ConsultationsCubit>().rescheduleConsultation(
                    consultationId: consultation.id,
                    newStartTime: d,
                  );
                },
              ),
            ),
          ),
        );

      case ConsultationStatus.completed:
        return Row(
          children: [
            Expanded(
              child: GradiantButton(text: 'عرض الملخص', onTap: onTap),
            ),
            Expanded(
              child: _OutlinedActionButton(
                text: 'إضافة تقييم',
                onTap: () => _showRatingSheet(context),
              ),
            ),
          ],
        );

      case ConsultationStatus.cancelled:
        return const SizedBox.shrink();

      case ConsultationStatus.disputes:
        return SizedBox(
          width: double.infinity,
          child: GradiantButton(
            text: 'عرض النزاع',
            onTap: () => _showDisputePopup(context),
          ),
        );

      case ConsultationStatus.none:
        return SizedBox(
          width: double.infinity,
          child: GradiantButton(text: 'عرض التفاصيل', onTap: onTap),
        );
    }
  }

  void _showRescheduleSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _RescheduleBottomSheet(
        initialDateTime: consultation.effectiveStartDateTime,
        onConfirm: (newStartTime) {
          Navigator.pop(sheetContext);
          context.read<ConsultationsCubit>().rescheduleConsultation(
            consultationId: consultation.id,
            newStartTime: newStartTime,
          );
        },
      ),
    );
  }

  void _showRatingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ConsultationsCubit>(),
        child: _RatingBottomSheet(consultation: consultation),
      ),
    );
  }

  void _showDisputePopup(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _DisputeDetailsPopup(consultation: consultation),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming Session Countdown Button (card variant)
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingSessionButton extends StatefulWidget {
  final ConsultationModel consultation;
  final VoidCallback onEnter;
  final VoidCallback? onReschedule;

  const _UpcomingSessionButton({
    required this.consultation,
    required this.onEnter,
    this.onReschedule,
  });

  @override
  State<_UpcomingSessionButton> createState() => _UpcomingSessionButtonState();
}

class _UpcomingSessionButtonState extends State<_UpcomingSessionButton> {
  Timer? _timer;
  final _logger = Logger();
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    // Defensive guard: this widget is only ever switched-in by
    // _buildBottomAction for ConsultationStatus.upcoming, but we keep the
    // check here too so the countdown timer can never start (or keep
    // running) for any other status, even if this widget is reused
    // elsewhere later.
    if (widget.consultation.status != ConsultationStatus.upcoming) {
      _remaining = Duration.zero;
      return;
    }
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _tick();
    });
  }

  void _tick() {
    if (widget.consultation.status != ConsultationStatus.upcoming) {
      _timer?.cancel();
      return;
    }
    final dt = _correctServerTime(widget.consultation.effectiveStartDateTime);
    if (dt == null) {
      setState(() => _remaining = null);
      _timer?.cancel();
      return;
    }
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final startMs = dt.millisecondsSinceEpoch;
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

  bool get _sessionStarted => _remaining == null || _remaining == Duration.zero;

  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomConfirmationDialog(
        title: 'تأكيد الإلغاء',
        description: 'هل أنت متأكد من رغبتك في إلغاء الموعد ؟',
        icon: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE53935),
              width: 2.5,
            ),
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Color(0xFFE53935),
            size: 34,
          ),
        ),
        confirmText: 'نعم',
        cancelText: 'لا',
        onConfirm: () {
          context.read<ConsultationsCubit>().cancelConsultation(
            consultationId: widget.consultation.id,
          );
        },
        onCancel: () {},
      ),
    );
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
      child: Column(
        children: [
          Container(
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
                    Icon(Icons.timer_outlined,
                        size: 16.sp, color: primaryColor),
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
          if (widget.onReschedule != null &&
              getIt<CacheHelper>().cachedVendorType == VendorType.user)
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.h),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.h),
                        onTap: widget.onReschedule,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Center(
                            child: Text(
                              'إعادة الجدولة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: primaryColor.withOpacity(.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.h),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.h),
                        onTap: () => _confirmCancel(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Center(
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
// Cancelled Warning Banner
// ─────────────────────────────────────────────────────────────────────────────

class _CancelledWarningBanner extends StatelessWidget {
  const _CancelledWarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18.sp, color: Colors.red.shade400),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'انتهت مهلة الدفع. يرجى إعادة الحجز بدلاً من الدفع.',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outlined Action Button (secondary action paired with GradiantButton)
// ─────────────────────────────────────────────────────────────────────────────

class _OutlinedActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OutlinedActionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primary.withOpacity(0.0)),
            backgroundColor: primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.w),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reschedule Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _RescheduleBottomSheet extends StatefulWidget {
  final DateTime? initialDateTime;
  final void Function(DateTime newStartTime) onConfirm;

  const _RescheduleBottomSheet({
    required this.initialDateTime,
    required this.onConfirm,
  });

  @override
  State<_RescheduleBottomSheet> createState() => _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends State<_RescheduleBottomSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool get _isValid => _selectedDate != null && _selectedTime != null;

  @override
  void initState() {
    super.initState();
    final base = _correctServerTime(widget.initialDateTime);
    if (base != null) {
      _selectedDate = DateTime(base.year, base.month, base.day);
      _selectedTime = TimeOfDay(hour: base.hour, minute: base.minute);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';

  String _formatTime(TimeOfDay t) {
    final hour = t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    final isAm = hour < 12;
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute ${isAm ? 'صباحاً' : 'مساءً'}';
  }

  void _confirm() {
    final d = _selectedDate!;
    final t = _selectedTime!;
    widget.onConfirm(DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(50),
                ),
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
                  'إعادة الجدولة',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(width: 36.w),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'اختر التاريخ والوقت الجديد للاستشارة',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade500),
            ),
            SizedBox(height: 24.h),
            _PickerTile(
              icon: Icons.calendar_today_outlined,
              label: 'التاريخ',
              value: _selectedDate != null
                  ? _formatDate(_selectedDate!)
                  : 'اختر التاريخ',
              hasValue: _selectedDate != null,
              onTap: _pickDate,
            ),
            SizedBox(height: 12.h),
            _PickerTile(
              icon: Icons.access_time_outlined,
              label: 'الوقت',
              value: _selectedTime != null
                  ? _formatTime(_selectedTime!)
                  : 'اختر الوقت',
              hasValue: _selectedTime != null,
              onTap: _pickTime,
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              child: GradiantButton(
                text: 'تأكيد إعادة الجدولة',
                onTap: _isValid ? _confirm : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color: hasValue ? primary : Colors.grey.shade300,
          ),
          color: hasValue ? primary.withOpacity(0.04) : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20.sp, color: hasValue ? primary : Colors.grey.shade400),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade500, fontSize: 11.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasValue ? primary : Colors.grey.shade400,
                    fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_left,
                color: hasValue ? primary : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rating Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _RatingBottomSheet extends StatefulWidget {
  final ConsultationModel consultation;

  const _RatingBottomSheet({required this.consultation});

  @override
  State<_RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<_RatingBottomSheet> {
  int _stars = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<ConsultationsCubit>().rateConsultation(
      consultation: widget.consultation,
      stars: _stars,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ConsultationsCubit, ConsultationsState>(
      listenWhen: (_, curr) =>
      (curr is ConsultationRatingSubmitted &&
          curr.consultationId == widget.consultation.id) ||
          (curr is ConsultationRatingError &&
              curr.consultationId == widget.consultation.id),
      listener: (context, state) {
        if (state is ConsultationRatingSubmitted ||
            state is ConsultationRatingError) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ConsultationRatingSubmitting &&
            state.consultationId == widget.consultation.id;

        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: isSubmitting ? null : () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 36.w,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person,
                      size: 36.sp, color: theme.colorScheme.primary),
                ),
                SizedBox(height: 14.h),
                Text(
                  'قيّم تجربتك معنا',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'تقييمك يعكس مدى رضاك ويساعدنا على التحسين.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    final filled = starIndex <= _stars;
                    return GestureDetector(
                      onTap: isSubmitting
                          ? null
                          : () => setState(() => _stars = starIndex),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32.sp,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'كيف كانت تجربتك؟ احكي لنا',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _commentController,
                  enabled: !isSubmitting,
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'أكتب هنا ...',
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.w),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,

                  child: isSubmitting
                      ? Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50.w),
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 22.w,
                      height: 40.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : GradiantButton(
                    text: 'إرسال الآن',
                    onTap: () => _submit(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dispute Details Popup
// ─────────────────────────────────────────────────────────────────────────────

class _DisputeDetailsPopup extends StatelessWidget {
  final ConsultationModel consultation;

  const _DisputeDetailsPopup({required this.consultation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
                Gap(16.w),
                Text(
                  consultation.type == "instant"
                      ? "إستشاره فوريه"
                      : consultation.type == "written"
                      ? "إستشاره كتابيه"
                      : consultation.type == "scheduled"
                      ? "إستشاره مجدوله"
                      : "غير معوف",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            GeneralDivider(),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'سبب النزاع',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                consultation.dispute!.reason ?? 'تأخير في موعد الحضور',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تفاصيل النزاع',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                consultation.dispute!.description ??
                    'المحامي دخل الجلسة متأخر حوالي 10 دقائق مما أثّر على وقت الاستشارة.',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 10.h),
            GeneralDivider(),
            SizedBox(height: 10.h),
            GradiantButton(text: 'تم', onTap: () => Navigator.pop(context)),
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
  final currentUser;

  const _ClientInfoRow({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Row(
      children: [
        Container(
          width: 55.w,
          height: 55.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: ClipOval(
              child: Image.network(
                AppConfig.baseImgUrl +
                    (getIt<CacheHelper>().cachedVendorType == VendorType.lawyer
                        ? currentUser.avatar
                        : currentUser.photoUrl),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentUser.fullName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            if (currentUser.city != null)
              Text(
                currentUser.city!,
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
       _label == "الكل" ? "قيد الإنتظار" :_label,
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
                'تصفية حسب',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15.sp,
              ),
            ),
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

// ═══════════════════════════════════════════════════════════════════════════
// REMOVED: _ErrorView and _EmptyView — replaced by ErrorStateWidget & NoDataWidget
// ═══════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// Custom Confirmation Dialog
// ─────────────────────────────────────────────────────────────────────────────

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget icon;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.confirmText = 'نعم',
    this.cancelText = 'لا',
    this.onConfirm,
    this.onCancel,
  });

  static const double _circleSize = 70.0;
  static const double _circleRadius = _circleSize / 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: _circleRadius),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.h),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  24.w, _circleRadius + 20.h, 24.w, 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22.sp,
                      color: const Color(0xFF2D2D2D),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF888888),
                      height: 1.7,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onConfirm?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              confirmText,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 56.h,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onCancel?.call();
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.grey.shade500,
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              cancelText,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(child: icon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}