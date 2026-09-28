// ─────────────────────────────────────────────────────────────────────────────
// features/User/ratings/presentation/screens/client_rating_detail_screen.dart
//
// Client rating details (read-only).
//   GET /api/v1/client/ratings/{id}
//
// Notes:
//   - lawyerReply is shown ONLY when lawyerReplyPublished == true.
//   - "عرض الاستشارة" navigates to consultation details via consultation.id.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import 'package:rasikh/features/Lawyer/consultation/Bloc/consultation_details_cubit.dart';
import 'package:rasikh/features/Lawyer/consultation/consultation_details_screen.dart';
import 'package:rasikh/features/Lawyer/consultation/repo/consultations_repo.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/models/lawyer_ratings_model.dart';
import 'package:rasikh/features/User/ratings/bloc/client_ratings_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared design tokens (kept local so the screen stays self-contained)
// ─────────────────────────────────────────────────────────────────────────────

const _kBorderColor = Color(0xFFF3F3F3);
const _kCardColor = Colors.white;

// ── Consultation type / status → Arabic ─────────────────────────────────────

String _consultationTypeLabel(String type) {
  switch (type) {
    case 'instant':
      return 'إستشارة فورية';
    case 'written':
      return 'إستشارة كتابية';
    case 'scheduled':
      return 'إستشارة مجدولة';
    default:
      return 'غير معروف';
  }
}

String _consultationStatusLabel(String status) {
  switch (status) {
    case 'active':
      return 'نشطة';
    case 'upcoming':
      return 'قادمة';
    case 'completed':
      return 'مكتملة';
    case 'cancelled':
      return 'ملغاة';
    case 'disputes':
      return 'نزاعات';
    case 'pending':
    case '':
      return 'قيد الانتظار';
    default:
      return 'غير معروف';
  }
}

Color _consultationStatusColor(String status, ColorScheme colorScheme) {
  switch (status) {
    case 'active':
      return colorScheme.primary;
    case 'upcoming':
      return const Color(0xFFE08A1E);
    case 'completed':
      return const Color(0xFF2E9E5B);
    case 'cancelled':
      return const Color(0xFFD64545);
    case 'disputes':
      return const Color(0xFF8E4FD6);
    default:
      return Colors.grey;
  }
}

class ClientRatingDetailScreen extends StatefulWidget {
  final String ratingId;

  const ClientRatingDetailScreen({
    super.key,
    required this.ratingId,
  });

  @override
  State<ClientRatingDetailScreen> createState() =>
      _ClientRatingDetailScreenState();
}

class _ClientRatingDetailScreenState extends State<ClientRatingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClientRatingsCubit>().fetchRatingDetail(widget.ratingId);
  }

  Future<void> _onRefresh() =>
      context.read<ClientRatingsCubit>().fetchRatingDetail(widget.ratingId);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const GeneralAppBar(title: 'تفاصيل التقييم'),
      body: BlocBuilder<ClientRatingsCubit, ClientRatingsState>(
        builder: (context, state) {
          if (state is ClientRatingDetailLoading) {
            return _DetailShimmer(theme: theme);
          }

          if (state is ClientRatingDetailError) {
            return _buildError(theme, colorScheme, state.message);
          }

          if (state is ClientRatingDetailLoaded) {
            return _buildContent(theme, colorScheme, state.detail);
          }

          return _DetailShimmer(theme: theme);
        },
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(
      ThemeData theme, ColorScheme colorScheme, String message) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: ListView(
        children: [
          SizedBox(height: 160.h),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 48, color: Colors.red),
                Gap(12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.red),
                  ),
                ),
                Gap(12.h),
                TextButton(
                  onPressed: () => context
                      .read<ClientRatingsCubit>()
                      .fetchRatingDetail(widget.ratingId),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────

  Widget _buildContent(
      ThemeData theme, ColorScheme colorScheme, RatingDetailModel detail) {
    // ملحوظة 1: لا يظهر رد المحامي إلا إذا كان منشوراً.
    final showLawyerReply = detail.lawyerReplyPublished &&
        detail.lawyerReply.trim().isNotEmpty;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero: lawyer + score ─────────────────────────────────────
            _buildHeroCard(theme, colorScheme, detail)
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.25, end: 0, curve: Curves.easeOut),

            Gap(16.h),

            // ── My comment ───────────────────────────────────────────────
            _buildCommentCard(theme, colorScheme, detail)
                .animate(delay: 120.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            Gap(16.h),

            // ── Consultation + عرض الاستشارة ─────────────────────────────
            _buildConsultationCard(theme, colorScheme, detail.consultation)
                .animate(delay: 240.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            // ── Lawyer reply (published only) ────────────────────────────
            if (showLawyerReply) ...[
              Gap(16.h),
              _buildLawyerReply(theme, detail.lawyerReply)
                  .animate(delay: 360.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
            ],
          ],
        ),
      ),
    );
  }

  // ── Hero card (lawyer) ────────────────────────────────────────────────────

  Widget _buildHeroCard(
      ThemeData theme, ColorScheme colorScheme, RatingDetailModel detail) {
    final lawyer = detail.lawyer;
    final stars = detail.stars.toDouble();
    final fullStars = stars.floor();
    final formattedDate =
        DateFormat('dd/MM/yyyy', 'en_US').format(detail.createdAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.h),
        border: Border.all(color: _kBorderColor),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colorScheme.primary.withOpacity(0.08),
            _kCardColor,
          ],
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(
                url: lawyer.photoUrl,
                fallbackLetter: lawyer.fullName.isNotEmpty
                    ? lawyer.fullName[0].toUpperCase()
                    : '?',
                colorScheme: colorScheme,
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyer.fullName.isNotEmpty ? lawyer.fullName : '—',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                    Gap(6.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16.w, color: Colors.grey),
                        Gap(4.w),
                        Expanded(
                          child: Text(
                            lawyer.city.isNotEmpty ? lawyer.city : '—',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontFamily: 'cairo',
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(4.h),
                    Row(
                      children: [
                        Picture(getAssetIcon('Calendar.svg'),
                            width: 18.w, height: 18.h),
                        Gap(4.w),
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontFamily: 'cairo',
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(16.h),
          Container(height: 1, color: _kBorderColor),
          Gap(16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                stars.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 44,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        IconData icon;
                        if (index < fullStars) {
                          icon = Icons.star_rounded;
                        } else if (index == fullStars &&
                            (stars - fullStars) >= 0.5) {
                          icon = Icons.star_half_rounded;
                        } else {
                          icon = Icons.star_outline_rounded;
                        }
                        return Icon(icon,
                            color: colorScheme.primary, size: 24);
                      }),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .shimmer(delay: 400.ms, duration: 1.seconds),
                    Gap(6.h),
                    Text(
                      _ratingLabel(stars),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontFamily: 'cairo',
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ratingLabel(double stars) {
    if (stars >= 4.5) return 'تقييم ممتاز';
    if (stars >= 3.5) return 'تقييم جيد جداً';
    if (stars >= 2.5) return 'تقييم جيد';
    if (stars >= 1.5) return 'تقييم مقبول';
    return 'تقييم ضعيف';
  }

  // ── Comment card ──────────────────────────────────────────────────────────

  Widget _buildCommentCard(
      ThemeData theme, ColorScheme colorScheme, RatingDetailModel detail) {
    final hasComment = detail.comment.trim().isNotEmpty;

    return _SectionCard(
      title: 'تعليقي',
      iconData: Icons.format_quote_rounded,
      colorScheme: colorScheme,
      theme: theme,
      child: Text(
        hasComment ? detail.comment : 'لم تترك تعليقاً',
        textAlign: TextAlign.right,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13.sp,
          height: 1.6,
          color: hasComment
              ? theme.textTheme.bodyMedium?.color?.withOpacity(0.8)
              : Colors.grey,
        ),
      ),
    );
  }

  // ── Consultation card + عرض الاستشارة ─────────────────────────────────────

  Widget _buildConsultationCard(
      ThemeData theme, ColorScheme colorScheme, RatingConsultation c) {
    return _SectionCard(
      title: 'معلومات الاستشارة',
      iconData: Icons.description_outlined,
      colorScheme: colorScheme,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.consultationNumber.isNotEmpty) ...[
            _buildInfoRow(theme, 'رقم الاستشارة', c.consultationNumber),
            Gap(10.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110.w,
                child: Text(
                  'النوع',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontFamily: 'cairo',
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _consultationTypeLabel(c.type),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Gap(10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110.w,
                child: Text(
                  'الحالة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontFamily: 'cairo',
                    fontSize: 13.sp,
                  ),
                ),
              ),
              _StatusChip(status: c.status, colorScheme: colorScheme),
            ],
          ),
          Gap(16.h),
          // ملحوظة 2: زر عرض الاستشارة → تفاصيل الاستشارة عبر consultation.id
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => ConsultationDetailsCubit(
                        repo: ConsultationsRepo(),
                      ),
                      child: LawyerConsultationDetailsScreen(
                        consultationId: c.id,
                      ),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back_rounded,
                  size: 18.w, color: colorScheme.primary),
              label: Text(
                'عرض الاستشارة',
                style: TextStyle(
                  fontFamily: 'cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary.withOpacity(0.4)),
                backgroundColor: colorScheme.primary.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontFamily: 'cairo',
              fontSize: 13.sp,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Published lawyer reply only ───────────────────────────────────────────

  Widget _buildLawyerReply(ThemeData theme, String reply) {
    const accent = Color(0xFF2E9E5B);

    return Container(
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.h),
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: accent,
                  size: 18.w,
                ),
              ),
              Gap(8.w),
              Expanded(
                child: Text(
                  'رد المحامي',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          Gap(12.h),
          Text(
            reply,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable section card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.iconData,
    required this.child,
    required this.theme,
    required this.colorScheme,
  });

  final String title;
  final IconData iconData;
  final Widget child;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: _kBorderColor),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10.h),
                ),
                child:
                    Icon(iconData, size: 18.w, color: colorScheme.primary),
              ),
              Gap(8.w),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Gap(14.h),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.fallbackLetter,
    required this.colorScheme,
  });

  final String url;
  final String fallbackLetter;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl =
        url.isEmpty ? '' : (url.startsWith('http') ? url : AppConfig.baseImgUrl + url);
    return CircleAvatar(
      radius: 30.w,
      backgroundColor: colorScheme.primary.withOpacity(0.15),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: resolvedUrl,
          width: 60.w,
          height: 60.w,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Center(
            child: Text(
              fallbackLetter,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ),
          placeholder: (_, __) => Center(
            child: SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.colorScheme});

  final String status;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final color = _consultationStatusColor(status, colorScheme);
    final label = _consultationStatusLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Gap(6.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontFamily: 'cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              height: null,
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 30.w, backgroundColor: Colors.white),
                      Gap(12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _box(width: 130, height: 14),
                          Gap(8.h),
                          _box(width: 90, height: 11),
                          Gap(6.h),
                          _box(width: 70, height: 11),
                        ],
                      ),
                    ],
                  ),
                  Gap(20.h),
                  Row(
                    children: [
                      _box(width: 70, height: 44, radius: 10),
                      Gap(12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _box(width: 130, height: 16),
                          Gap(8.h),
                          _box(width: 80, height: 11),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(16.h),
            _card(height: 120),
            Gap(16.h),
            _card(height: 190),
          ],
        ),
      ),
    );
  }

  static Widget _box(
      {required double width, required double height, double radius = 6}) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static Widget _card({double? height, Widget? child}) {
    return Container(
      width: double.infinity,
      height: height?.h,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
