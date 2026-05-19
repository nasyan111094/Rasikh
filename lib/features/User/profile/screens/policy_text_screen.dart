import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

import '../widgets/header_capsule_appbar_widget.dart';

class PolicySection {
  final String title;
  final String body;
  const PolicySection({required this.title, required this.body});
}

class PolicyTextScreen extends StatelessWidget {
  const PolicyTextScreen({
    super.key,
    required this.pageTitle,
    required this.sections,
  });

  final String pageTitle;
  final List<PolicySection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: HeaderCapsuleAppBar(title: pageTitle),
        body: ListView.separated(
          padding: EdgeInsets.only(
            top: 20.h,
            right: 16.w,
            left: 16.w,
            bottom: 12.h,
          ),
          itemCount: sections.length,
          separatorBuilder: (_, __) => Divider(
            color: cs.surfaceVariant.withOpacity(0.15),
            height: 28.h,
          ),
          itemBuilder: (context, i) {
            final s = sections[i];
            return Padding(
              padding: EdgeInsets.only(
                top: 5.h,
                right: 5.w,
                left: 16.w,
                bottom: 12.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    s.body,

                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.6,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
