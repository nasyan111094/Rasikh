
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

class TermsBottomSheet extends StatelessWidget {
  const TermsBottomSheet({super.key});

  static String get _termsText => Loc.sampleTermsText();

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

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
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
                      Expanded(
                        child: Text(
                          Loc.termsAndConditions(),
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

                Divider(
                  color:     cs.outlineVariant.withOpacity(0.5),
                  height:    1,
                  thickness: 1,
                ),

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