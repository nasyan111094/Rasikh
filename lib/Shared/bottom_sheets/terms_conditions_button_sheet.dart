// ─────────────────────────────────────────────────────────────────────────────
// shared/auth/pages/terms_bottom_sheet.dart
//
// Modal bottom sheet for "الشروط والأحكام".
// UI matches Terms_and_Conditions.png 100%.
//
// Design notes:
//  • White/surface background, full-height draggable sheet
//  • Header row: [X circle button] ... [الشروط والأحكام title]
//  • Thin divider below header
//  • Scrollable body with right-aligned Arabic body text
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

class TermsBottomSheet extends StatelessWidget {
  const TermsBottomSheet({super.key});

  // Placeholder Arabic terms text — replace with real content.
  static const String _termsText = '''هذا النص هو مثال لنص يمكن أن يستبدل في نفس المساحة، لقد تم توليد هذا النص من مولد النص العربي، حيث يمكنك أن تولد مثل هذا النص أو العديد من النصوص الأخرى إضافة إلى زيادة عدد الحروف التى يولدها التطبيق.

إذا كنت تحتاج إلى عدد أكبر من الفقرات يتيح لك مولد النص العربي زيادة عدد الفقرات كما تريد، النص لن يبدو مقسما ولا يحوي أخطاء لغوية، مولد النص العربي مفيد لمصممي المواقع على وجه الخصوص، حيث يحتاج العميل في كثير من الأحيان أن يطلع على صورة حقيقية لتصميم الموقع.

ومن هنا وجب على المصمم أن يضع نصوصا مؤقتة على التصميم ليظهر للعميل الشكل الكامل، دور مولد النص العربي أن يوفر على المصمم عناء البحث عن نص بديل لا علاقة له بالموضوع الذى يتحدث عنه التصميم فيظهر التصميم بشكل لا يليق.

هذا النص يمكن أن يتم تركيبه على أي تصميم دون مشكلة فلن يبدو وكأنه نص منسوخ، غير منظم، غير منسق، أو حتى غير مفهوم. لأنه مازال نصاً بديلاً ومؤقتاً.

هذا النص يمكن أن يتم تركيبه على أي تصميم دون مشكلة فلن يبدو وكأنه نص منسوخ، غير منظم، غير منسق، أو حتى غير مفهوم. لأنه مازال نصاً بديلاً ومؤقتاً.''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize:     0.5,
        maxChildSize:     0.95,
        expand:           false,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color:        cs.onPrimary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // ── Drag handle ──────────────────────────────────────
                Gap(10.h),
                Center(
                  child: Container(
                    width:  40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color:        cs.outlineVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Gap(14.h),

                // ── Header row ───────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      // X button (left side in RTL = displayed left)
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width:  38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.surfaceContainerHighest
                                .withOpacity(0.6),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size:  20.sp,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Gap(10.w) ,
                      // Title (right-aligned in RTL fills the space)
                      Expanded(
                        child: Text(
                          'الشروط والأحكام',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:      cs.onSurface,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

                Gap(12.h),

                // ── Divider ──────────────────────────────────────────
                Divider(
                  color:     cs.outlineVariant.withOpacity(0.5),
                  height:    1,
                  thickness: 1,
                ),

                // ── Scrollable body ──────────────────────────────────
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                    children: [
                      Text(
                        _termsText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:  cs.onSurface,
                          height: 1.85,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}