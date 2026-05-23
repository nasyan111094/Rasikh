// features/help_center/presentation/screens/helping_center_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/widgets/account_item_widget.dart' show AccountItem;
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/widgets/general_app_bar.dart';
import '../../../User/profile/screens/contact_us_screen.dart';
import '../../../User/profile/screens/policy_text_screen.dart';
import '../../../User/profile/screens/question_screen.dart';
import '../../../User/profile/widgets/header_capsule_appbar_widget.dart';

import '../../../User/profile/widgets/support_action_row.dart';
import '../../../common/Auth/models/auth_model.dart';
import '../Repo/help_center_repo.dart';
import '../bloc/help_center/content_cubit.dart';

class HelpingCenterScreen extends StatelessWidget {
  const HelpingCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withOpacity(0.2);
    final divider = Divider(color: dividerColor, thickness: 1, height: 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: GeneralAppBar(title: 'مركز المساعدة'),
        body: SafeArea(
          child: Column(
            children: [
              divider,
              const SizedBox(height: 20),
              /// الأسئلة الشائعة
             if(getIt<CacheHelper>().cachedVendorType == VendorType.user) SupportActionRow(
                leading: SvgPicture.asset(
                  'assets/icons/Question_Circle.svg',
                  width: 24.w,
                  height: 24.h,
                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                ),
                label: 'الأسئلة الشائعة',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FaqScreen(),
                    ),
                  );
                },
              ),

              _HelpCenterBody(divider: divider),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HelpCenterBody extends StatelessWidget {
  const _HelpCenterBody({required this.divider});

  final Divider divider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Contact Us ────────────────────────────────────────────────────
          AccountItem(
            svgAsset: 'assets/icons/edit.svg',
            label: 'تواصل معنا',
            trailingChevronRight: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ContactUsScreen(),
              ),
            ),
          ),
          divider,

          // ── Terms of Use ──────────────────────────────────────────────────
          AccountItem(
            svgAsset: 'assets/icons/user_id.svg',
            label: 'سياسة الإستخدام',
            trailingChevronRight: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PolicyTextScreen(
                  pageTitle: 'سياسة الإستخدام',
                  contentType: ContentType.terms,
                ),
              ),
            ),
          ),
          divider,

          // ── Privacy Policy ────────────────────────────────────────────────
          AccountItem(
            svgAsset: 'assets/icons/mobile.svg',
            label: 'سياسة الخصوصية',
            trailingChevronRight: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PolicyTextScreen(
                  pageTitle: 'سياسة الخصوصية',
                  contentType: ContentType.privacyPolicy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// features/User/profile/screens/policy_text_screen.dart
//
// Replaces the old static PolicySection-based screen.
// Pass [contentType] to choose which API endpoint to call.



// Keep the old model around so existing call-sites that still pass sections
// won't break while you migrate them.
class PolicySection {
  final String title;
  final String body;
  const PolicySection({required this.title, required this.body});
}

// ─────────────────────────────────────────────────────────────────────────────

class PolicyTextScreen extends StatelessWidget {
  const PolicyTextScreen({
    Key? key,
    required this.pageTitle,
    required this.contentType,
    // Legacy param — ignored when contentType is provided
    this.sections = const [],
  }) : super(key: key);

  final String pageTitle;
  final ContentType contentType;
  final List<PolicySection> sections; // kept for backward-compat only

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContentCubit(getIt<HelpCenterRepo>())
        ..fetchContent(contentType),
      child: _PolicyTextView(pageTitle: pageTitle, contentType: contentType),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PolicyTextView extends StatelessWidget {
  const _PolicyTextView({
    required this.pageTitle,
    required this.contentType,
  });

  final String pageTitle;
  final ContentType contentType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: HeaderCapsuleAppBar(
          title: pageTitle,
          showBottomDivider: true,
        ),
        body: BlocConsumer<ContentCubit, ContentState>(
          listenWhen: (_, s) => s is ContentFailure,
          listener: (context, state) {
            if (state is ContentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // ── Shimmer ─────────────────────────────────────────────────
            if (state is ContentLoading) {
              return const _ContentShimmer();
            }

            // ── Error ────────────────────────────────────────────────────
            if (state is ContentFailure) {
              return _ErrorBody(
                message: state.message,
                onRetry: () => context
                    .read<ContentCubit>()
                    .fetchContent(contentType),
              );
            }

            // ── Loaded ───────────────────────────────────────────────────
            if (state is ContentLoaded) {
              return RefreshIndicator(
                onRefresh: () => context
                    .read<ContentCubit>()
                    .refreshContent(contentType),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Html(
                    data: state.content.content,
                    style: {
                      'body': Style(
                        fontSize: FontSize(14.sp),
                        lineHeight: const LineHeight(1.7),
                        color: theme.textTheme.bodyMedium?.color,
                        textAlign: TextAlign.right,
                        direction: TextDirection.rtl,
                      ),
                      'p': Style(
                        margin: Margins.only(bottom: 12),
                      ),
                      'strong': Style(
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    },
                  ),
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
// Shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _ContentShimmer extends StatelessWidget {
  const _ContentShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(8, (i) {
            final isShort = i % 3 == 2;
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Container(
                height: 14.h,
                width: isShort
                    ? MediaQuery.of(context).size.width * 0.5
                    : double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error body
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56.w, color: Colors.red.shade300),
            SizedBox(height: 12.w),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.red.shade400),
            ),
            SizedBox(height: 20.w),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}