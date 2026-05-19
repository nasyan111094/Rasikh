import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

class LegalConsultationCard extends StatelessWidget {
  final VoidCallback onPressed;

  const LegalConsultationCard({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = Directionality.of(context);
    final isRtl = textDirection == TextDirection.rtl;

    final Color primaryGold = const Color(0xFFB49567);
    final Color textGray = theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? const Color(0xFF6F6F6F);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration:  BoxDecoration(

      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: primaryGold.withOpacity(0.4),
        width: 1.2,
      ),
    ),

    child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Icon at the start ----
          isRtl ? _chatIcon(primaryGold) : _questionMark(primaryGold),
          Gap(12.w),

          // ---- Text + Button ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استشارات قانونية احترافية',
                  textAlign: TextAlign.start,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryGold,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                Gap(8.h),
                Text(
                  'احصل على استشارات قانونية سريعة وآمنة مع محامين مرخصين.',
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textGray,
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
                Gap(14.h),
                ElevatedButton.icon(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h),
                    elevation: 0,
                  ),
                  icon: Icon(
                    isRtl ? Icons.arrow_back : Icons.arrow_forward,
                    size: 18.sp,
                  ),
                  label: const Text(
                    'استشر الآن',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Gap(10.w),

          // ---- Icon at the end ----
          isRtl ? _questionMark(primaryGold) : _chatIcon(primaryGold),
        ],
      ),
    );
  }

  Widget _questionMark(Color color) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
          color: color.withOpacity(0.2)
      ),
      child: Container(
        
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5), width: 1.2),
        ),
        child: Center(
          child: Icon(Icons.question_mark, color: color, size: 10.w),
        ),
      ),
    );
  }

  Widget _chatIcon(Color color) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/chat.svg',
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: 22.w,
          height: 22.w,
        ),
      ),
    );
  }
}
