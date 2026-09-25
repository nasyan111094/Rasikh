// ─────────────────────────────────────────────────────────────────────────────
// core/widgets/no_data_widget.dart
//
// One flexible, reusable empty/no-data state widget — no external assets,
// no Lottie. The icon gently floats and is surrounded by soft outward
// pulse rings, so it feels alive without needing any extra files.
//
// Usage:
//   if (items.isEmpty)
//     NoDataWidget(
//       icon: Icons.search_off_rounded,
//       title: 'لا توجد نتائج',
//       message: 'حاول تعديل كلمات البحث أو الفلاتر المستخدمة',
//       actionLabel: 'إعادة المحاولة',
//       onAction: _onRetry,
//     )
//
// Minimal usage (icon + title only):
//   const NoDataWidget(title: 'لا توجد استشارات حتى الآن')
// ─────────────────────────────────────────────────────────────────────────────
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../utils/get_asset_path.dart';
import 'gradiant_button.dart';

class NoDataWidget extends StatefulWidget {
  /// Icon shown inside the animated circle.
  final IconData icon;

  /// Main heading, e.g. "لا توجد نتائج".
  final String title;

  /// Optional supporting text under the title.
  final String? message;

  /// Optional CTA — only renders when BOTH actionLabel and onAction
  /// are provided.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Accent color for the icon, pulse rings, and gradient.
  /// Defaults to the current theme's primary color.
  final Color? color;

  /// Size of the icon glyph itself — the surrounding circle and pulse
  /// rings scale proportionally to this.
  final double iconSize;

  const NoDataWidget({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.color,
    this.iconSize = 40,
  });

  @override
  State<NoDataWidget> createState() => _NoDataWidgetState();
}

class _NoDataWidgetState extends State<NoDataWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();

    // One-shot pop-in (fade + scale) the moment this widget appears.
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    // Continuous gentle up/down float on the icon circle.
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Continuous outward pulse rings behind the icon (two rings,
    // offset in phase, for a smoother "radar" feel).
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    final entranceCurve = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutBack,
    );

    return Center(
      child: Padding(
        padding:  EdgeInsets.all(16.0.w),
        child: Container(

          decoration: BoxDecoration
            (
            borderRadius: BorderRadius.circular(10.h) ,
            border: Border.all(color:  widget.color!=null? color.withOpacity(.2) : primary.withOpacity(.2)) ,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w , vertical: 16.h),
            child: FadeTransition(
              opacity: _entrance,
              child: ScaleTransition(
                scale: Tween(begin: 0.85, end: 1.0).animate(entranceCurve),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildAnimatedIcon(color),
                          Gap(20.h),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                          [
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: widget.color ?? Colors.black,
                                fontSize: 16.sp,
                              ),
                            ),
                            if (widget.message != null) ...[
                              Gap(8.h),
                              Text(
                                widget.message!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontSize: 13.sp,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],) ,
                          if (widget.actionLabel != null && widget.onAction != null) ...[
                            Gap(24.h),
                            SizedBox(
                              width: double.infinity,
                              child: GradiantButton(
                                text: widget.actionLabel!,
                                onTap: widget.onAction!,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(Color color) {
    final circleSize = widget.iconSize * 0.9;

    return AnimatedBuilder(
      animation: Listenable.merge([_float, _pulse]),
      builder: (context, _) {
        final floatOffset =
            (Curves.easeInOut.transform(_float.value) - 0.5) * 2;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _pulseRing(color, circleSize, _pulse.value),
                _pulseRing(color, circleSize, (_pulse.value + 0.5) % 1),
                Container(
                  width: circleSize * 0.8,
                  height: circleSize * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.16),
                        color.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child:
                      Picture(getAssetIcon(widget.color!=null  ? "error.svg" :"empty.svg") , color: widget.color?? primary,) ,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// A single outward-fading ring. `t` is 0→1 progress; called twice with
  /// offset phases so two rings pulse in a staggered, continuous loop.
  Widget _pulseRing(Color color, double baseSize, double t) {
    final scale = 1 + t * 0.7;
    final opacity = (1 - t).clamp(0.0, 1.0) * 0.35;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: baseSize,
          height: baseSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.4),
          ),
        ),
      ),
    );
  }
}