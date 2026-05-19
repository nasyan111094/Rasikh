import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';
import '../../../../config/theme/colors.dart' as AppColors;
import '../../../../core/utils/get_asset_path.dart';
import '../../../../core/widgets/picture.dart';


/// حالة العملية
enum TxStatus { paid, failed }

class TransactionCard extends StatelessWidget {
  final String id;
  final String title;
  final String amountText;
  final String date;
  final TxStatus status;

  const TransactionCard({
    super.key,
    required this.id,
    required this.title,
    required this.amountText,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🎨 ألوان ديناميكية حسب الثيم
    final bgColor = theme.cardColor;
    final borderColor = theme.dividerColor.withOpacity(0.2);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.7);
    final dividerColor = theme.dividerColor.withOpacity(0.2);
    final iconBg = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF3EFE8);

    return Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── الصف العلوي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#$id',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: textColor,
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),

            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1, color: dividerColor),
            const SizedBox(height: 12),

            // ── الصف الرئيسي
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1️⃣ الأيقونة
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Picture(getAssetIcon("wallet.svg")),
                ),

                const SizedBox(width: 12),

                // 2️⃣ العنوان والمبلغ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        amountText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // يوسّط كل المحتوى أفقياً
                  crossAxisAlignment: CrossAxisAlignment.center, // يوسّطهم عمودياً
                  children: [
                   Picture(getAssetIcon("Calendar.svg") , width: 20.w,height: 20.w,),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                        fontFamily: "cairo"
                      ),
                    ),
                  ],
                )

              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// شارة الحالة: "تم الدفع" أو "فشل الدفع"
class _StatusChip extends StatelessWidget {
  final TxStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = status == TxStatus.paid;

    // 🎨 ديناميكية حسب الثيم
    final bg = isPaid
        ? Colors.green.withOpacity(0.1)
        : theme.colorScheme.error.withOpacity(0.1);
    final fg = isPaid
        ? Colors.green
        : theme.colorScheme.error;

    final text = isPaid ? 'تم الدفع' : 'فشل الدفع';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          
          fontWeight: FontWeight.w700,
          height: 1.6,
          color: fg,
        ),
      ),
    );
  }
}
