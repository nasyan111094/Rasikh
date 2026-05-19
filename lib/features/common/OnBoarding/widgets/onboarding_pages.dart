import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/localization/loc_keys.dart';
import 'onboarding_single_page.dart';

/// Widget to display OnBoarding Pages with parallax effects
class OnBoardingPages extends StatelessWidget {
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final double pageValue;

  const OnBoardingPages({
    super.key,
    required this.pageController,
    required this.onPageChanged,
    this.pageValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.8.h,
      child: PageView.builder(
        controller: pageController,
        allowImplicitScrolling: true,
        padEnds: true,
        pageSnapping: true,
        physics: const BouncingScrollPhysics(),
        onPageChanged: onPageChanged,
        itemCount: 3,
        itemBuilder: (context, index) {
          // Calculate parallax offset for current page
          final double pageOffset = pageValue - index;
          final double parallaxOffset = pageOffset * 50;
          final double opacity = (1 - pageOffset.abs()).clamp(0.0, 1.0);
          final double scale = (1 - (pageOffset.abs() * 0.1)).clamp(0.8, 1.0);

          return Transform.translate(
            offset: Offset(parallaxOffset, 0),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: _buildPage(index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    final List<Map<String, String>> pages = [
      {
        'image': 'assets/images/onboarding1.png',
        'title': "حماية خصوصيتك أولويتنا",
        'description': "استمتع بخدمة قانونية عالية الجودة، مع التزام تام بالحفاظ على سرية معلوماتك وحماية حقوقك.",
      },
      {
        'image': 'assets/images/onboarding2.png',
        'title': "استشارات قانونية في أي وقت",
        'description': "تواصل مع محامٍ محترف بسهولة واطمئنان، مع ضمان سرية جميع بياناتك ومحادثاتك القانونية.",
      },
      {
        'image': 'assets/images/onboarding3.png',
        'title': "دفع آمن، راحة بال كاملة",
        'description': "أجرِ معاملاتك المالية بكل أمان وراحة بال، مع حماية كاملة لبياناتك وخصوصيتك.",
      },
    ];

    return OnBoardingPage(
      image: pages[index]['image']!,
      title: pages[index]['title']!,
      description: pages[index]['description']!,
      pageIndex: index,
    );
  }
}