// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/presentation/screens/lawyer_settings_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/widgets/account_item_widget.dart' show AccountItem;
import '../../../../Shared/widgets/lawyer_profile_avatar.dart';
import '../../../../config/navigation/nav.dart';
import '../../../User/profile/screens/notifications_screen.dart';
import '../../../User/profile/widgets/dialog_widget.dart';

import '../bloc/lawyer_cubit.dart';
import '../bloc/lawyer_state.dart';


class LawyerSettingsScreen extends StatefulWidget {
  const LawyerSettingsScreen({super.key});

  @override
  State<LawyerSettingsScreen> createState() => _LawyerSettingsScreenState();
}

class _LawyerSettingsScreenState extends State<LawyerSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile on first load if not already loaded
    final cubit = context.read<LawyerProfileCubit>();
    if (cubit.cachedProfile == null) {
      cubit.getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary = theme.textTheme.bodyMedium?.color?.withOpacity(0.7);
    final dividerColor = theme.dividerColor.withOpacity(0.2);
    final divider = Divider(color: dividerColor, thickness: 1, height: 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16.w,
          title: Text(
            'الإعدادات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(color: dividerColor, height: 1, thickness: 1),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ── Profile Header ─────────────────────────────────────────────
              BlocBuilder<LawyerProfileCubit, LawyerProfileState>(
                buildWhen: (prev, curr) =>
                curr is LawyerProfileLoaded ||
                    curr is LawyerProfileLoading ||
                    curr is UpdateProfileSuccess,
                builder: (context, state) {
                  final profile =
                      context.read<LawyerProfileCubit>().cachedProfile;

                  return LawyerProfileHeader(
                    theme: theme,
                    textPrimary: textPrimary,
                    iconColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    textSecondary: textSecondary,
                    isLoading: state is LawyerProfileLoading,
                    fullName: profile?.fullName,
                    photoUrl: profile?.photoUrl,
                    accountStatus: profile?.accountStatus,
                    createdAt: profile?.createdAt,
                  );
                },
              ),
              divider,
              const SizedBox(height: 20),
              _LawyerSettingsBody(divider: divider),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings Menu Body ────────────────────────────────────────────────────────

class _LawyerSettingsBody extends StatelessWidget {
  const _LawyerSettingsBody({required this.divider});
  final Divider divider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AccountItem(
            svgAsset: 'assets/icons/user_outline.svg',
            label: 'ملفي الشخصي',
            trailingChevronRight: true,
            onTap: () => Nav.lawyerProfileScreen(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/bag_outline.svg',
            label: 'تخصصاتي',
            trailingChevronRight: true,
            onTap: () => Nav.lawyerSpecializationsScreen(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/wallet_outline.svg',
            label: 'المحفظه',
            trailingChevronRight: true,
            onTap: () => Nav.walletScreen(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/transactions.svg',
            label: 'المعاملات المالية',
            trailingChevronRight: true,
            onTap: () => Nav.financialTransactionsScreen(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/star_outline.svg',
            label: 'تقييماتي',
            trailingChevronRight: true,
            onTap: () => Nav.lawyerRatesScreen(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/lawyer_help_center.svg',
            label: 'مركز المساعده',
            trailingChevronRight: true,
            onTap: () => Nav.helpingCenterScreen(context),
          ),
          divider,
          AccountItem(
            svgAsset: 'assets/icons/Bell_Bing.svg',
            label: 'الإشعارات',
            trailingChevronRight: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          divider,
          const SizedBox(height: 20),
          AccountItem(
            svgAsset: 'assets/icons/Logout_icon.svg',
            label: 'تسجيل الخروج',
            trailingChevronRight: false,
            iconbgColor: Colors.red,

            onTap: () async {
              final confirmed = showLogoutAndDeletAccountConfirmDialog(
                context,
                isLogout: true,
                title: 'تسجيل الخروج',
                message: 'هل أنت متأكد من رغبتك في تسجيل الخروج  ؟',
                svgAsset: 'assets/icons/Logout_icon.svg',
              );
              if (confirmed == true) {
                // TODO: implement logout
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class LawyerProfileHeader extends StatelessWidget {
  const LawyerProfileHeader({
    super.key,
    required this.theme,
    required this.textPrimary,
    required this.iconColor,
    required this.textSecondary,
    this.isLoading = false,
    this.fullName,
    this.photoUrl,
    this.accountStatus,
    this.createdAt,
  });

  final ThemeData theme;
  final Color textPrimary;
  final Color? iconColor;
  final Color? textSecondary;
  final bool isLoading;
  final String? fullName;
  final String? photoUrl;
  final String? accountStatus;
  final String? createdAt;

  // Parse ISO date to Arabic-formatted string
  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      return 'تاريخ الإنضمام : ${dt.day} / ${dt.month} / ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  bool get _isVerified => accountStatus == 'verified';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ───────────────────────────────────────────────────────
          LawyerProfileAvatar(
            photoUrl: photoUrl,
            radius: 26.h,
            isLoading: isLoading,
          ),
          SizedBox(width: 12.w),

          // ── Name + date ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? _ShimmerBox(width: 120.w, height: 14.h)
                    : Text(
                  fullName ?? '---',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                isLoading
                    ? _ShimmerBox(width: 160.w, height: 12.h)
                    : _JoinDateRow(
                  color: iconColor,
                  textColor: textSecondary,
                  dateText: _formatDate(createdAt),
                ),
              ],
            ),
          ),

          // ── Verified badge ───────────────────────────────────────────────
          if (!isLoading && _isVerified)
            Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.2),
                borderRadius: BorderRadius.circular(30.h),
                border: Border.all(color: Colors.green, width: 1),
              ),
              padding: EdgeInsets.all(7.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'موثّق',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.verified, color: Colors.green, size: 20.sp),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Join Date Row ─────────────────────────────────────────────────────────────

class _JoinDateRow extends StatelessWidget {
  final Color? color;
  final Color? textColor;
  final String dateText;

  const _JoinDateRow({this.color, this.textColor, required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Picture(getAssetIcon('Calendar.svg'), width: 20.h, height: 20.h),
        Gap(5.w),
        Expanded(
          child: Text(
            dateText.isNotEmpty ? dateText : 'تاريخ الإنضمام : ---',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: textColor?.withOpacity(.4),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).dividerColor.withOpacity(0.15);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(6.h),
      ),
    );
  }
}