import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/features/Lawyer/lawyer_Settings/screens/helping_center_screen.dart';

import '../../../../config/navigation/nav.dart';
import '../../../../Shared/widgets/account_item_widget.dart';
import '../../../common/notifications/notifications_screen.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/dialog_widget.dart';
import 'profile_edit_screen.dart';
import 'financial_transactions_screen.dart';
import 'support_help_screen.dart';

// ProfileScreen reads the singleton ProfileCubit that is provided above
// the bottom-nav scaffold via BlocProvider.value(value: getIt<ProfileCubit>()).
// It does NOT create its own cubit.

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh profile each time this tab becomes active.
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme         = Theme.of(context);
    final textPrimary   = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary = theme.textTheme.bodyMedium?.color?.withOpacity(0.7);
    final dividerColor  = theme.dividerColor.withOpacity(0.2);
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
          titleSpacing: 16,
          title: Text(
            'حسابي',
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
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final profile = state.data;

              // Avatar image provider
              ImageProvider avatarImage;
              if (profile?.avatar != null) {
                avatarImage = NetworkImage(
                  'http://89.117.60.202:3050${profile!.avatar}',
                );
              } else {
                avatarImage = const AssetImage('assets/images/avatar.png');
              }

              final locationText = profile?.city != null
                  ? 'المملكة العربية السعودية - ${profile!.city}'
                  : 'المملكة العربية السعودية';

              return Column(
                children: [
                  // ── Header: avatar + name + city ──────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        ClipOval(
                          child: state.loading && profile == null
                              ? Container(
                            width: 52,
                            height: 52,
                            color: theme.colorScheme.surfaceVariant,
                          )
                              : Image(
                            image: avatarImage,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/avatar.png',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name skeleton while loading
                              state.loading && profile == null
                                  ? Container(
                                height: 16,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                                  : Text(
                                profile?.fullName ?? '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _LocationRow(
                                locationText: locationText,
                                textColor: textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  divider,
                  const SizedBox(height: 20),

                  // ── Menu items ────────────────────────────────────────────
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        AccountItem(
                          svgAsset: 'assets/icons/Pen_New_Square.svg',
                          label: 'تعديل البيانات الشخصية',
                          trailingChevronRight: true,
                          onTap: () async {
                            // Pass the SAME singleton cubit into the route
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ProfileCubit>(),
                                  child: const ProfileEditScreen(),
                                ),
                              ),
                            );
                            // Refresh header after returning
                            if (context.mounted) {
                              context.read<ProfileCubit>().loadProfile();
                            }
                          },
                        ),
                        divider,
                        AccountItem(
                          svgAsset: 'assets/icons/Wallet_Money.svg',
                          label: 'المعاملات المالية',
                          trailingChevronRight: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                              const FinancialTransactionsScreen(),
                            ),
                          ),
                        ),
                        divider,
                        AccountItem(
                          svgAsset: 'assets/icons/Setting_icon.svg',
                          label: 'الإعدادات',
                          trailingChevronRight: true,
                          onTap: () => Nav.settings(context),
                        ),
                        divider,
                        AccountItem(
                          svgAsset: 'assets/icons/Chat_Dots.svg',
                          label: 'الدعم والمساعدة',
                          trailingChevronRight: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HelpingCenterScreen(),
                            ),
                          ),
                        ),
                        divider,
                        AccountItem(
                          svgAsset: 'assets/icons/Bell_Bing.svg',
                          label: 'الإشعارات',
                          trailingChevronRight: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
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
                            final confirmed =
                            await showLogoutAndDeletAccountConfirmDialog(
                              context,
                              isLogout: true ,
                              title: 'تسجيل الخروج',
                              message:
                              'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                              svgAsset: 'assets/icons/Logout_icon.svg',
                            );
                            if (confirmed == true) {
                              // TODO: تنفيذ عملية تسجيل الخروج هنا
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final String locationText;
  final Color? textColor;
  const _LocationRow({required this.locationText, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            locationText,
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