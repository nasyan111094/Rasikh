import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:size_config/size_config.dart';

import '../widgets/contact_datail.dart';
import '../widgets/header_capsule_appbar_widget.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: const HeaderCapsuleAppBar(
        title: 'تواصل معنا',
        showBottomDivider: true,
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/contact_us.png',
              height: MediaQuery.of(context).size.height * 0.28,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'تواصل معنا',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'نحن دائماً سعداء بخدمتك، ويمكنك التواصل معنا عبر الوسائل المتاحة أدناه',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            ContactTileFigma(
              title: 'التواصل عبر رقم الدعم الفني',
              subtitle: '+966 576066690',
              iconAsset: 'assets/icons/call-calling.svg',
              showChevron: true,
              onTap: () {},
            ),
            const SizedBox(height: 20),
            ContactTileFigma(
              title: 'التواصل عبر البريد الإلكتروني',
              subtitle: 'info@email.com',
              iconAsset: 'assets/icons/sms.svg',
              showChevron: true,
              onTap: () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final borderRadius = BorderRadius.circular(14);

    return Material(
      color: colorScheme.surface,
      borderRadius: borderRadius,
      elevation: 1.5,
      shadowColor: colorScheme.shadow.withOpacity(0.08),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            tileColor: colorScheme.surface,
            leading: Icon(icon, color: colorScheme.primary),
            title: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textTheme.titleMedium?.color,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.hintColor,
              size: 18,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
        ),
      ),
    );
  }
}
