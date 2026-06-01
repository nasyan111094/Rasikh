// ─────────────────────────────────────────────────────────────────────────────
// payment_screen.dart  (Step 5 / Final)
// UI unchanged — "ادفع الآن" now calls cubit.createConsultation()
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../core/theme/sizes.dart';
import '../../../core/utils/get_asset_path.dart';
import '../../../core/widgets/auth_stepper.dart';
import '../../../core/widgets/general_app_bar.dart';
import '../../../core/widgets/general_divider.dart';

import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int currentSelectedIndex = 0;

  // ── Dialogs ───────────────────────────────────────────────────────────────

  Future<void> _showOrderConfirmedInstant(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    int secondsLeft = 10;
    Timer? timer;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (ctx, setDState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (secondsLeft > 0) {
              setDState(() => secondsLeft--);
            } else {
              t.cancel();
              Navigator.pop(dialogContext);
              Nav.connectingToLawyerScreen(context);
            }
          });

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.h)),
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/anims/success.json',
                    width: 120.w,
                    height: 120.h,
                    repeat: false,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "تم تأكيد طلبك",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFAE895D),
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "تم تأكيد طلبك... سنربطك الآن بأفضل محامي متاح (حتى $secondsLeft ثانية).",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _showOrderConfirmedScheduled(BuildContext context) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2E7D32),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  "تم تأكيد طلبك",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFAE895D),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "تم حجز موعدك بنجاح",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[700], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE895D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Nav.layout(context);
                    },
                    child: const Text("العودة للرئيسية",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String error) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: Text('فشل إنشاء الاستشارة',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Text(error, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  // ── Pay handler ───────────────────────────────────────────────────────────

  Future<void> _handlePay(BuildContext context, ConsultationState state) async {
    // Create consultation via API
    await context.read<ConsultationCubit>().createConsultation();

    // Re-read state after await
    if (!mounted) return;
    final newState = context.read<ConsultationCubit>().state;

    if (newState.createStatus == ConsultationStatus.failure) {
      _showErrorDialog(context, newState.createError ?? 'حدث خطأ ما');
      return;
    }

    // Success – navigate based on type
    if (state.selectedConsultationType == ConsultationType.scheduled) {
      _showOrderConfirmedScheduled(context);
    } else {
      _showOrderConfirmedInstant(context);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const GeneralAppBar(title: "الدفع"),
        body: BlocBuilder<ConsultationCubit, ConsultationState>(
          builder: (context, state) {
            final lawyer =
                state.selectedLawyerDetail ?? state.recommendedLawyer;
            final pricing = state.selectedPricing;
            final isScheduled = state.isScheduled;
            final isLoading =
                state.createStatus == ConsultationStatus.loading;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 24.h, horizontal: 16.w),
                  child: const AuthStepperWidget(
                      activeStep: 5, totalSteps: 5),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Notice banner ──────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isScheduled
                                ? "قم بالدفع الآن لتأكيد موعدك مع المحامي."
                                : "قم بالدفع الآن وسيتم تحويلك مباشرة إلى المحادثة مع المحامي المختص.",
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.green,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),

                        // ── Consultation summary card ──────────────
                        buildAnimatedCard(
                          title: 'تفاصيل الاستشارة',
                          titleIconPath: 'chat.svg',
                          index: 0,
                          children: [
                            rowItem('نوع الاستشارة',
                                state.selectedConsultationType.arabicLabel),
                            rowItem('عنوان الاستشارة',
                                state.consultationTitle),
                            rowItem(
                              'التخصص',
                              state.selectedSpecialization?.name ?? '—',
                            ),
                            if (state.selectedSubSpecializations.isNotEmpty)
                              rowItem(
                                'التخصص الفرعي',
                                state.selectedSubSpecializations
                                    .map((s) => s.name)
                                    .join('، '),
                              ),
                            if (isScheduled && state.startTime != null)
                              rowItem(
                                'تاريخ الجلسة',
                                _formatDateTime(state.startTime!),
                              ),
                            rowItem(
                              'المدة',
                              pricing?.durationLabel ?? '—',
                              hasDivider: false,
                            ),
                          ],
                        ),

                        // ── Lawyer card ────────────────────────────
                        if (lawyer != null)
                          buildAnimatedCard(
                            title: 'بيانات المحامي',
                            titleIconPath: 'user.svg',
                            index: 1,
                            children: [
                              rowItem('الاسم', lawyer.fullName),
                              rowItem('المدينة', lawyer.city ?? '—'),
                              if (lawyer.experienceYears != null)
                                rowItem('سنوات الخبرة',
                                    '${lawyer.experienceYears}'),
                              rowItem(
                                'التقييم',
                                '${lawyer.rating.toStringAsFixed(1)} ⭐',
                                hasDivider: false,
                              ),
                            ],
                          ),

                        // ── Pricing card ───────────────────────────
                        if (pricing != null)
                          buildAnimatedCard(
                            title: 'ملخص الدفع',
                            titleIconPath: 'sr.svg',
                            index: 2,
                            children: [
                              rowItem(
                                'سعر الاستشارة',
                                pricing.priceLabel,
                                isPrice: true,
                                valueColor: colorScheme.primary,
                                hasDivider: false,
                              ),
                            ],
                          ),

                        // ── Payment method ─────────────────────────
                        buildAnimatedCard(
                          title: 'طريقة الدفع',
                          titleIconPath: 'card.svg',
                          index: 3,
                          children: [
                            _PaymentOption(
                              title: 'مدى',
                              assetPath: 'mada.png',
                              selected: currentSelectedIndex == 0,
                              onTap: () =>
                                  setState(() => currentSelectedIndex = 0),
                            ),
                            SizedBox(height: 8.h),
                            _PaymentOption(
                              title: 'فيزا / ماستركارد',
                              assetPath: 'visa.png',
                              selected: currentSelectedIndex == 1,
                              onTap: () =>
                                  setState(() => currentSelectedIndex = 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Pay button ─────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 16.h),
                  child: SizedBox(
                    height: 48.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _handlePay(context, state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        "ادفع الآن",
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  String _formatDateTime(DateTime dt) {
    const arabicDays = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد',
    ];
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final dayName = arabicDays[dt.weekday == 7 ? 6 : dt.weekday - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'م' : 'ص';
    return '$dayName ${dt.day} ${arabicMonths[dt.month - 1]} – $hour:$minute $period';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable card builder — identical to original
// ─────────────────────────────────────────────────────────────────────────────

Widget buildAnimatedCard({
  required String title,
  String? titleIconPath,
  required List<Widget> children,
  required int index,
  bool showStatus = false,
}) {
  return AnimationConfiguration.staggeredList(
    position: index,
    duration: const Duration(milliseconds: 500),
    child: SlideAnimation(
      horizontalOffset: 120.0,
      curve: Curves.easeOutCubic,
      child: FadeInAnimation(
        child: Builder(builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.h),
              border: Border.all(
                  color: theme.disabledColor.withOpacity(.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (titleIconPath != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.h),
                          color:
                          colorScheme.primary.withOpacity(.1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Picture(
                            getAssetIcon(titleIconPath),
                            width: 20.h,
                            height: 20.h,
                            fit: BoxFit.cover,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    Gap(10.w),
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                GeneralDivider(height: h20),
                AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 400),
                      childAnimationBuilder: (child) => SlideAnimation(
                        horizontalOffset: 60.0,
                        curve: Curves.easeOut,
                        child: FadeInAnimation(child: child),
                      ),
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// rowItem — identical to original
// ─────────────────────────────────────────────────────────────────────────────

Widget rowItem(
    String label,
    String value, {
      bool hasDivider = true,
      bool isPrice = false,
      String? iconPath,
      bool? blackDivider = false,
      Color? valueColor,
    }) {
  return Builder(builder: (context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Row(
          children: [
            if (iconPath != null)
              Picture(
                getAssetIcon(iconPath),
                width: 20.h,
                height: 20.h,
                fit: BoxFit.cover,
                color: colorScheme.onSurfaceVariant,
              ),
            Gap(6.w),
            Text(
              label,
              style: textTheme.titleSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? colorScheme.onSurface,
                    ),
                  ),
                  if (isPrice)
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SvgPicture.asset(
                        "assets/icons/sr.svg",
                        width: 20.h,
                        height: 20.h,
                        color: valueColor ?? colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        hasDivider
            ? GeneralDivider(height: 16.h)
            : const SizedBox(),
      ],
    );
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// _PaymentOption — identical to original
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentOption extends StatelessWidget {
  final String title;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : theme.colorScheme.surface,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Picture(
              getAssetImage(assetPath),
              width: 150.w,
              height: 40.h,
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: selected ? colorScheme.primary : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
