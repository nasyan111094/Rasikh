
import 'package:rasikh/config/localization/loc_keys.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/navigation/nav.dart';
import '../../../core/theme/sizes.dart';
import '../../../core/utils/get_asset_path.dart';
import '../../../core/widgets/general_app_bar.dart';
import '../../../core/widgets/general_divider.dart';

import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart';
import 'widgets/consultation_flow_widgets.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with WidgetsBindingObserver {
  int currentSelectedIndex = 0;
  bool _isCheckingPayment = false;
  bool _hasOpenedPaymentUrl = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed && _hasOpenedPaymentUrl && !_isCheckingPayment) {
      _checkPaymentAfterReturn();
    }
  }


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
                    Loc.requestConfirmed(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFAE895D),
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    Loc.requestConfirmedConnectingLawyer(secondsLeft),
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
                  Loc.requestConfirmed(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFAE895D),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  Loc.appointmentBookedSuccessfully(),
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
                    child: Text(Loc.backToHomeAlt(),
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
        title: Text(Loc.createConsultationFailed(),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Text(error, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Loc.okAction()),
          ),
        ],
      ),
    );
  }


  Future<void> _handlePay(BuildContext context, ConsultationState state) async {
    final cubit = context.read<ConsultationApplicationCubit>();

    if (state.createdConsultation == null) {
      _showErrorDialog(context, Loc.consultationMustBeCreatedFirst());
      return;
    }

    if (currentSelectedIndex == 1) {
      await cubit.payWithWallet();
    } else {
      await cubit.initiatePayment();
    }

    if (!mounted) return;
    final newState = cubit.state;

    if (newState.paymentStatus == ConsultationStatus.failure) {
      _showErrorDialog(context, newState.paymentError ?? Loc.errorDuringPayment());
      return;
    }

    if (newState.paymentStatus == ConsultationStatus.success) {
      if (currentSelectedIndex == 1) {
        if (state.selectedConsultationType == ConsultationType.scheduled) {
          _showOrderConfirmedScheduled(context);
        } else {
          _showOrderConfirmedInstant(context);
        }
      } else {
        final paymentUrl = newState.paymentData?['payment']?['PaymentURL'];
        if (paymentUrl != null) {
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            setState(() => _hasOpenedPaymentUrl = true);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            _showErrorDialog(context, Loc.unableToOpenPaymentLink());
          }
        } else {
          _showErrorDialog(context, Loc.paymentLinkNotReceived());
        }
      }
    }
  }


  Future<void> _checkPaymentAfterReturn() async {
    if (_isCheckingPayment) return;
    setState(() => _isCheckingPayment = true);

    final cubit = context.read<ConsultationApplicationCubit>();
    final state = cubit.state;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: 16.w),
            Text(Loc.checkingPaymentStatus()),
          ],
        ),
      )
    );

    final paymentStatus = await cubit.checkPaymentStatus();

    if (!mounted) return;
    Navigator.pop(context);

    setState(() => _isCheckingPayment = false);

    switch (paymentStatus) {
      case 'paid':
        if (state.selectedConsultationType == ConsultationType.scheduled) {
          _showOrderConfirmedScheduled(context);
        } else {
          _showOrderConfirmedInstant(context);
        }
        break;
      case 'failed':
        _showErrorDialog(context, Loc.paymentFailedTryAgain());
        break;
      case 'pending':
        _showPendingDialog(context);
        break;
      case 'error':
        _showErrorDialog(context, Loc.errorCheckingPaymentStatus());
        break;
    }
  }

  Future<void> _showPendingDialog(BuildContext context) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(Loc.processingPayment()),
        content: Text(Loc.checkingPaymentStatusMayTakeMinutes()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Nav.layout(context);
            },
            child: Text(Loc.backToHomeAlt()),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Nav.layout(context);
          }
        },
        child: Scaffold(
          appBar: GeneralAppBar(
            title: Loc.payment(),
            onTapArrow: () => Nav.layout(context),
            backIcon: Icons.arrow_back,
            backIconSize: 22,
          ),
        body: BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
          builder: (context, state) {
            final lawyer =
                state.selectedLawyerDetail ?? state.recommendedLawyer;
            final pricing = state.selectedPricing;
            final isScheduled = state.isScheduled;
            final isLoading =
                state.paymentStatus == ConsultationStatus.loading;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ConsultationFlowSpacing.horizontal,
                  ),
                  child: ConsultationFlowStepper(
                      activeStep: isScheduled ? 6 : 5),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ConsultationFlowSpacing.horizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                ? Loc.payNowToConfirmAppointment()
                                : Loc.payNowToStartChat(),
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.green,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),

                        buildAnimatedCard(
                          title: Loc.consultationDetails(),
                          titleIconPath: 'chat.svg',
                          index: 0,
                          children: [
                            rowItem(Loc.consultationType(),
                                state.selectedConsultationType.arabicLabel),
                            rowItem(Loc.consultationTitle(),
                                state.consultationTitle),
                            rowItem(
                              Loc.specialization(),
                              state.selectedSpecialization?.name ?? '—',
                            ),
                            if (state.selectedSubSpecializations.isNotEmpty)
                              rowItem(
                                Loc.subSpecialization(),
                                state.selectedSubSpecializations
                                    .map((s) => s.name)
                                    .join(Loc.listSeparator()),
                              ),
                            if (isScheduled && state.startTime != null)
                              rowItem(
                                Loc.sessionDate(),
                                _formatDateTime(state.startTime!),
                              ),
                            rowItem(
                              Loc.duration(),
                              pricing?.durationLabel ?? '—',
                              hasDivider: false,
                            ),
                          ],
                        ),

                        if (lawyer != null)
                          buildAnimatedCard(
                            title: Loc.lawyerData(),
                            titleIconPath: 'user.svg',
                            index: 1,
                            children: [
                              rowItem(Loc.nameLabel(), lawyer.fullName),
                              rowItem(Loc.city(), lawyer.city ?? '—'),
                              if (lawyer.experienceYears != null)
                                rowItem(Loc.yearsOfExperience(),
                                    '${lawyer.experienceYears}'),
                              rowItem(
                                Loc.rating(),
                                '${lawyer.rating.toStringAsFixed(1)} ⭐',
                                hasDivider: false,
                              ),
                            ],
                          ),

                        if (pricing != null)
                          buildAnimatedCard(
                            title: Loc.paymentSummary(),
                            titleIconPath: 'sr.svg',
                            index: 2,
                            children: [
                              rowItem(
                                Loc.consultationPrice(),
                                pricing.priceLabel,
                                isPrice: true,
                                valueColor: colorScheme.primary,
                                hasDivider: false,
                              ),
                            ],
                          ),

                        buildAnimatedCard(
                          title: Loc.paymentMethod(),
                          titleIconPath: 'card.svg',
                          index: 3,
                          children: [
                            _PaymentOption(
                              title: Loc.myFatoorah(),
                              assetPath: 'myfatoorah.jpeg',
                              selected: currentSelectedIndex == 0,
                              onTap: () =>
                                  setState(() => currentSelectedIndex = 0),
                            ),
                            SizedBox(height: 8.h),
                            _PaymentOption(
                              title: Loc.myWallet(),
                              assetPath: 'wallet.png',
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

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ConsultationFlowSpacing.horizontal,
                  ),
                  child: ConsultationBottomButton(
                    text: Loc.payNow(),
                    isLoading: isLoading,
                    onPressed: () => _handlePay(context, state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
        ),
      );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt .toLocal();

    final arabicDays = [
      Loc.mondayAlt(), Loc.tuesdayAlt(), Loc.wednesday(), Loc.thursday(),
      Loc.friday(), Loc.saturday(), Loc.sunday(),
    ];
    final arabicMonths = [
      Loc.january(), Loc.february(), Loc.march(), Loc.april(), Loc.may(), Loc.june(),
      Loc.july(), Loc.august(), Loc.september(), Loc.october(), Loc.november(), Loc.december(),
    ];
    final dayName = arabicDays[local.weekday == 7 ? 6 : local.weekday - 1];
    final displayHour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? Loc.pmShort() : Loc.amShort();
    return '$dayName ${local.day} ${arabicMonths[local.month - 1]} – $displayHour:$minute $period';
  }
}


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
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                width: 40.h,
                height: 40.h,
                child: Picture(
                  getAssetImage(assetPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10.w,) , 
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