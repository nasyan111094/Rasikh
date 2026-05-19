import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

class ContactTileFigma extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final VoidCallback? onTap;
  final bool showChevron;

  const ContactTileFigma({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    this.onTap,
    this.showChevron = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    final cardRadius = 16.h;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),

        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: greyFA,
              width: 1.w,
            ),
            borderRadius: BorderRadius.circular(cardRadius),
     
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🟤 Icon Container
              Container(
                height: 52.h,
                width: 52.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.h),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.3),
                    width: 1.w,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 26.w,
                    height: 26.h,
                    colorFilter: ColorFilter.mode(
                      cs.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // 📝 Title + Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: textTheme.bodySmall?.color?.withOpacity(0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // ➡️ Chevron
              if (showChevron) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: theme.hintColor.withOpacity(0.8),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
