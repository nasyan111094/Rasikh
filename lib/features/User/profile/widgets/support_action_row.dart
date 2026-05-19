import 'package:flutter/material.dart';


class SupportActionRow extends StatelessWidget {
  const SupportActionRow({
    super.key,
    required this.leading,
    required this.label,
    this.trailing,
    required this.onTap,
    this.startPadding = 12,
    this.endPadding = 16,
    this.gap = 8,
    this.height = 52,
    this.arrowOpacity = 0.90,
  });

  final Widget leading;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;


  final double startPadding;
  final double endPadding;
  final double gap;
  final double height;
  final double arrowOpacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final defaultTrailing = Icon(
      isRTL ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
      size: 20,
      color: cs.onSurface.withOpacity(arrowOpacity), // General/90
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsetsDirectional.only(
          start: startPadding,
          end: endPadding,
          top: 14,
          bottom: 14,
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading,
            SizedBox(width: gap),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            SizedBox(width: gap),
            trailing ?? defaultTrailing,
          ],
        ),
      ),
    );
  }
}
