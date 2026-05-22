// ─────────────────────────────────────────────────────────────────────────────
// features/consultations/presentation/widgets/consultation_shimmer.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';

// ── Shimmer box helper ────────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Single card shimmer ───────────────────────────────────────────────────────

class ConsultationCardShimmer extends StatelessWidget {
  const ConsultationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor =
        isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.w),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ShimmerBox(width: 60.w, height: 24.h, radius: 50),
                  _ShimmerBox(width: 120.w, height: 16.h),
                ],
              ),
              SizedBox(height: 16.h),

              // Divider
              _ShimmerBox(width: double.infinity, height: 1.h, radius: 0),
              SizedBox(height: 16.h),

              // Lawyer info row
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ShimmerBox(width: 130.w, height: 14.h),
                      SizedBox(height: 6.h),
                      _ShimmerBox(width: 90.w, height: 12.h),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  _ShimmerBox(width: 44.w, height: 44.h, radius: 50),
                ],
              ),
              SizedBox(height: 16.h),

              // Divider
              _ShimmerBox(width: double.infinity, height: 1.h, radius: 0),
              SizedBox(height: 16.h),

              // Time & price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      _ShimmerBox(width: 70.w, height: 12.h),
                      SizedBox(height: 6.h),
                      _ShimmerBox(width: 90.w, height: 14.h),
                    ],
                  ),
                  _ShimmerBox(width: 2.w, height: 30.h, radius: 50),
                  Column(
                    children: [
                      _ShimmerBox(width: 70.w, height: 12.h),
                      SizedBox(height: 6.h),
                      _ShimmerBox(width: 80.w, height: 14.h),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Button
              _ShimmerBox(
                  width: double.infinity, height: 44.h, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ── List shimmer (multiple cards) ─────────────────────────────────────────────

class ConsultationsListShimmer extends StatelessWidget {
  final int itemCount;

  const ConsultationsListShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ConsultationCardShimmer(),
    );
  }
}

// ── Details screen shimmer ────────────────────────────────────────────────────

class ConsultationDetailsShimmer extends StatelessWidget {
  const ConsultationDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor =
        isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Title
            _ShimmerBox(width: 140.w, height: 18.h),
            SizedBox(height: 20.h),

            // Specialization label
            _ShimmerBox(width: 80.w, height: 14.h),
            SizedBox(height: 8.h),
            _ShimmerBox(width: 120.w, height: 14.h),
            SizedBox(height: 20.h),

            // Description label
            _ShimmerBox(width: 110.w, height: 14.h),
            SizedBox(height: 8.h),
            _ShimmerBox(width: double.infinity, height: 14.h),
            SizedBox(height: 6.h),
            _ShimmerBox(width: 200.w, height: 14.h),
            SizedBox(height: 20.h),

            // Divider
            _ShimmerBox(width: double.infinity, height: 1.h, radius: 0),
            SizedBox(height: 20.h),

            // Time & price section
            _ShimmerBox(width: 100.w, height: 14.h),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  _ShimmerBox(width: 70.w, height: 12.h),
                  SizedBox(height: 6.h),
                  _ShimmerBox(width: 90.w, height: 14.h),
                ]),
                _ShimmerBox(width: 2.w, height: 30.h, radius: 50),
                Column(children: [
                  _ShimmerBox(width: 70.w, height: 12.h),
                  SizedBox(height: 6.h),
                  _ShimmerBox(width: 80.w, height: 14.h),
                ]),
              ],
            ),
            SizedBox(height: 20.h),

            // Divider
            _ShimmerBox(width: double.infinity, height: 1.h, radius: 0),
            SizedBox(height: 20.h),

            // Voice note label
            _ShimmerBox(width: 90.w, height: 14.h),
            SizedBox(height: 12.h),
            _ShimmerBox(width: double.infinity, height: 60.h, radius: 12),
            SizedBox(height: 20.h),

            // Attachments label
            _ShimmerBox(width: 80.w, height: 14.h),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(
                5,
                (i) => Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: _ShimmerBox(width: 60.w, height: 60.h, radius: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
