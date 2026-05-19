// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/home/screens/lawyer_home_screen.dart
//
// Integrates LawyerProfileCubit to show real name + avatar in the AppBar.
// All existing UI widgets are unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:size_config/size_config.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';

import '../../../Shared/widgets/lawyer_profile_avatar.dart';
import '../../User/home/widgets/custom_app_bar_widget.dart';

import '../lawyer_Settings/bloc/lawyer_cubit.dart';
import '../lawyer_Settings/bloc/lawyer_state.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key});

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile once when home screen appears
    final cubit = context.read<LawyerProfileCubit>();
    if (cubit.cachedProfile == null) {
      cubit.getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // ── Custom AppBar with live name + avatar ────────────────────────────
      appBar: _LawyerHomeAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            GeneralDivider(),
            _AvailabilityCard(),
            GeneralDivider(),
            Gap(20.h),
            Expanded(
              child: SingleChildScrollView(
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                        title: 'استشارات جديدة', onViewAll: () {}),
                    Gap(10.h),
                    _ConsultationCard(
                      title: 'استشارات فورية',
                      time: '٢:٣٠ م',
                      onAccept: () {},
                      onDetails: () {},
                    ),
                    Gap(10.h),
                    _ConsultationCard(
                      title: 'استشارات كتابية',
                      time: '٣:٠٠ م',
                      onAccept: () {},
                      onDetails: () {},
                    ),
                    Gap(24.h),
                    _SectionHeader(
                        title: 'أقرب 3 مواعيد اليوم', onViewAll: () {}),
                    Gap(10.h),
                    _AppointmentCard(
                        title: 'استشارات كتابية', time: '٢:٣٠ م'),
                    Gap(10.h),
                    _AppointmentCard(
                        title: 'استشارات كتابية', time: '٥:٣٠ م'),
                    Gap(24.h),
                    _SectionHeader(
                        title: 'آخر حركة مالية', onViewAll: () {}),
                    Gap(10.h),
                    _TransactionCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AppBar with live profile data ─────────────────────────────────────────────

class _LawyerHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor:
      theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16.w,
      title: BlocBuilder<LawyerProfileCubit, LawyerProfileState>(
        buildWhen: (p, c) =>
        c is LawyerProfileLoaded ||
            c is UpdateProfileSuccess ||
            c is LawyerProfileLoading,
        builder: (context, state) {
          final cubit = context.read<LawyerProfileCubit>();
          final profile = cubit.cachedProfile;
          final isLoading = state is LawyerProfileLoading;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                // Avatar
                LawyerProfileAvatar(
                  photoUrl: profile?.photoUrl,
                  radius: 18.h,
                  isLoading: isLoading,
                ),
                Gap(10.w),
                // Name + greeting
                Expanded(
                  child: isLoading
                      ? _ShimmerBox(width: 100.w, height: 14.h)
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'مرحباً،',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                      Text(
                        profile?.fullName ?? '---',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification bell (kept from original CustomAppBar logic)
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 22.sp,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.h),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The widgets below are IDENTICAL to the original — no UI changes.
// ─────────────────────────────────────────────────────────────────────────────

class _AvailabilityCard extends StatefulWidget {
  const _AvailabilityCard();

  @override
  State<_AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<_AvailabilityCard> {
  bool isAvailable = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.h)),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAvailable ? Colors.green : Colors.red,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حالة التوفر', style: theme.textTheme.titleMedium),
                Text(
                  'هل أنت متاح الآن للإستشارات الفورية',
                  style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  isAvailable ? 'متاح' : 'غير متاح',
                  key: ValueKey(isAvailable),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
                child: Switch(
                  value: isAvailable,
                  onChanged: (val) => setState(() => isAvailable = val),
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Picture(getAssetIcon('dot.svg')),
        Gap(5.w),
        Text(title, style: theme.textTheme.titleMedium),
        const Spacer(),
        InkWell(
          onTap: onViewAll,
          child: Text('عرض الكل',
              style: theme.textTheme.bodySmall?.copyWith(color: primary)),
        ),
      ],
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final String title;
  final String time;
  final VoidCallback onAccept;
  final VoidCallback onDetails;

  const _ConsultationCard({
    required this.title,
    required this.time,
    required this.onAccept,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.h),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: theme.colorScheme.outline, width: 1),
            ),
            child: Center(
              child: Picture(
                getAssetIcon('chat.svg'),
                width: 25.w,
                height: 25.w,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Gap(10.w),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      Gap(6.h),
                      Text(time,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
                Gap(10.h),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.h)),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                          ),
                          child: Text('قبول',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(color: Colors.white)),
                        ),
                      ),
                      Gap(10.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDetails,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.h)),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                          ),
                          child: Text('التفاصيل',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(color: primary)),
                        ),
                      ),
                    ],
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

class _AppointmentCard extends StatelessWidget {
  final String title;
  final String time;
  const _AppointmentCard({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.h),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          Picture(getAssetIcon('clock.svg'), width: 20.w, height: 20.w),
          Gap(6.w),
          Text(time,
              style:
              theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.h),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              border: Border.all(color: greyFA),
              shape: BoxShape.circle,
            ),
            child: Picture(getAssetIcon('wallet.svg'),
                width: 20.w, height: 20.w),
          ),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تم إضافة لمحفظتك',
                    style: theme.textTheme.titleMedium),
                Text(
                  '1200 ريال',
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: primary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Picture(getAssetIcon('Calendar.svg'),
                  width: 20.h, height: 20.h),
              Gap(5.w),
              Text(
                '16 / 10 / 2025',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.hintColor,
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}