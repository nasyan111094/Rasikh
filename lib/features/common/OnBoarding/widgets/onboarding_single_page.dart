import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

/// Individual OnBoarding Page with floating image and staggered animations
class OnBoardingPage extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final int pageIndex;

  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    this.pageIndex = 0,
  });

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Floating animation for the image
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000 + (widget.pageIndex * 200)),
    );

    _floatAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Image with float + fade + slide + scale + rotate
        Expanded(
          flex: 3,
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Image.asset(
              widget.image,
              fit: BoxFit.contain,
            )
                .animate(
              key: ValueKey('${widget.image}_${DateTime.now()}'),
            )
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideX(begin: 0.3, end: 0, duration: 700.ms, curve: Curves.easeOutCubic)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 700.ms, curve: Curves.easeOutBack)
                .rotate(begin: 0.02, end: 0, duration: 700.ms, curve: Curves.easeOutCubic),
          ),
        ),

        SizedBox(height: 20.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              // Title with fade + slideY + scale + shimmer
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 22.sp,
                  letterSpacing: 0.5,
                ),
              )
                  .animate(
                key: ValueKey('${widget.title}_${DateTime.now()}'),
              )
                  .fadeIn(duration: 500.ms, delay: 300.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 600.ms, delay: 300.ms, curve: Curves.easeOutBack)
                  .shimmer(duration: 1500.ms, delay: 800.ms, color: theme.colorScheme.primary.withOpacity(0.3)),

              Gap(16.h),

              // Description with left → right slide + fade + scale
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: black,
                    fontSize: 16.sp,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                )
                    .animate(
                  key: ValueKey('${widget.description}_${DateTime.now()}'),
                )
                    .fadeIn(duration: 500.ms, delay: 600.ms, curve: Curves.easeOut)
                    .slideX(begin: -0.3, end: 0, duration: 600.ms, delay: 600.ms, curve: Curves.easeOutCubic)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 600.ms, delay: 1000.ms, curve: Curves.easeOutCubic),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }
}
