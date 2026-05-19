import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import 'consultation_type_screen(2).dart';

class ConnectingToLawyerScreen extends StatefulWidget {
  const ConnectingToLawyerScreen({super.key});

  @override
  State<ConnectingToLawyerScreen> createState() =>
      _ConnectingToLawyerScreenState();
}

class _ConnectingToLawyerScreenState extends State<ConnectingToLawyerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {

      if(selectedTypeIndex == 0)
      Nav.videoCallScreen(context);
      else
       Nav.chat(context);
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Dots Indicator
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final progress = (_controller.value * 3).floor() % 3;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = index == progress;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          width: isActive ? 10.w : 8.w,
                          height: isActive ? 10.w : 8.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        );
                      }),
                    );
                  },
                ),

                Gap(30.h),

                // Title
                Text(
                  "جاري ربطك بالمحامي",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                Gap(10.h),

                // Subtitle
                Text(
                  "يرجى الانتظار لحظات حتى نكمل عملية الربط مع المحامي المناسب.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
