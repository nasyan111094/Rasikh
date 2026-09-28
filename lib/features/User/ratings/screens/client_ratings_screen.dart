// ─────────────────────────────────────────────────────────────────────────────
// features/User/ratings/presentation/screens/client_ratings_screen.dart
//
// Client "My ratings" — paginated list of ratings created by the client.
//   GET /api/v1/client/ratings?page=&limit=
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import 'package:rasikh/features/Lawyer/lawyer_Settings/models/lawyer_ratings_model.dart';
import 'package:rasikh/features/User/ratings/bloc/client_ratings_cubit.dart';
import 'package:rasikh/features/User/ratings/repo/client_ratings_repo.dart';
import 'package:rasikh/features/User/ratings/screens/client_rating_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry-point
// ─────────────────────────────────────────────────────────────────────────────

class ClientRatingsScreen extends StatelessWidget {
  const ClientRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientRatingsCubit(getIt<ClientRatingsRepo>())
        ..fetchRatings(),
      child: const _ClientRatingsView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal stateful view
// ─────────────────────────────────────────────────────────────────────────────

class _ClientRatingsView extends StatefulWidget {
  const _ClientRatingsView();

  @override
  State<_ClientRatingsView> createState() => _ClientRatingsViewState();
}

class _ClientRatingsViewState extends State<_ClientRatingsView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Infinite scroll ───────────────────────────────────────────────────────

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<ClientRatingsCubit>();
      final state = cubit.state;
      if (state is ClientRatingsLoaded && cubit.hasMorePages()) {
        cubit.loadMoreRatings();
      }
    }
  }

  // ── Pull-to-refresh ───────────────────────────────────────────────────────

  Future<void> _onRefresh() =>
      context.read<ClientRatingsCubit>().fetchRatings();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const GeneralAppBar(title: 'تقييماتي'),
      body: BlocBuilder<ClientRatingsCubit, ClientRatingsState>(
        builder: (context, state) {
          // ── Shimmer skeleton on first load ─────────────────────────────
          if (state is ClientRatingsLoading) {
            return _RatingsShimmer(theme: theme);
          }

          // ── Error ──────────────────────────────────────────────────────
          if (state is ClientRatingsError) {
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
                            state.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.red),
                          ),
                        ),
                        Gap(12.h),
                        TextButton(
                          onPressed: () => context
                              .read<ClientRatingsCubit>()
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

          // ── Resolve model from any "has data" state ────────────────────
          final LawyerRatingsModel? ratingsModel;
          final bool isPaginationLoading;

          switch (state) {
            case ClientRatingsLoaded():
              ratingsModel = state.ratingsModel;
              isPaginationLoading = false;
            case ClientRatingsPaginationLoading():
              ratingsModel = state.currentModel;
              isPaginationLoading = true;
            default:
              ratingsModel = null;
              isPaginationLoading = false;
          }

          if (ratingsModel == null) {
            return _RatingsShimmer(theme: theme);
          }
          final model = ratingsModel;

          // ── Main content ───────────────────────────────────────────────
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: colorScheme.primary,
            child: model.ratings.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 120.h),
                      const NoDataWidget(
                        title: 'لا توجد تقييمات بعد',
                        message: 'تقييماتك للمحامين ستظهر هنا',
                      ),
                    ],
                  )
                : ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                    itemCount: model.ratings.length +
                        (isPaginationLoading ? 1 : 0),
                    separatorBuilder: (_, __) => Gap(10.h),
                    itemBuilder: (context, index) {
                      if (index == model.ratings.length) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final rating = model.ratings[index];
                      return _buildRatingCard(
                        theme,
                        colorScheme,
                        rating,
                        index,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  // ── Single rating card ────────────────────────────────────────────────────

  Widget _buildRatingCard(
    ThemeData theme,
    ColorScheme colorScheme,
    RatingModel rating,
    int index,
  ) {
    final formattedDate =
        DateFormat('dd/MM/yyyy', 'en_US').format(rating.createdAt);
    final lawyer = rating.lawyer;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) =>
                  ClientRatingsCubit(getIt<ClientRatingsRepo>()),
              child: ClientRatingDetailScreen(ratingId: rating.id),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(color: const Color(0xFFF3F3F3)),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lawyer
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25.w,
                              backgroundColor: colorScheme.primary
                                  .withOpacity(0.15),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: lawyer.photoUrl.isNotEmpty
                                      ? (lawyer.photoUrl
                                              .startsWith('http')
                                          ? lawyer.photoUrl
                                          : AppConfig.baseImgUrl +
                                              lawyer.photoUrl)
                                      : '',
                                  width: 50.w,
                                  height: 50.w,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Center(
                                    child: Text(
                                      lawyer.fullName.isNotEmpty
                                          ? lawyer.fullName[0]
                                              .toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                                  placeholder: (_, __) =>
                                      const CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            Gap(8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lawyer.fullName.isNotEmpty
                                        ? lawyer.fullName
                                        : '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Gap(5.h),
                                  Row(
                                    children: [
                                      Picture(
                                        getAssetIcon('Calendar.svg'),
                                        width: 20.w,
                                        height: 20.h,
                                      ),
                                      Gap(4.w),
                                      Text(
                                        formattedDate,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: Colors.grey,
                                          fontFamily: 'cairo',
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stars
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            rating.stars.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'cairo',
                              fontSize: 15.sp,
                            ),
                          ),
                          Gap(5.w),
                          Picture(
                            getAssetIcon('golden_start.svg'),
                            width: 25.h,
                            height: 25.h,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (rating.comment.trim().isNotEmpty) ...[
                    Gap(8.h),
                    Text(
                      rating.comment,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.8),
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                  // Published lawyer reply indicator (text shown in details)
                  if (rating.lawyerReplyPublished &&
                      rating.lawyerReply.trim().isNotEmpty) ...[
                    Gap(8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.reply_rounded,
                          size: 16.w,
                          color: colorScheme.primary,
                        ),
                        Gap(4.w),
                        Text(
                          'يوجد رد من المحامي',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontFamily: 'cairo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 120).ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _RatingsShimmer extends StatelessWidget {
  const _RatingsShimmer({required this.theme});

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
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
        itemCount: 6,
        separatorBuilder: (_, __) => Gap(10.h),
        itemBuilder: (_, __) => Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.h),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 25.w, backgroundColor: Colors.white),
              Gap(8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 130.w,
                      height: 13.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Gap(6.h),
                    Container(
                      width: 90.w,
                      height: 10.h,
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
        ),
      ),
    );
  }
}
