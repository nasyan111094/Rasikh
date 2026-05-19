import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';

/// AppBar بكبسولة سهم قبل العنوان (يسار/الشمال) تمامًا مثل فيجما.
/// السهم بيتحدد تلقائيًا حسب اتجاه اللغة:
/// - RTL (عربي)  → Arrow Back  (يبص شمال)
/// - LTR (إنجليزي) → Arrow Forward (يبص يمين)
class HeaderCapsuleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  // تخصيصات اختيارية (كلها ممكن تتأثر بالثيم)
  final Color? capsuleColor;
  final Color? iconColor;
  final IconData? icon;
  final bool showBottomDivider;
  final double capsuleSize;
  final double capsuleRadius;
  final double iconSize;
  final double titleGap;

  const HeaderCapsuleAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.capsuleColor,
    this.iconColor,
    this.icon,
    this.showBottomDivider = true,
    this.capsuleSize = 38,
    this.capsuleRadius = 12,
    this.iconSize = 20,
    this.titleGap = 12,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // تحديد الأيقونة حسب اللغة
    final IconData arrowIcon = icon ??
        (isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded);

    // ألوان حسب الثيم
    final Color effectiveCapsuleColor =
        capsuleColor ?? (isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surfaceContainerLow);

    final Color effectiveIconColor =
        iconColor ?? theme.iconTheme.color ?? (isDark ? Colors.white : Colors.black87);

    final Color titleColor =
        theme.textTheme.titleMedium?.color ?? (isDark ? Colors.white : Colors.black87);

    final Color dividerColor = theme.dividerColor.withOpacity(0.8);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _CapsuleButton(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            bg: greyFA,
            radius: capsuleRadius,
            size: capsuleSize,
            icon: arrowIcon,
            iconColor: Colors.black,
            iconSize: iconSize,
          ),
          SizedBox(width: titleGap),
          Text(
            title,
            textAlign: TextAlign.left,
            style: theme.textTheme.titleMedium?.copyWith(

              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
        ],
      ),
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      bottom: showBottomDivider
          ? PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: dividerColor,
        ),
      )
          : null,
    );
  }
}

class _CapsuleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color bg;
  final double size;
  final double radius;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  const _CapsuleButton({
    required this.onTap,
    required this.bg,
    required this.size,
    required this.radius,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
