import 'package:flutter/material.dart';

import '../../../../config/navigation/nav.dart';
import '../../../../Shared/widgets/account_item_widget.dart';
import '../widgets/dialog_widget.dart';
import 'profile_edit_screen.dart';
import 'financial_transactions_screen.dart';
import 'support_help_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary = theme.textTheme.bodyMedium?.color?.withOpacity(0.7);
    final dividerColor = theme.dividerColor.withOpacity(0.2);
    final iconColor = textSecondary;
    final divider = Divider(color: dividerColor, thickness: 1, height: 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ??
              theme.scaffoldBackgroundColor,
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/avatar.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فهد بن فيصل',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _LocationRow(
                              color: iconColor, textColor: textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              divider,
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    AccountItem(
                      svgAsset: 'assets/icons/Pen_New_Square.svg',

                      label: 'تعديل البيانات الشخصية',
                      trailingChevronRight: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileEditScreen(),
                        ),
                      ),
                    ),
                    divider,
                    AccountItem(
                      svgAsset: 'assets/icons/Wallet_Money.svg',
                      label: 'المعاملات المالية',
                      trailingChevronRight: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FinancialTransactionsScreen(),
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
                          builder: (_) => const SupportHelpScreen(),
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
                        final confirmed = await showLogoutAndDeletAccountConfirmDialog(
                          context,
                          title: 'تسجيل الخروج',
                          message: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
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
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final Color? color;
  final Color? textColor;
  const _LocationRow({this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'المملكة العربية السعودية - الرياض',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: textColor!.withOpacity(.4),
            ),
          ),
        ),
      ],
    );
  }
}
