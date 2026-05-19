import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/localization/loc_keys.dart';
import '../../../../config/navigation/nav.dart';
import '../../../../core/widgets/elevated_button.dart';
import '../../../../core/widgets/gradiant_button.dart';

/// Widget for OnBoarding Navigation Buttons with smooth morphing animations
class OnBoardingNavigationButtons extends StatefulWidget {
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const OnBoardingNavigationButtons({
    super.key,
    required this.pageController,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<OnBoardingNavigationButtons> createState() =>
      _OnBoardingNavigationButtonsState();
}

class _OnBoardingNavigationButtonsState
    extends State<OnBoardingNavigationButtons> with SingleTickerProviderStateMixin {
  final Duration animationDuration = const Duration(milliseconds: 400);
  final Curve animationCurve = Curves.easeInOutCubic;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the main button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleNavigation(VoidCallback navigation) {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    // Add haptic feedback
    HapticFeedback.lightImpact();

    navigation();

    Future.delayed(animationDuration, () {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = widget.currentIndex == 2;

    return SizedBox(
      height: 100.h,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skip button with slide and fade animation
            AnimatedContainer(
              duration: animationDuration,
              curve: animationCurve,
              width: isLastPage ? 0 : MediaQuery.of(context).size.width / 2.1,
              child: AnimatedOpacity(
                duration: animationDuration,
                opacity: isLastPage ? 0.0 : 1.0,
                child: AnimatedScale(
                  duration: animationDuration,
                  scale: isLastPage ? 0.8 : 1.0,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: 16.w),
                    child: !isLastPage
                        ? CustomElevatedButton(
                      onTap: () => _handleNavigation(() {
                        widget.onIndexChanged(2);
                        widget.pageController.animateToPage(
                          2,
                          duration: animationDuration,
                          curve: animationCurve,
                        );
                      }),
                      buttonName: Loc.skip(),
                      buttonColor: theme.colorScheme.secondary,
                      buttonTextStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                      ),
                    )
                        .animate(key: ValueKey('skip_${widget.currentIndex}'))
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic)
                        : const SizedBox(),
                  ),
                ),
              ),
            ),

            // Animated "Next" / "Start" Button with morphing effect
            Expanded(
              child: AnimatedContainer(
                duration: animationDuration,
                curve: animationCurve,
                margin: EdgeInsets.only(
                  left: isLastPage ? 0 : 0,
                ),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isLastPage ? _pulseAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: GradiantButton(
                    key: ValueKey('main_button_${widget.currentIndex}'),
                    text: isLastPage ? Loc.start_now() : Loc.next(),
                    onTap: () => _handleNavigation(() {
                      if (widget.currentIndex < 2) {
                        widget.onIndexChanged(widget.currentIndex + 1);
                        widget.pageController.animateToPage(
                          widget.currentIndex + 1,
                          duration: animationDuration,
                          curve: animationCurve,
                        );
                      } else {
                        _pulseController.stop();
                        Nav.login(context);
                      }
                    }),
                  )
                      .animate(key: ValueKey('gradient_${widget.currentIndex}'))
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideX(
                    begin: 0.2,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                      .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}