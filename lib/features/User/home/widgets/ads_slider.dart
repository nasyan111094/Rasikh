import 'dart:async';
import 'package:rasikh/core/widgets/no_data_widget.dart';
import 'package:rasikh/core/widgets/picture.dart';

import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';

import '../models/advertising_response_model.dart';
import 'package:size_config/size_config.dart';

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
      if (mounted && _pageController.hasClients) {
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
    if (widget.imageUrls.isEmpty) {
      return NoDataWidget(
        title: Loc.noAdsCurrently(),

      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: SizedBox(
        height: 156.h,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: _BannerNotchClipper(
                  radius: 12.w,
                  notchHeight: 16.h,
                  notchTopHalfWidth: 48.w,
                  notchBottomHalfWidth: 68.w,
                ),
                child: ColoredBox(
                  color: const Color(0xFFF9F7F4),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Picture(
                        widget.imageUrls[index].image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 16.h,
              child: Center(
                child: _BannerPageIndicator(
                  count: widget.imageUrls.length,
                  currentIndex: _currentIndex,
                  onTap: (index) {
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
      ),
    );
  }
}

class _BannerPageIndicator extends StatelessWidget {
  const _BannerPageIndicator({
    required this.count,
    required this.currentIndex,
    required this.onTap,
  });

  final int count;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            width: isActive ? 26.w : 24.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: isActive ? primary : primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
        );
      }),
    );
  }
}

class _BannerNotchClipper extends CustomClipper<Path> {
  const _BannerNotchClipper({
    required this.radius,
    required this.notchHeight,
    required this.notchTopHalfWidth,
    required this.notchBottomHalfWidth,
  });

  final double radius;
  final double notchHeight;
  final double notchTopHalfWidth;
  final double notchBottomHalfWidth;

  @override
  Path getClip(Size size) {
    final card = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    final cx = size.width / 2;
    final bottom = size.height;
    final top = bottom - notchHeight;
    final slope = notchBottomHalfWidth - notchTopHalfWidth;
    final corner = notchHeight * 0.3;

    final notch = Path()
      ..moveTo(cx - notchBottomHalfWidth - corner, bottom)
      ..quadraticBezierTo(
        cx - notchBottomHalfWidth,
        bottom,
        cx - notchBottomHalfWidth + corner * slope / notchHeight,
        bottom - corner,
      )
      ..lineTo(cx - notchTopHalfWidth - corner * slope / notchHeight, top + corner)
      ..quadraticBezierTo(
        cx - notchTopHalfWidth,
        top,
        cx - notchTopHalfWidth + corner,
        top,
      )
      ..lineTo(cx + notchTopHalfWidth - corner, top)
      ..quadraticBezierTo(
        cx + notchTopHalfWidth,
        top,
        cx + notchTopHalfWidth + corner * slope / notchHeight,
        top + corner,
      )
      ..lineTo(
        cx + notchBottomHalfWidth - corner * slope / notchHeight,
        bottom - corner,
      )
      ..quadraticBezierTo(
        cx + notchBottomHalfWidth,
        bottom,
        cx + notchBottomHalfWidth + corner,
        bottom,
      )
      ..close();

    return Path.combine(PathOperation.difference, card, notch);
  }

  @override
  bool shouldReclip(covariant _BannerNotchClipper oldClipper) =>
      oldClipper.radius != radius ||
      oldClipper.notchHeight != notchHeight ||
      oldClipper.notchTopHalfWidth != notchTopHalfWidth ||
      oldClipper.notchBottomHalfWidth != notchBottomHalfWidth;
}
