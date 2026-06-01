// ─────────────────────────────────────────────────────────────────────────────
// lawyer_details_screen.dart
// UI is 100% identical to the original.
// Changes: accepts lawyerId param → fetches real data via ConsultationCubit.
//          "احجز الآن" selects the lawyer and navigates to the next step.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/theme/font_weights.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../config/theme/colors.dart';
import '../../../core/widgets/picture.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart';


class LawyerDetailsScreen extends StatefulWidget {
  /// The id of the lawyer to display.
  /// Pass it when pushing this route:
  ///   Nav.lawyerDetailsScreen(context, lawyerId: lawyer.id);
  final String lawyerId;

  const LawyerDetailsScreen({Key? key, required this.lawyerId})
      : super(key: key);

  @override
  State<LawyerDetailsScreen> createState() => _LawyerDetailsScreenState();
}

class _LawyerDetailsScreenState extends State<LawyerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch real data
    context.read<ConsultationCubit>().loadLawyerDetail(widget.lawyerId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Book button handler ───────────────────────────────────────────────────

  void _onBook(BuildContext context, ConsultationState state) {
    final detail = state.selectedLawyerDetail;
    if (detail == null) return;

    // Store as selected lawyer (LawyerModel base fields are identical)
    context.read<ConsultationCubit>().selectLawyer(detail);

    if (state.selectedConsultationType == ConsultationType.scheduled) {
      Nav.appointmentBookingScreen(context);
    } else {
      Nav.paymentScreen(context);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(title: "تفاصيل المحامي"),
      body: BlocBuilder<ConsultationCubit, ConsultationState>(
        builder: (context, state) {
          // ── Loading ──────────────────────────────────────────────────────
          if (state.lawyerDetailStatus == ConsultationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ────────────────────────────────────────────────────────
          if (state.lawyerDetailStatus == ConsultationStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.lawyerDetailError ?? 'حدث خطأ ما'),
                  const Gap(12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ConsultationCubit>()
                        .loadLawyerDetail(widget.lawyerId),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          // ── Success — render exactly the original UI with real data ──────
          final lawyer = state.selectedLawyerDetail;
          if (lawyer == null) return const SizedBox.shrink();

          // Build review list from API ratings
          final reviews = lawyer.ratings
              .map((r) => {
            'id': r.createdAt,
            'rating': r.stars.toDouble(),
            'author': r.client?.fullName ?? 'مستخدم',
            'text': r.comment ?? '',
            'avatar': r.client?.avatar ?? '',
          })
              .toList();

          // Specialization chip labels from both main + sub
          final specializationLabels = [
            ...lawyer.mainSpecializations
                .where((s) => s.name != null)
                .map((s) => s.name!),
            ...lawyer.subSpecializations
                .where((s) => s.name != null)
                .map((s) => s.name!),
          ];

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      Gap(16.h),
                      _buildProfileCard(theme, colorScheme, lawyer),
                      Expanded(
                        child: _buildTabsAndContent(
                          theme,
                          colorScheme,
                          lawyer,
                          reviews,
                          specializationLabels,
                        ),
                      ),
                      Gap(24.h),
                    ],
                  ),
                ),
              ),
              _buildBookButton(theme, colorScheme, state),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile card — UI unchanged, data from LawyerDetailModel
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildProfileCard(
      ThemeData theme,
      ColorScheme colorScheme,
      LawyerDetailModel lawyer,
      ) {
    final photoUrl = lawyer.photoUrl ?? '';
    final isOnline = lawyer.activityStatus == 'active';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 70.h,
            width: double.infinity,
            child: Row(
              children: [
                // ── Avatar ─────────────────────────────────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 35.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1000.h),
                        child: photoUrl.isNotEmpty
                            ? Picture(photoUrl)
                            : Icon(
                          Icons.person,
                          size: 40.h,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    // Online dot
                    if (isOnline)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                    // Rating badge
                    Positioned(
                      bottom: -10.h,
                      left: 3.w,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10.h),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 18),
                            SizedBox(width: 4.w),
                            Text(
                              lawyer.rating.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: "almarai",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Gap(12.w),

                // ── Name + city ────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawyer.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Gap(10.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16.w, color: theme.hintColor),
                          Gap(4.w),
                          Text(
                            lawyer.city ?? '—',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GeneralDivider(height: 40.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  theme,
                  'سنوات الخبرة',
                  lawyer.experienceYears != null
                      ? '${lawyer.experienceYears}'
                      : '—',
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: theme.dividerColor.withOpacity(0.3),
              ),
              Expanded(
                child: _buildInfoItem(
                  theme,
                  'يبدأ بـ',
                  lawyer.consultationFee != null
                      ? '${lawyer.consultationFee!.toStringAsFixed(0)} ريال'
                      : '—',
                ),
              ),
            ],
          ),
          GeneralDivider(height: 20.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tabs — UI unchanged
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTabsAndContent(
      ThemeData theme,
      ColorScheme colorScheme,
      LawyerDetailModel lawyer,
      List<Map<String, dynamic>> reviews,
      List<String> specializationLabels,
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: colorScheme.primary,
              padding: EdgeInsets.zero,
              unselectedLabelColor: theme.hintColor,
              labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: fw900,
              ),
              unselectedLabelStyle: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: Colors.grey),
              tabs: const [
                Tab(text: 'التقييمات'),
                Tab(text: 'الخبرات والمؤهلات'),
                Tab(text: 'الملف الشخصي'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewsContent(theme, colorScheme, reviews,
                    lawyer.rating, lawyer.ratings.length),
                _buildExperienceContent(
                    theme, colorScheme, lawyer.qualifications),
                _buildAboutContent(
                    theme, colorScheme, lawyer.bio, specializationLabels,
                    lawyer.license?.imageUrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab content — UI unchanged, data injected
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildReviewsContent(
      ThemeData theme,
      ColorScheme colorScheme,
      List<Map<String, dynamic>> reviews,
      double avgRating,
      int totalCount,
      ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(20.h),
          _buildRatingSummary(theme, colorScheme, avgRating, totalCount),
          Gap(20.h),
          Text(
            'التقييمات ($totalCount)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(20.h),
          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text('لا توجد تقييمات بعد',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.hintColor)),
              ),
            )
          else
            ...reviews.map(
                  (review) => Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: _buildReviewItem(theme, colorScheme, review),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(
      ThemeData theme,
      ColorScheme colorScheme,
      double avgRating,
      int totalCount,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              avgRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                height: 1,
              ),
            ),
            Gap(4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return Icon(
                  index < avgRating.floor()
                      ? Icons.star_rounded
                      : (index < avgRating
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded),
                  color: colorScheme.primary,
                  size: 22,
                );
              }),
            ),
            Gap(6.h),
            Text(
              'بناءً على $totalCount تقييماً',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        Gap(24.w),
        Expanded(
          child: Row(
            children: [
              Column(
                children: List.generate(5, (index) {
                  final widthFactors = [0.95, 0.85, 0.65, 0.45, 0.25];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    child: Container(
                      width: 220.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.h),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: widthFactors[index],
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(4.h),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        Gap(10.w),
      ],
    );
  }

  Widget _buildReviewItem(
      ThemeData theme,
      ColorScheme colorScheme,
      Map<String, dynamic> review,
      ) {
    final avatarUrl = review['avatar'] as String? ?? '';
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: greyFA),
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25.w,
              backgroundColor: theme.dividerColor,
              backgroundImage:
              avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? Icon(Icons.person,
                  color: colorScheme.onSurfaceVariant, size: 24.h)
                  : null,
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review['author'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.h),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (review['rating'] as double)
                                  .toStringAsFixed(1),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFamily: "cairo",
                                fontSize: 14,
                              ),
                            ),
                            Gap(4.w),
                            Icon(
                              Icons.star_rounded,
                              color: colorScheme.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(6.h),
                  Text(
                    review['text'] as String,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceContent(
      ThemeData theme,
      ColorScheme colorScheme,
      String? qualifications,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخبرات السابقة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          Gap(16.h),
          Container(
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.h),
              border: Border.all(color: greyFA),
            ),
            child: Text(
              qualifications?.isNotEmpty == true
                  ? qualifications!
                  : 'لا توجد معلومات عن الخبرات.',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                height: 1.7,
                color:
                theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
              ),
            ),
          ),
          GeneralDivider(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildAboutContent(
      ThemeData theme,
      ColorScheme colorScheme,
      String? bio,
      List<String> specializationLabels,
      String? licenseImageUrl,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نبذة عن المحامي',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          Gap(16.h),
          Text(
            bio?.isNotEmpty == true ? bio! : 'لا توجد نبذة.',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              height: 1.5,
              color:
              theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
            ),
          ),
          Gap(28.h),
          Text(
            'التخصصات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          Gap(16.h),
          if (specializationLabels.isEmpty)
            Text('لا توجد تخصصات مسجلة.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor))
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.start,
              children: specializationLabels
                  .map((s) => _buildSpecChip(theme, colorScheme, s))
                  .toList(),
            ),
          Gap(28.h),
          Text(
            'رخصة مزاولة المهنة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          Gap(16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16.h),
            ),
            child: Column(
              children: [
                if (licenseImageUrl != null && licenseImageUrl.isNotEmpty)
                  Picture(
                    licenseImageUrl,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  )
                else
                  Container(
                    height: 160.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                    child: Text('لا توجد صورة رخصة',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor)),
                  ),
                Gap(12.h),
                Text(
                  'وزارة العدل - المملكة العربية السعودية',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Spec chip — UI unchanged
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSpecChip(
      ThemeData theme, ColorScheme colorScheme, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFF5F5F5)
            : theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24.h),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Info item — UI unchanged
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 13,
            color: theme.hintColor,
          ),
          textAlign: TextAlign.center,
        ),
        Gap(6.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Book button — UI unchanged, now navigates via cubit
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBookButton(
      ThemeData theme,
      ColorScheme colorScheme,
      ConsultationState state,
      ) {
    final isLoading =
        state.lawyerDetailStatus == ConsultationStatus.loading;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _onBook(context, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.h),
              ),
            ),
            child: const Text(
              'احجز الآن',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// LicenseModel lives in consultation_models.dart — no duplicate needed here.
