import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

class AccountItem extends StatelessWidget {
  final String svgAsset;
  final String label;
  final VoidCallback? onTap;
  final bool trailingChevronRight;
  final Color ? iconbgColor ;

  const AccountItem({
    super.key,
    required this.svgAsset,
    required this.label,
    this.onTap,
    this.trailingChevronRight = true,
    this.iconbgColor ,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final iconColor = theme.iconTheme.color ?? Colors.grey;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.h),
      highlightColor: cs.primary.withOpacity(0.05),
      splashColor: cs.primary.withOpacity(0.08),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        color: Colors.transparent,
        child: Row(
          children: [
            // 🟢 Icon Circle
            Container(
              width: 36.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconbgColor!=null ? iconbgColor!.withOpacity(0.1) : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03))),

              alignment: Alignment.center,
              child: SvgPicture.asset(
                svgAsset,
                width: 22.w,
                height: 22.w,

                colorFilter: ColorFilter.mode(iconbgColor??  textColor, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 8.w),

            // 📝 Label
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,

                  height: 1.5,
                  color: iconbgColor ??  textColor,
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // ➡️ Trailing Chevron
            if (trailingChevronRight)
              Icon(
                Icons.chevron_right_rounded,
                size: 22.w,
                color: iconColor.withOpacity(0.7),
              ),
          ],
        ),
      ),
    );
  }
}
