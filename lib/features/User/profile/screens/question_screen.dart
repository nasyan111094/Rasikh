import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

import '../widgets/header_capsule_appbar_widget.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final faqs = <FaqItem>[
      FaqItem(
        q: 'كيف أقدر أختار المحامي المناسب لقضيتي؟',
        a: 'يمكنك تصفح قائمة المحامين المتاحين في التطبيق، حيث يتم عرض التخصصات والخبرات لكل محامي بشكل واضح، كما يمكنك قراءة تقييمات العملاء السابقين لمساعدتك في اتخاذ القرار المناسب.',
      ),
      FaqItem(
        q: 'هل استشارتي تبقى سرية وآمنة؟',
        a: 'نعم، جميع الاستشارات تتم بسرية تامة ووفق معايير الأمان المعتمدة.',
      ),
      FaqItem(
        q: 'كم تستغرق مدة الرد على الاستشارة؟',
        a: 'عادةً يتم الرد خلال 24–48 ساعة، وقد تختلف المدة حسب ضغط الطلبات.',
      ),
      FaqItem(
        q: 'هل أقدر أتابع قضيتي من التطبيق مباشرة؟',
        a: 'نعم، يمكنك متابعة حالة القضية وتحديثاتها واستلام الإشعارات من داخل التطبيق.',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        appBar: const HeaderCapsuleAppBar(
          title: 'الأسئلة الشائعة',
          showBottomDivider: true,
        ),
        body: ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
          itemBuilder: (context, index) => _FaqTile(item: faqs[index]),
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemCount: faqs.length,
        ),
      ),
    );
  }
}

class FaqItem {
  final String q;
  final String a;
  FaqItem({required this.q, required this.a});
}

class _FaqTile extends StatefulWidget {
  final FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final cardRadius = 16.w;
    final borderColor = colorScheme.outlineVariant.withOpacity(0.3);

    return Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (v) => setState(() => _expanded = v),
          maintainState: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 18.h),


          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          trailing: _CapsulePlusMinus(isExpanded: _expanded),
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Text(
              widget.item.q,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.w,
                color: textTheme.titleMedium?.color,
              ),
            ),
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: borderColor),
              ),
              padding: EdgeInsets.all(12.w),
              child: Text(
                widget.item.a,
                textAlign: TextAlign.right,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 13.w,
                  height: 1.6,
                  color: textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapsulePlusMinus extends StatelessWidget {
  final bool isExpanded;
  const _CapsulePlusMinus({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final plusBg = colorScheme.surfaceVariant.withOpacity(0.4);
    final plusIcon = theme.iconTheme.color ?? colorScheme.onSurface;
    final minusBg = colorScheme.primary;
    final minusIcon = colorScheme.onPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: isExpanded ? minusBg : plusBg,
        borderRadius: BorderRadius.circular(8.w),
      ),
      alignment: Alignment.center,
      child: Icon(
        isExpanded ? Icons.remove_rounded : Icons.add_rounded,
        size: 20.w,
        color: isExpanded ? minusIcon : plusIcon,
      ),
    );
  }
}
