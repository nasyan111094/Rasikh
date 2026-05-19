import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:size_config/size_config.dart';
import '../../../../config/theme/colors.dart';
import '../widgets/header_capsule_appbar_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        appBar: const HeaderCapsuleAppBar(
          title: 'الإشعارات',
          showBottomDivider: true,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _NotificationCard(
                title: 'تم استلام استشارتك بنجاح',
                body: 'سيقوم أحد المحامين بالرد عليك قريبًا.',
                time: '29 June 2024, 9.22 PM',
              ),
              SizedBox(height: 12),
              _NotificationCard(
                title: 'لديك عرض جديد من محامٍ',
                body: 'تفضل بمراجعته واختيار الأنسب لك.',
                time: '29 June 2024, 9.22 PM',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.title,
    required this.body,
    required this.time,
  });

  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double maxWidth = 398.w;
    final double cardWidth = screenWidth;
    final double constrainedWidth = cardWidth > maxWidth ? maxWidth : cardWidth;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constrainedWidth),
        child: Container(
          constraints: BoxConstraints(minHeight: 97.h),
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(
              color: greyEA,
              width: 1.w,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔔 أيقونة الإشعار
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/Bell_Bing.svg',
                  width: 22.w,
                  height: 22.w,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    cs.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 14.w),

              // 📝 النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      body,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        time,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(

                          fontWeight: FontWeight.w500,

                          height: 1.8,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
