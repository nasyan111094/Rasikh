import 'dart:async';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/core/widgets/loading_widget.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/core/widgets/picture.dart';

import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/advertising_response_model.dart';

class AdsSlider extends StatefulWidget {
  const AdsSlider({super.key, required this.imageUrls});
  final List<Advertise> imageUrls;

  @override
  State<AdsSlider> createState() => _AdsSliderState();
}

class _AdsSliderState extends State<AdsSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < widget.imageUrls.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (mounted) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.imageUrls.isEmpty) {
      return NoDataWidget(
        title: "لا توجد إعلانات حاليا",

      );
    }

    return SizedBox(
      height: 250.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// ====== PageView ======
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Picture(
                    widget.imageUrls[index].image,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          /// ====== SmoothPageIndicator ======
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.primaryContainer, // من الثيم
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.imageUrls.length,
                effect: ExpandingDotsEffect(
                  dotWidth: 14.0,
                  dotHeight: 5.0,
                  expansionFactor: 2,
                  dotColor: colorScheme.outline.withOpacity(0.4),
                  activeDotColor: colorScheme.primary,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
