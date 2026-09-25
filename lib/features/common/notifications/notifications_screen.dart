// features/notifications/presentation/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rasikh/core/widgets/error_state_widget.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/features/common/notifications/repo/notifications_repo.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../../../../config/theme/colors.dart';
import '../../../../../../core/get_it_service/get_it_service.dart';

import '../../User/profile/widgets/header_capsule_appbar_widget.dart';

import 'bloc/notifications_cubit.dart';
import 'models/notification_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(getIt<NotificationsRepo>())
        ..fetchNotifications(),
      child: const _NotificationsView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll - 200) {
      context.read<NotificationsCubit>().loadMoreNotifications();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<NotificationsCubit>().refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: GeneralAppBar(
          title: 'الإشعارات',
        ),
        body: BlocConsumer<NotificationsCubit, NotificationsState>(
          listenWhen: (_, current) =>
          current is NotificationsFailure ||
              current is MarkReadFailure ||
              current is MarkReadSuccess,
          listener: (context, state) {
            if (state is NotificationsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is MarkReadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // ── Loading (initial) ───────────────────────────────────────────
            if (state is NotificationsLoading) {
              return const _NotificationsShimmer();
            }

            // ── Error ───────────────────────────────────────────────────────
            if (state is NotificationsFailure) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80.h),
                  ErrorStateWidget(
                    title: 'تعذر تحميل الإشعارات',
                    message: state.message,
                    actionLabel: 'إعادة المحاولة',
                    onAction: () =>
                        context.read<NotificationsCubit>().fetchNotifications(),
                  ),
                ],
              );
            }

            // ── Loaded (or refreshing with old data) ──────────────────────
            if (state is NotificationsLoaded) {
              // ── Empty ───────────────────────────────────────────────────
              if (state.notifications.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 80.h),
                    const NoDataWidget(
                      icon: Icons.notifications_off_outlined,
                      title: 'لا توجد إشعارات',
                      message: 'ستظهر إشعاراتك الجديدة هنا عند وصولها',
                    ),
                  ],
                );
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 16.h),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.notifications.length +
                      (state.isPaginating ? 1 : 0),
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    // Pagination loader at the bottom
                    if (index == state.notifications.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final notification = state.notifications[index];
                    return _NotificationCard(
                      notification: notification,
                      onTap: notification.isRead
                          ? null
                          : () => context
                          .read<NotificationsCubit>()
                          .markAsRead(notification.id),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Card  (unchanged UI, now driven by real data)
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  /// Format ISO-8601 date to a human-readable string
  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      const months = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}, $hour.$minute $period';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double maxWidth = 398.w;
    final double constrainedWidth =
    screenWidth > maxWidth ? maxWidth : screenWidth;

    final bool isUnread = !notification.isRead;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constrainedWidth),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.h),
            boxShadow: isUnread
                ? [
              BoxShadow(
                color: cs.primary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Material(
            color: isUnread
                ? Colors.transparent
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.h),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.h),
              splashColor: cs.primary.withOpacity(0.08),
              highlightColor: cs.primary.withOpacity(0.04),
              child: Container(
                constraints: BoxConstraints(minHeight: 97.h),
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.h),
                  border: Border.all(
                    color: isUnread ? cs.primary.withOpacity(0.35) : borderColor,
                    width: isUnread ? 1.2.w : 1.w,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔔 Icon
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: isUnread
                            ? cs.primary.withOpacity(0.15)
                            : cs.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/Bell_Bing.svg',
                        width: 22.w,
                        height: 22.w,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          cs.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // 📝 Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight:
                                    isUnread ? FontWeight.w800 : FontWeight.w700,
                                    fontSize: 14.sp,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              // Unread dot
                              if (isUnread) ...[
                                SizedBox(width: 6.w),
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withOpacity(0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            notification.body,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                              color: cs.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  _formatDate(
                                    notification.sentAt ?? notification.createdAt,
                                  ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 1.8,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              if (isUnread) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6.h),
                                  ),
                                  child: Text(
                                    'New',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer placeholder (mirrors card structure exactly)
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsShimmer extends StatelessWidget {
  const _NotificationsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 16.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, __) => _ShimmerCard(),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 97.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: greyEA, width: 1.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circle placeholder
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 14.w),

          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.h,
                  width: 160.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.h),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 12.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.h),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  height: 12.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.h),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 10.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.h),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REMOVED: _ErrorBody — replaced by ErrorStateWidget
// ═══════════════════════════════════════════════════════════════════════════