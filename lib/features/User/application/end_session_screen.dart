import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart' show getAssetIcon;
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/general_option_card.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../../../config/theme/colors.dart';
import '../../../core/widgets/picture.dart' show Picture;
import '../../../features/User/application/repo/video_call_repo.dart';
import 'bloc/consulation_application_cubit.dart';

class EndSessionScreen extends StatefulWidget {
  const EndSessionScreen({
    super.key,
    required this.consultationId,
    required this.lawyerId,
    required this.clientId,
  });

  final String consultationId;
  final String lawyerId;
  final String clientId;

  @override
  State<EndSessionScreen> createState() => _EndSessionScreenState();
}

class _EndSessionScreenState extends State<EndSessionScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _TimeUpDialog.show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: GeneralAppBar(
          title: 'إنهاء الجلسة',
          isBack: false,

        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(12.h),
            GeneralOptionCard(
              title: 'فتح منازعة',
              icon: Picture(getAssetIcon("doc_add.svg"), width: 25.h, height: 25.h),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => OpenDisputeDialog(
                    consultationId: widget.consultationId,
                  ),
                );
              },
            ),
            GeneralDivider(),
            GeneralOptionCard(
              title: 'تقييم الجلسة',
              icon: Picture(getAssetIcon("Stars.svg"), width: 25.h, height: 25.h),
              onTap: () {
                showRateExperienceBottomSheet(
                  context,
                  consultationId: widget.consultationId,
                  lawyerId: widget.lawyerId,
                  clientId: widget.clientId,
                );
              },
            ),
            const Spacer(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.h),
                      ),
                    ),
                    onPressed: () {
                      getIt<ConsultationApplicationCubit>().resetFlow();
                      Nav.layout(context);
                    },
                    child: Text(
                      'الرجوع للرئيسية',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Open-dispute dialog
// ─────────────────────────────────────────────────────────────────────────────

class OpenDisputeDialog extends StatefulWidget {
  const OpenDisputeDialog({
    super.key,
    required this.consultationId,
  });

  final String consultationId;

  @override
  State<OpenDisputeDialog> createState() => _OpenDisputeDialogState();
}

class _OpenDisputeDialogState extends State<OpenDisputeDialog> {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  bool _isSubmitting = false;
  final VideoCallRepo _repo = VideoCallRepo();

  Future<void> _showSentDialog(BuildContext context) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Green Check Icon
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2E7D32),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
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
                  "تم إرسال طلبك , سنراجع طلبك خلال 72 –48 ساعة.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'فتح منازعة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: greyFA,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ),
                ],
              ),
              Gap(16.h),

              /// --- Reason TextField ---
              Text(
                'سبب المنازعة *',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(6.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.h),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Picture(getAssetIcon("doc_add.svg"),
                          width: 25.h, height: 25.h),
                    ),
                    Expanded(
                      child: TextField(
                        controller: reasonController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'اكتب سبب المنازعة',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Gap(16.h),

              /// --- Details TextField ---
              Text(
                'تفاصيل المنازعة *',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(6.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.h),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: detailsController,
                  maxLines: 5,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'اكتب هنا ...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                ),
              ),

              Gap(20.h),

              /// --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    theme.colorScheme.primary.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                    if (reasonController.text.trim().isEmpty ||
                        detailsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text('الرجاء إدخال جميع الحقول المطلوبة'),
                        ),
                      );
                      return;
                    }

                    setState(() => _isSubmitting = true);
                    final result = await _repo.openDispute(
                      consultationId: widget.consultationId,
                      reason: reasonController.text.trim(),
                      description: detailsController.text.trim(),
                    );
                    setState(() => _isSubmitting = false);
                    result.fold(
                          (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                              Text('فشل إرسال المنازعة: $error')),
                        );
                      },
                          (_) {
                        Navigator.pop(context);
                        _showSentDialog(context);
                      },
                    );
                  },
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'إرسال الآن!',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rate-experience bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

void showRateExperienceBottomSheet(
    BuildContext context, {
      required String consultationId,
      required String lawyerId,
      required String clientId,
    }) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  double rating = 0.0;
  bool isSubmitting = false;
  final TextEditingController feedbackController = TextEditingController();
  final repo = VideoCallRepo();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      backgroundColor: greyFA,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  const Gap(12),
                  Text(
                    'قَيِّم تجربتك معنا',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(6),
                  Text(
                    'تقييمك يعكس مدى رضاك ويساعدنا على التحسين.',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  GeneralDivider(height: 26.h),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    glowColor: Colors.yellow,
                    glow: true,
                    itemCount: 5,
                    itemPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0),
                    unratedColor: theme.disabledColor.withOpacity(0.2),
                    itemBuilder: (context, _) =>
                        Picture(getAssetIcon("star.svg"),
                            color: theme.primaryColor),
                    onRatingUpdate: (r) => setState(() => rating = r),
                  ),
                  const Gap(20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'كيف كانت تجربتك؟ أحكي لنا',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const Gap(8),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'اكتب هنا ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: greyFA),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: greyFA),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.disabledColor.withOpacity(.05),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                  const Gap(20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                        if (rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text('الرجاء اختيار تقييم')),
                          );
                          return;
                        }
                        setState(() => isSubmitting = true);
                        final result = await repo.submitRating(
                          consultationId: consultationId,
                          lawyerId: lawyerId,
                          clientId: clientId,
                          stars: rating.toInt(),
                          comment: feedbackController.text.trim(),
                        );
                        setState(() => isSubmitting = false);
                        result.fold(
                              (error) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'فشل إرسال التقييم: $error')),
                            );
                          },
                              (_) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'تم إرسال تقييمك بنجاح')),
                            );
                          },
                        );
                      },
                      child: isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        'إرسال الآن',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Time-up notice for clients
// ─────────────────────────────────────────────────────────────────────────────

class _TimeUpDialog {
  static Future<void> show(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.timer_off,
                    color: colorScheme.onErrorContainer,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'انتهت مدة الجلسة',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'لقد انتهت المدة المحددة للاستشارة.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}

class GeneralOptionCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback? onTap;

  const GeneralOptionCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0.h),


        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              icon ,

              Gap(8.w),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Gap(8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.w,
                color: theme.iconTheme.color?.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



