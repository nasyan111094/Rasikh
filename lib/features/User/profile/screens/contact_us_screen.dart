// features/User/profile/screens/contact_us_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../../core/get_it_service/get_it_service.dart';
import '../../../Lawyer/lawyer_Settings/Repo/help_center_repo.dart';
import '../../../Lawyer/lawyer_Settings/bloc/help_center/contact_cubit.dart';
import '../widgets/contact_datail.dart';
import '../widgets/header_capsule_appbar_widget.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ContactCubit(getIt<HelpCenterRepo>())..fetchContact(),
      child: const _ContactUsView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ContactUsView extends StatelessWidget {
  const _ContactUsView();

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _callPhone(String phone) =>
      _launch('tel:$phone');

  Future<void> _openWhatsApp(String phone) =>
      _launch('https://wa.me/$phone');

  Future<void> _sendEmail(String email) =>
      _launch('mailto:$email');

  Future<void> _openUrl(String url) => _launch(url);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const HeaderCapsuleAppBar(
        title: 'تواصل معنا',
        showBottomDivider: true,
      ),
      body: BlocConsumer<ContactCubit, ContactState>(
        listenWhen: (_, s) => s is ContactFailure,
        listener: (context, state) {
          if (state is ContactFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // ── Shimmer ───────────────────────────────────────────────────────
          if (state is ContactLoading) {
            return const _ContactShimmer();
          }

          // ── Error (no data yet) ───────────────────────────────────────────
          if (state is ContactFailure) {
            return _ErrorBody(
              message: state.message,
              onRetry: () =>
                  context.read<ContactCubit>().fetchContact(),
            );
          }

          // ── Loaded ────────────────────────────────────────────────────────
          if (state is ContactLoaded) {
            final contact = state.contact;

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<ContactCubit>().refreshContact(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/contact_us.png',
                    height:
                    MediaQuery.of(context).size.height * 0.28,
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
                      color: textTheme.bodyMedium?.color
                          ?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [


                          // ── Phone ────────────────────────────────────────────
                          if (contact.phone.isNotEmpty) ...[
                            ContactTileFigma(
                              title: 'التواصل عبر رقم الدعم الفني',
                              subtitle: contact.phone,
                              iconAsset: 'assets/icons/call-calling.svg',
                              showChevron: true,
                              onTap: () => _callPhone(contact.phone),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Email ─────────────────────────────────────────────
                          if (contact.email.isNotEmpty) ...[
                            ContactTileFigma(
                              title: 'التواصل عبر البريد الإلكتروني',
                              subtitle: contact.email,
                              iconAsset: 'assets/icons/sms.svg',
                              showChevron: true,
                              onTap: () => _sendEmail(contact.email),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── WhatsApp ──────────────────────────────────────────
                          if (contact.whatsapp.isNotEmpty) ...[
                            ContactTileFigma(
                              title: 'التواصل عبر واتساب',
                              subtitle: contact.whatsapp,
                              iconAsset: 'assets/icons/whatsapp.svg',
                              showChevron: true,
                              onTap: () => _openWhatsApp(contact.whatsapp),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Social Links ──────────────────────────────────────
                          ...contact.socialLinks.map(
                                (link) => Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: ContactTileFigma(
                                title: 'تابعنا على ${link.platform}',
                                subtitle: link.url,
                                iconAsset: 'assets/icons/link.svg',
                                showChevron: true,
                                onTap: () => _openUrl(link.url),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _ContactShimmer extends StatelessWidget {
  const _ContactShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Image placeholder
            Container(
              height: MediaQuery.of(context).size.height * 0.28,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            // Title placeholder
            Container(
              height: 22,
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle placeholder
            Container(
              height: 14,
              width: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 28),
            // Tile placeholders
            ..._buildTilePlaceholders(3),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTilePlaceholders(int count) {
    return List.generate(count, (_) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    });
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