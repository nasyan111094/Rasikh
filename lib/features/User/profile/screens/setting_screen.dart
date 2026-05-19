import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rasikh/config/theme/colors.dart';

import '../../../../config/navigation/nav.dart';
import '../widgets/dialog_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textDirection = Directionality.of(context);
    final isRTL = textDirection == TextDirection.rtl;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isRTL),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // تعديل رقم الجوال
            _SettingsRow(
              leading: SvgPicture.asset(
                'assets/icons/Pen_New_Square.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              label: 'تعديل رقم الجوال',
              trailing: Icon(
                isRTL
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: colorScheme.onSurface,
              ),
              onTap: ()
              {
                Nav.changePhoneNumber(context);
              },
            ),

            const SizedBox(height: 12),
            Divider(
              color: colorScheme.outline.withOpacity(0.2),
              thickness: 1,
              height: 1,
            ),

            const SizedBox(height: 24),

            // حذف الحساب
            _DeleteRow(
              label: 'حذف الحساب',
              onTap: ()
              async
              {
                showLogoutAndDeletAccountConfirmDialog(context, title: "حذف الحساب", message: "هل أنت متأكد من أنك تريد حذف الحساب  ؟", svgAsset: "assets/icons/Trash_Bin.svg") ;
              },
            ),
          ],
        ),
      ),
    );
  }
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isRTL) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 56,
      backgroundColor:
      theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Arrow back button
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: greyFA,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  !isRTL
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Text(
                'الإعدادات',
                textAlign: TextAlign.right,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          color: colorScheme.outline.withOpacity(0.2),
          thickness: 1,
          height: 1,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.leading,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final Widget leading;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _DeleteRow extends StatelessWidget {
  const _DeleteRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/Trash_Bin.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.error,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
