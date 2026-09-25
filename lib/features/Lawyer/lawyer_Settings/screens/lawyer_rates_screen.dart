// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/lawyer_Settings/presentation/screens/lawyer_rates_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/widgets/dialogs/report_comment_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../Repo/lawyer_ratings_repo.dart';
import '../bloc/Ratings_cubit/lawyer_ratings_cubit.dart';
import '../models/lawyer_ratings_model.dart';
import 'rating_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry-point
// ─────────────────────────────────────────────────────────────────────────────

class LawyerRatesScreen extends StatelessWidget {
  const LawyerRatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LawyerRatingsCubit(LawyerRatingsRepo())..fetchRatings(),
      child: const _LawyerRatesView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal stateful view
// ─────────────────────────────────────────────────────────────────────────────

class _LawyerRatesView extends StatefulWidget {
  const _LawyerRatesView({Key? key}) : super(key: key);

  @override
  State<_LawyerRatesView> createState() => _LawyerRatesViewState();
}

class _LawyerRatesViewState extends State<_LawyerRatesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Infinite scroll ───────────────────────────────────────────────────────

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<LawyerRatingsCubit>();
      final state = cubit.state;
      if (state is LawyerRatingsLoaded && cubit.hasMorePages()) {
        cubit.loadMoreRatings();
      }
    }
  }

  // ── Pull-to-refresh ───────────────────────────────────────────────────────

  Future<void> _onRefresh() =>
      context.read<LawyerRatingsCubit>().fetchRatings();

  // ── BlocListener side-effects ─────────────────────────────────────────────

  void _handleStateChange(BuildContext context, LawyerRatingsState state) {
    if (state is LawyerRatingReportSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.green),
      );
    } else if (state is LawyerRatingReportError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<LawyerRatingsCubit, LawyerRatingsState>(
      listener: _handleStateChange,
      child: Scaffold(
        appBar: const GeneralAppBar(title: "تقييماتي"),
        body: BlocBuilder<LawyerRatingsCubit, LawyerRatingsState>(
          builder: (context, state) {
            // ── Shimmer skeleton on first load ───────────────────────────
            if (state is LawyerRatingsLoading) {
              return _RatingsShimmer(
                  theme: theme, colorScheme: colorScheme);
            }

            // ── Error ────────────────────────────────────────────────────
            if (state is LawyerRatingsError) {
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
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.red),
                          ),
                          Gap(12.h),
                          TextButton(
                            onPressed: () => context
                                .read<LawyerRatingsCubit>()
                                .fetchRatings(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── Resolve model from any "has data" state ──────────────────
            final LawyerRatingsModel? ratingsModel;
            final Set<String> reportedIds;
            final bool isPaginationLoading;
            final String? reportingId;

            switch (state) {
              case LawyerRatingsLoaded():
                ratingsModel = state.ratingsModel;
                reportedIds = state.reportedIds;
                isPaginationLoading = false;
                reportingId = null;

              case LawyerRatingsPaginationLoading():
                ratingsModel = state.currentModel;
                reportedIds = state.reportedIds;
                isPaginationLoading = true;
                reportingId = null;

              case LawyerRatingReportLoading():
                ratingsModel = state.currentModel;
                reportedIds = state.reportedIds;
                isPaginationLoading = false;
                reportingId = state.ratingId;

              case LawyerRatingReportSuccess():
                ratingsModel = state.currentModel;
                reportedIds = state.reportedIds;
                isPaginationLoading = false;
                reportingId = null;

              case LawyerRatingReportError():
                ratingsModel = state.currentModel;
                reportedIds = state.reportedIds;
                isPaginationLoading = false;
                reportingId = null;

              default:
                ratingsModel = null;
                reportedIds = {};
                isPaginationLoading = false;
                reportingId = null;
            }

            if (ratingsModel == null) {
              return _RatingsShimmer(
                  theme: theme, colorScheme: colorScheme);
            }

            // ── Main content ─────────────────────────────────────────────
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(40.h),

                        _RatingSummary(model: ratingsModel)
                            .animate()
                            .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        Gap(30.h),

                        Text(
                          'التقييمات الأخيره',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(10.h),

                        Expanded(
                          child: _buildReviewsContent(
                            theme,
                            colorScheme,
                            ratingsModel.ratings,
                            reportedIds,
                            reportingId,
                            isPaginationLoading,
                          )
                              .animate()
                              .fadeIn(
                              duration: 500.ms, curve: Curves.easeOut)
                              .slideY(begin: 0.2, end: 0, duration: 700.ms)
                              .scaleXY(
                              begin: 0.97, end: 1.0, duration: 500.ms),
                        ),
                        Gap(24.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Reviews list with pull-to-refresh ─────────────────────────────────────

  Widget _buildReviewsContent(
      ThemeData theme,
      ColorScheme colorScheme,
      List<RatingModel> ratings,
      Set<String> reportedIds,
      String? reportingId,
      bool isPaginationLoading,
      ) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if(ratings.isEmpty) NoDataWidget(title: " لا توجد تقييمات بعد", message: "سيظهر تقييم العملاء هنا بمجرد تلقيك لتقييمات"),
            ...ratings.asMap().entries.map((entry) {
              final i = entry.key;
              final rating = entry.value;
              final isReported = reportedIds.contains(rating.id);
              final isReporting = reportingId == rating.id;

              return Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: _buildReviewItem(
                  theme,
                  colorScheme,
                  rating,
                  isReported: isReported,
                  isReporting: isReporting,
                )
                    .animate(delay: (i * 200).ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.4, end: 0, curve: Curves.easeOut)
                    .scaleXY(begin: 0.9, end: 1.0, duration: 400.ms),
              );
            }).toList(),

            if (isPaginationLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(child: CircularProgressIndicator()),
              ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  // ── Rating summary ────────────────────────────────────────────────────────
  // Extracted into `_RatingSummary` at the bottom of this file.

  // ── Single review card ────────────────────────────────────────────────────

  Widget _buildReviewItem(
      ThemeData theme,
      ColorScheme colorScheme,
      RatingModel review, {
        required bool isReported,
        required bool isReporting,
      }) {
    final formattedDate = DateFormat('dd/MM/yyyy' , 'en_US').format(review.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => LawyerRatingsCubit(LawyerRatingsRepo()),
              child: RatingDetailScreen(ratingId: review.id),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(color: const Color(0xFFF3F3F3)),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Author
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25.w,
                              backgroundColor: colorScheme.primary.withOpacity(0.15),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: AppConfig.baseImgUrl+ review.client.avatar ?? '',
                                  width: 50.w,
                                  height: 50.w,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Center(
                                    child: Text(
                                      review.client.fullName.isNotEmpty
                                          ? review.client.fullName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                                  placeholder: (_, __) => const CircularProgressIndicator(),
                                ),
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scaleXY(
                              begin: 1,
                              end: 1.05,
                              duration: 800.ms,
                              curve: Curves.easeInOut,
                            ),
                            Gap(6.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.client.fullName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Gap(5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Picture(getAssetIcon("Calendar.svg"),
                                        width: 20.w, height: 20.h),
                                    Gap(4.w),
                                    Text(
                                      formattedDate,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                        fontFamily: "cairo",
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Stars + report
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              review.stars.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: "cairo",
                                fontSize: 15.sp,
                              ),
                            ),
                            Gap(5.w),
                            Picture(getAssetIcon("golden_start.svg"),
                                width: 25.h, height: 25.h),
                            Gap(4.w),

                            isReporting
                                ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                                : WarningButton(
                              isReported: isReported,
                              onTap: isReported
                                  ? null
                                  : () => _onReportTap(review.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gap(8.h),
                    Text(
                      review.comment,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.8),
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReportTap(String ratingId) {
    showReportDialog(
      context,
      onSubmit: (message) {
        context.read<LawyerRatingsCubit>().reportRating(
          ratingId: ratingId,
          message: message,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton — mirrors summary header + review card layout exactly
// ─────────────────────────────────────────────────────────────────────────────

class _RatingsShimmer extends StatelessWidget {
  const _RatingsShimmer({required this.theme, required this.colorScheme});

  final ThemeData theme;
  final ColorScheme colorScheme;

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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(40.h),

            // ── Summary header skeleton ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    // Big number
                    _shimmerBox(width: 72, height: 56, radius: 10),
                    Gap(8.h),
                    // Stars row
                    _shimmerBox(width: 110, height: 14, radius: 6),
                    Gap(6.h),
                    // "Based on N" label
                    _shimmerBox(width: 90, height: 11, radius: 6),
                  ],
                ),
                Gap(24.w),
                // Bar chart
                Expanded(
                  child: Column(
                    children: List.generate(
                      5,
                          (_) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        child: _shimmerBox(
                            width: double.infinity, height: 5, radius: 4),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Gap(30.h),

            // Section label
            _shimmerBox(width: 130, height: 14, radius: 6),
            Gap(14.h),

            // Review card skeletons
            ...List.generate(5, (_) => const _ShimmerReviewCard()),
          ],
        ),
      ),
    );
  }

  static Widget _shimmerBox(
      {required double width, required double height, required double radius}) {
    return Container(
      width: width == double.infinity ? null : width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ShimmerReviewCard extends StatelessWidget {
  const _ShimmerReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar + name/date
                    Row(
                      children: [
                        CircleAvatar(
                            radius: 25.w, backgroundColor: Colors.white),
                        Gap(8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 110.w,
                              height: 13.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            Gap(6.h),
                            Container(
                              width: 80.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Stars + warning icon
                    Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 13.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Gap(20.w),
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(10.h),
                // Comment line 1
                Container(
                  width: double.infinity,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Gap(6.h),
                // Comment line 2 (shorter)
                Container(
                  width: 200.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
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

// ─────────────────────────────────────────────────────────────────────────────
// Rating summary (average + stars distribution bars)
// ─────────────────────────────────────────────────────────────────────────────

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.model});

  final LawyerRatingsModel model;

  /// Arabic-correct label for the ratings count.
  static String _countLabel(int n) {
    if (n == 0) return 'لا توجد تقييمات بعد';
    if (n == 1) return 'بناءً على تقييم واحد';
    if (n == 2) return 'بناءً على تقييمين';
    if (n <= 10) return 'بناءً على $n تقييمات';
    return 'بناءً على $n تقييماً';
  }

  /// Full / half / empty star for position [index] (0-based) given [avg].
  static IconData _starIcon(int index, double avg) {
    final diff = avg - index;
    if (diff >= 0.75) return Icons.star_rounded;
    if (diff >= 0.25) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final avg = model.effectiveAverage.clamp(0.0, 5.0);
    final total = model.effectiveTotal;
    final distribution = model.effectiveDistribution;
    final isEmpty = total == 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.h),
        border: Border.all(color: const Color(0xFFF3F3F3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Average block ──────────────────────────────────────────────
          SizedBox(
            width: 108.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 46.sp,
                    fontWeight: FontWeight.w700,
                    color: isEmpty ? theme.hintColor : colorScheme.primary,
                    height: 1,
                  ),
                ),
                Gap(6.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                        (i) => Icon(
                      _starIcon(i, avg),
                      size: 18.w,
                      color: isEmpty
                          ? theme.dividerColor
                          : colorScheme.primary,
                    ),
                  ),
                ),
                Gap(6.h),
                Text(
                  _countLabel(total),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),

          Gap(12.w),
          Container(width: 1, height: 84.h, color: theme.dividerColor.withOpacity(0.25)),
          Gap(12.w),

          // ── Distribution bars (5 → 1) ──────────────────────────────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in distribution)
                  _DistributionBar(
                    item: item,
                    // Stagger so bars fill top-to-bottom.
                    delay: ((5 - item.stars) * 80).ms,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({required this.item, required this.delay});

  final RatingDistributionItem item;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasValue = item.count > 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          // ── Star label ─────────────────────────────────────────────────
          Text(
            '${item.stars}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
          Gap(3.w),
          Icon(Icons.star_rounded, size: 11.w, color: colorScheme.primary),
          Gap(8.w),

          // ── Track + fill ───────────────────────────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.h),
              child: Container(
                height: 6.h,
                color: theme.dividerColor.withOpacity(0.18),
                child: Align(
                  // Direction-aware: fills from the start edge (right in RTL).
                  alignment: AlignmentDirectional.centerStart,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: item.fraction),
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => FractionallySizedBox(
                      // 0 would render nothing; keep a tiny cap visible
                      // only when the value is actually > 0.
                      widthFactor: value <= 0 ? 0.0 : value.clamp(0.02, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary
                              .withOpacity(hasValue ? 0.9 : 0.0),
                          borderRadius: BorderRadius.circular(4.h),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Gap(8.w),

          // ── Percentage ─────────────────────────────────────────────────
          SizedBox(
            width: 32.w,
            child: Text(
              '${item.percentage.round()}%',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                color: hasValue ? theme.hintColor : theme.dividerColor,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WarningButton
// ─────────────────────────────────────────────────────────────────────────────

class WarningButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isReported;

  const WarningButton({
    Key? key,
    required this.onTap,
    this.isReported = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isReported ? Colors.grey : Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Icon(
              isReported
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: color,
              size: 20.w,
            )
                .animate(onPlay: (c) => c.forward(from: 0))
                .shakeX(
              hz: 4,
              duration: 400.ms,
              curve: Curves.elasticInOut,
              amount: 8,
            ),
          ),
        ),
      ),
    );
  }
}