// ─────────────────────────────────────────────────────────────────────────────
// appointments_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/error_state_widget.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/features/User/Appointments/reschedule_consultation_screen.dart';
import 'package:rasikh/features/User/application/appointment_booking_screen(3.3).dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../Lawyer/consultation/Bloc/consultation_details_cubit.dart';
import '../../Lawyer/consultation/Bloc/consultations_cubit.dart';
import '../../Lawyer/consultation/Bloc/consultations_states.dart';
import '../../Lawyer/consultation/consultation_details_screen.dart';
import '../../Lawyer/consultation/models/consultation_model.dart';
import 'package:rasikh/core/widgets/picture.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Server time correction
// ─────────────────────────────────────────────────────────────────────────────

DateTime? _correctServerTime(DateTime? dt) {
  if (dt == null) return null;
  return dt.toLocal().subtract(const Duration(hours: 0));
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  static const _tabs = [
    (label: 'قادمة', status: ConsultationStatus.upcoming),
    (label: 'مكتملة', status: ConsultationStatus.completed),
    (label: 'ملغاة', status: ConsultationStatus.cancelled),
  ];

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context
        .read<ConsultationsCubit>()
        .fetchConsultations(status: ConsultationStatus.upcoming);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ConsultationsCubit>().loadMoreConsultations();
    }
  }

  // ── Navigation helpers ────────────────────────────────────────────────────
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

  void _navigateToReschedule(BuildContext context, ConsultationModel item) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ConsultationsCubit>(),
          child: RescheduleConsultationScreen(consultation: item),
        ),
      ),
    );
  }

  void _handleConsultationTap(BuildContext context, ConsultationModel item) {
    if (item.isActive == true || item.isUpcoming == true) {
      final startDt = _correctServerTime(item.effectiveStartDateTime);
      final canJoin = startDt == null ||
          DateTime.now().toLocal().isAfter(startDt.toLocal()) ||
          item.isActive == true;

      if (!canJoin) {
        _navigateToDetails(context, item);
        return;
      }

      if (item.type == 'written') {
        Nav.chat(
          context,
          consultationId: item.id,
          clientId: item.client?.id,
          lawyerId: item.lawyer?.id,
          lawyerName: item.lawyer?.fullName,
          lawyerPhotoUrl: getIt<CacheHelper>().currentUser?.avatar,
        );
      } else {
        Nav.videoCallScreen(
          context,
          consultationId: item.id,
          clientId: item.client?.id,
          lawyerId: item.lawyer?.id,
          lawyerName: item.lawyer?.fullName,
          consultationType: item.type,
          lawyerPhotoUrl: getIt<CacheHelper>().currentUser?.avatar,
        );
      }
    } else {
      _navigateToDetails(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<ConsultationsCubit, ConsultationsState>(
        listenWhen: (_, curr) =>
        curr is ConsultationRescheduled ||
            curr is ConsultationRescheduleError ||
            curr is ConsultationCancelled ||
            curr is ConsultationCancelError,
        listener: (context, state) {
          if (state is ConsultationRescheduled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إعادة جدولة الاستشارة بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ConsultationRescheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ConsultationCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إلغاء الاستشارة بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ConsultationCancelError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Directionality(
          textDirection: Directionality.of(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(40.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "مواعيدي",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.titleSmall?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Gap(12.h),
              Divider(
                  height: 1,
                  color: theme.colorScheme.primary.withOpacity(0.1)),
              const Gap(12),

              // ── Tabs ────────────────────────────────────────────────────
              BlocBuilder<ConsultationsCubit, ConsultationsState>(
                buildWhen: (_, curr) =>
                curr is ConsultationsLoaded ||
                    curr is ConsultationsLoading ||
                    curr is ConsultationsEmpty ||
                    curr is ConsultationsError ||
                    curr is ConsultationRescheduled ||
                    curr is ConsultationCancelled,
                builder: (context, state) {
                  final cubit = context.read<ConsultationsCubit>();
                  final selectedIndex = _tabs
                      .indexWhere((t) => t.status == cubit.selectedStatus)
                      .clamp(0, _tabs.length - 1);

                  return AppointmentTabs(
                    selectedIndex: selectedIndex,
                    onTabSelected: (i) => cubit.applyFilter(_tabs[i].status),
                  );
                },
              ),
              const Gap(16),

              // ── Body ─────────────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<ConsultationsCubit, ConsultationsState>(
                  buildWhen: (_, curr) =>
                  curr is ConsultationsLoaded ||
                      curr is ConsultationsLoading ||
                      curr is ConsultationsEmpty ||
                      curr is ConsultationsError ||
                      curr is ConsultationsPaginating ||
                      curr is ConsultationsRefreshing ||
                      curr is ConsultationRescheduling ||
                      curr is ConsultationRescheduled ||
                      curr is ConsultationRescheduleError ||
                      curr is ConsultationCancelling ||
                      curr is ConsultationCancelled ||
                      curr is ConsultationCancelError,
                  builder: (context, state) => _buildBody(context, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATED: Full state handling with NoDataWidget & ErrorStateWidget
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBody(BuildContext context, ConsultationsState state) {
    // ── Loading (initial) ───────────────────────────────────────────────────
    if (state is ConsultationsLoading) {
      return const _AppointmentShimmerList();
    }

    // ── Error ───────────────────────────────────────────────────────────────
    if (state is ConsultationsError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          ErrorStateWidget(
            title: 'تعذر تحميل المواعيد',
            message: state.message,
            actionLabel: 'إعادة المحاولة',
            onAction: () => context
                .read<ConsultationsCubit>()
                .fetchConsultations(status: context.read<ConsultationsCubit>().selectedStatus),
          ),
        ],
      );
    }

    // ── Empty ───────────────────────────────────────────────────────────────
    if (state is ConsultationsEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          NoDataWidget(
            icon: Icons.calendar_today_outlined,
            title: 'لا توجد مواعيد ${_getStatusLabel(state.selectedStatus)}',
            message: 'لم يتم العثور على مواعيد في هذا التصنيف',
          ),
        ],
      );
    }

    // ── Loaded / Refreshing / Paginating / Action states ────────────────────
    final List<ConsultationModel> items;
    final bool isPaginating;

    if (state is ConsultationsLoaded) {
      items = state.consultations;
      isPaginating = false;
    } else if (state is ConsultationsPaginating) {
      items = state.currentConsultations;
      isPaginating = true;
    } else if (state is ConsultationsRefreshing) {
      items = state.currentConsultations;
      isPaginating = false;
    } else if (state is ConsultationRescheduling) {
      items = state.currentConsultations;
      isPaginating = false;
    } else if (state is ConsultationRescheduled) {
      items = state.consultations;
      isPaginating = false;
    } else if (state is ConsultationRescheduleError) {
      items = state.currentConsultations;
      isPaginating = false;
    } else if (state is ConsultationCancelling) {
      items = state.currentConsultations;
      isPaginating = false;
    } else if (state is ConsultationCancelled) {
      items = state.consultations;
      isPaginating = false;
    } else if (state is ConsultationCancelError) {
      items = state.currentConsultations;
      isPaginating = false;
    } else {
      return const SizedBox.shrink();
    }

    // Double-check empty after resolving
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          NoDataWidget(
            icon: Icons.calendar_today_outlined,
            title: 'لا توجد مواعيد',
            message: 'لم يتم العثور على مواعيد في هذا التصنيف',
          ),
        ],
      );
    }

    final reschedulingId = state is ConsultationRescheduling
        ? state.consultationId
        : null;

    final cancellingId = state is ConsultationCancelling
        ? state.consultationId
        : null;

    return RefreshIndicator(
      onRefresh: () => context
          .read<ConsultationsCubit>()
          .refreshConsultations(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length + (isPaginating ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: _AppointmentShimmerCard(),
            );
          }
          final item = items[index];
          final isRescheduling = reschedulingId == item.id;
          final isCancelling = cancellingId == item.id;

          return AppointmentCard.fromConsultation(
            item,
            isRescheduling: isRescheduling,
            isCancelling: isCancelling,
            onTap: () => _handleConsultationTap(context, item),
            onReschedule: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AppointmentBookingScreen(
                  lawyerId: item.lawyer!.id,
                  consultationId: item.id,
                  isRescheduleMode: true,
                  onRescheduleConfirmed: (d) {
                    context
                        .read<ConsultationsCubit>()
                        .rescheduleConsultation(
                      consultationId: item.id,
                      newStartTime: d,
                    );
                  },
                ),
              ),
            ),
            onDetails: () => _navigateToDetails(context, item),
          );
        },
      ),
    );
  }

  String _getStatusLabel(ConsultationStatus status) {
    switch (status) {
      case ConsultationStatus.upcoming:
        return 'قادمة';
      case ConsultationStatus.completed:
        return 'مكتملة';
      case ConsultationStatus.cancelled:
        return 'ملغاة';
      case ConsultationStatus.active:
        return 'نشطة';
      case ConsultationStatus.disputes:
        return 'متنازع عليها';
      case ConsultationStatus.none:
        return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REMOVED: _buildErrorView and _buildEmptyView — replaced by ErrorStateWidget & NoDataWidget
// ─────────────────────────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue ? primary : Colors.grey.shade300,
          ),
          color: hasValue ? primary.withOpacity(0.04) : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: hasValue ? primary : Colors.grey.shade400),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500, fontSize: 11),
                ),
                const SizedBox(height: 2),
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
// Shimmer List
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentShimmerList extends StatelessWidget {
  const _AppointmentShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _AppointmentShimmerCard(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Card
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentShimmerCard extends StatelessWidget {
  const _AppointmentShimmerCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _box(width: 110, height: 14),
                _box(width: 52, height: 24, radius: 12),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                _box(width: 44, height: 44, radius: 22),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 140, height: 14),
                    const SizedBox(height: 6),
                    _box(width: 90, height: 12),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoCol(),
                _vertDivider(),
                _infoCol(),
                _vertDivider(),
                _infoCol(),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _box(height: 40, radius: 10)),
                const SizedBox(width: 8),
                Expanded(child: _box(height: 40, radius: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({double? width, required double height, double radius = 6}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  Widget _infoCol() => Column(children: [
    _box(width: 60, height: 11),
    const SizedBox(height: 5),
    _box(width: 72, height: 13),
  ]);

  Widget _vertDivider() =>
      Container(width: 1.5, height: 24, color: Colors.white);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tabs Section
// ─────────────────────────────────────────────────────────────────────────────

class AppointmentTabs extends StatelessWidget {
  const AppointmentTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const _labels = ['قادمة', 'مكتملة', 'ملغاة'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_labels.length, (i) {
            final isSelected = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(i),
                child: isSelected
                    ? Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: tabColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _labels[i],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : Center(
                  child: Text(
                    _labels[i],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UPDATED: AppointmentCard — now matches _ConsultationCard from consultations_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

class AppointmentCard extends StatelessWidget {
  const AppointmentCard._({
    required this.consultation,
    required this.isRescheduling,
    this.isCancelling = false,
    this.onTap,
    this.onReschedule,
    this.onDetails,
  });

  final ConsultationModel consultation;
  final bool isRescheduling;
  final bool isCancelling;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule;
  final VoidCallback? onDetails;

  factory AppointmentCard.fromConsultation(
      ConsultationModel c, {
        bool isRescheduling = false,
        bool isCancelling = false,
        VoidCallback? onTap,
        VoidCallback? onReschedule,
        VoidCallback? onDetails,
      }) {
    return AppointmentCard._(
      consultation: c,
      isRescheduling: isRescheduling,
      isCancelling: isCancelling,
      onTap: onTap,
      onReschedule: onReschedule,
      onDetails: onDetails,
    );
  }

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
    final local = dt.toLocal();
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

    final startDt = _correctServerTime(consultation.effectiveStartDateTime);
    final periodLabel = consultation.durationMin != null
        ? '${consultation.durationMin} دقيقه'
        : '—';

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: (isRescheduling || isCancelling) ? 0.6 : 1.0,
        child: AbsorbPointer(
          absorbing: isRescheduling || isCancelling,
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

                      // ── Lawyer info (client side shows lawyer) ────────
                      if (consultation.lawyer != null)
                        _LawyerInfoRow(lawyer: consultation.lawyer!),

                      // ── Consultation title ────────────────────────────
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

                      // ── Cancelled warning banner ──────────────────────
                      if (consultation.status == ConsultationStatus.cancelled) ...[
                        const _CancelledWarningBanner(),
                        SizedBox(height: 14.h),
                      ],

                      // ── Date / time / duration row ──────────────────
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

                // ── Bottom action (status-driven) ───────────────────────
                _buildBottomAction(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom action resolver ───────────────────────────────────────────────

  Widget _buildBottomAction(BuildContext context) {
    switch (consultation.status) {
      case ConsultationStatus.active:
        return SizedBox(
          width: double.infinity,
          child: GradiantButton(text: 'أدخل الجلسه', onTap: onTap ?? () {}),
        );

      case ConsultationStatus.upcoming:
        return _UpcomingSessionButton(
          consultation: consultation,
          onEnter: onTap ?? () {},
          onReschedule: consultation.type == 'scheduled' ? onReschedule : null,
        );

      case ConsultationStatus.completed:
        return Row(
          children: [
            Expanded(
              child: GradiantButton(
                text: 'عرض الملخص',
                onTap: onDetails ?? () {},
              ),
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
          child: GradiantButton(
            text: 'عرض التفاصيل',
            onTap: onDetails ?? () {},
          ),
        );
    }
  }

  // ── Action handlers ───────────────────────────────────────────────────────

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
// Cancelled Warning Banner (copied from consultations_screen.dart)
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
// Outlined Action Button (copied from consultations_screen.dart)
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
// Upcoming Session Button (updated to match consultations_screen.dart)
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
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _tick();
    });
  }

  void _tick() {
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
          // ── Countdown ticker ────────────────────────────────────────
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

          // ── Reschedule + Cancel pill buttons ───────────────────────────
          if (widget.onReschedule != null)
            Row(
              children: [
                // Reschedule
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

                // Cancel
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
// Shared Action Spinner (used for both rescheduling & cancelling)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionSpinner extends StatelessWidget {
  final Color color;
  final Color? bgColor;
  final String label;

  const _ActionSpinner({
    required this.color,
    required this.label,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(14),
        bottomRight: Radius.circular(14),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: bgColor ?? color.withOpacity(0.07),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lawyer Info Row (updated to match consultations_screen.dart style)
// ─────────────────────────────────────────────────────────────────────────────

class _LawyerInfoRow extends StatelessWidget {
  final ConsultationLawyer lawyer;

  const _LawyerInfoRow({required this.lawyer});

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
              color: theme.colorScheme.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: ClipOval(
              child: lawyer.photoUrl != null && lawyer.photoUrl!.isNotEmpty
                  ? Picture(
                AppConfig.baseImgUrl+lawyer.photoUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
                  : Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  size: 28.h,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lawyer.fullName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            if (lawyer.city != null)
              Text(
                lawyer.city!,
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
// Status Badge (copied from consultations_screen.dart)
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
// Time / Date / Duration Row (copied from consultations_screen.dart)
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
// Rating Bottom Sheet (copied from consultations_screen.dart)
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
                  height: 50.h,
                  child: isSubmitting
                      ? Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50.w),
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 22.w,
                      height: 22.h,
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
// Dispute Details Popup (copied from consultations_screen.dart)
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
                border: Border.all(
                  color: Colors.white,
                  width: 5,
                ),
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