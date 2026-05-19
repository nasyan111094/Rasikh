import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../config/navigation/nav.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/transparent_text_icon_button.dart';
import '../widgets/onboarding_navigation_buttons.dart';
import '../widgets/onboarding_pages.dart';

/// Main OnBoarding Screen with enhanced animations
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController pageController = PageController();
  int currentIndex = 0;
  double pageValue = 0.0;
  final Duration animationDuration = const Duration(milliseconds: 500);
  final Curve animationCurve = Curves.easeInOutCubic;

  late AnimationController _entryController;
  late Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();

    getIt<CacheHelper>().setOnBoardingDone(true) ;
    getIt<CacheHelper>().setOnBoardingDone(true);
    

    // Entry animation for the whole screen
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    _entryController.forward();

    // Listen to page scroll for parallax effects
    pageController.addListener(() {
      setState(() {
        pageValue = pageController.page ?? 0.0;
      });
    });

    // Set initial system UI style based on theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final theme = Theme.of(context);

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
          theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: theme.colorScheme.surface,
          systemNavigationBarIconBrightness:
          theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
      );
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSecondary,
      body: Stack(
        children: [
          Picture(getAssetImage("onboarding_bg.png") , width: double.infinity , height: double.infinity , fit: BoxFit.cover ,) ,
          Column(
            children: [
              Gap(150.h)  ,
              Expanded(
                child: AnimatedBuilder(
                  animation: _entryAnimation,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center ,
                      children: [
                        Gap(100.h)  ,

                        Expanded(
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - _entryAnimation.value)),
                            child: Opacity(
                              opacity: _entryAnimation.value,
                              child: OnBoardingPages(
                                pageController: pageController,
                                pageValue: pageValue,
                                onPageChanged: (index) => setState(() => currentIndex = index),
                              ),
                            ),
                          ),
                        ),
                        Gap(24.h),

                        // Smooth Page Indicator with scale animation

                        Gap(200.h)  ,


                      ],
                    );
                  },
                ),
              ),
              Gap(50.h)  ,
            ],
          ),
          // داخل StatefulWidget اللي فيه currentIndex و pageController
          Positioned(
            top: 70.h,
            left: 0,
            right: 0,
            child: Row(
              children: [
                // زر "تخطي"
              currentIndex < 2 ?   Container(
                  child: TransparentIconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact(); // haptic feedback
                      pageController.animateToPage(
                        2, // آخر صفحة
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                      );
                      setState(() {
                        currentIndex = 2;
                      });
                    },
                    text: "تخطي",
                    icon: Icons.arrow_back_ios,
                  ),
                ) : SizedBox.shrink(),
                Spacer(),
                // عداد الصفحة
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w20),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: (currentIndex + 1).toString(),
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        const TextSpan(
                          text: '/',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const TextSpan(
                          text: '3',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

// زر "التالي" و الـ Page Indicator
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Row(
              children: [
                // زر "التالي"
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w20),
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact(); // haptic feedback
                      if (currentIndex < 2) {
                        pageController.animateToPage(
                          currentIndex + 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                        setState(() {
                          currentIndex += 1;
                        });
                      } else {
                        // آخر صفحة -> ابدأ التطبيق
                        // Mark onboarding as completed before navigating
                        getIt<CacheHelper>().setOnBoardingDone(true);
                        Nav.account_type_screen(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      currentIndex == 2 ? 'ابدأ الآن' : 'التالي',
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                // Page Indicator
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w20),
                  child: Transform.scale(
                    scale: (_entryAnimation.value == 0 && currentIndex == 0)
                        ? 1.0
                        : 0.5 + (0.5 * _entryAnimation.value),
                    child: Opacity(
                      opacity: (_entryAnimation.value == 0 && currentIndex == 0)
                          ? 1.0
                          : _entryAnimation.value,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: SmoothPageIndicator(
                          controller: pageController,
                          count: 3,
                          effect: ExpandingDotsEffect(
                            dotHeight: 8.h,
                            dotWidth: 12.w,
                            activeDotColor: theme.colorScheme.primary, // من الثيم
                            dotColor: theme.colorScheme.onSurface.withOpacity(0.3), // من الثيم بدل disabledColor
                            expansionFactor: 4,
                            spacing: 8.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),

        ],
      ),
    );
  }
}