// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/presentation/widgets/lawyer_profile_avatar.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:size_config/size_config.dart';

/// Renders the lawyer avatar from [photoUrl] (network) or
/// falls back to the local asset. Shows a shimmer circle when [isLoading].
class LawyerProfileAvatar extends StatelessWidget {
  const LawyerProfileAvatar({
    super.key,
    this.photoUrl,
    this.radius = 26,
    this.isLoading = false,
    this.showEditBadge = false,
    this.onEditTap,
  });

  final String? photoUrl;
  final double radius;
  final bool isLoading;

  /// Displays a camera badge — used on the edit-profile screen.
  final bool showEditBadge;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _ShimmerCircle(radius: radius);
    }

    ImageProvider image;
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      // Check if URL is complete (starts with http/https)
      if (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://')) {
        image = NetworkImage(photoUrl!);
      } else {
        // Relative path - prepend baseImgUrl
        image = NetworkImage(AppConfig.baseImgUrl + photoUrl!);
      }
    } else {
      image = const AssetImage('assets/images/avatar.png');
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFF3EFE8),
      backgroundImage: image,
    );

    if (!showEditBadge) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: 30.h,
              height: 30.h,
              decoration: BoxDecoration(
                color: const Color(0xFFB29569),
                borderRadius: BorderRadius.circular(30.h),
                border: Border.all(color: Colors.white, width: 1.5.w),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 11.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double radius;
  const _ShimmerCircle({required this.radius});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).dividerColor.withOpacity(0.15);
    return CircleAvatar(
      radius: radius,
      backgroundColor: base,
    );
  }
}
