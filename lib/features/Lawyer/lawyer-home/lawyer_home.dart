// features/Lawyer/lawyer-home/lawyer_home.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:size_config/size_config.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';

import '../../User/home/widgets/custom_app_bar_widget.dart';
import '../lawyer_Settings/bloc/Profile_cubit/lawyer_cubit.dart';
import '../lawyer_Settings/bloc/Profile_cubit/lawyer_state.dart';
import 'bloc/avaiabilty_cubit.dart';
import 'bloc/avaiabilty_state.dart';
import 'models/avaiability_status_model.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key});

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<LawyerProfileCubit>();
    if (cubit.cachedProfile == null) {
      cubit.getProfile();
    }
    else
      {
        setState(() {

        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LawyerAvailabilityCubit>(
      create: (_) => getIt<LawyerAvailabilityCubit>(),
      child: Scaffold(
        appBar: CustomAppBar<LawyerProfileCubit, LawyerProfileState>(
          getFullName: (state) {
            if (state is LawyerProfileLoaded) return state.profile.fullName;
            return null;
          },
          getAvatar: (state) {
            if (state is LawyerProfileLoaded) return state.profile.photoUrl;
            return null;
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              GeneralDivider(),
              _AvailabilityCard(),
              GeneralDivider(),
              Gap(20.h),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'استشارات جديدة', onViewAll: () {}),
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
                      _SectionHeader(title: 'أقرب 3 مواعيد اليوم', onViewAll: () {}),
                      Gap(10.h),
                      _AppointmentCard(title: 'استشارات كتابية', time: '٢:٣٠ م'),
                      Gap(10.h),
                      _AppointmentCard(title: 'استشارات كتابية', time: '٥:٣٠ م'),
                      Gap(24.h),
                      _SectionHeader(title: 'آخر حركة مالية', onViewAll: () {}),
                      Gap(10.h),
                      _TransactionCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Availability Card ─────────────────────────────────────────────────────────

class _AvailabilityCard extends StatefulWidget {
  const _AvailabilityCard();

  @override
  State<_AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<_AvailabilityCard> {
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    // ✅ If profile is already cached (e.g. after hot reload), use it immediately
    final cached = context.read<LawyerProfileCubit>().cachedProfile;
    if (cached != null) {
      _isAvailable = cached.activityStatus == 'available_now';
    }
    // Otherwise _isAvailable stays false and BlocListener below will update it
    // once LawyerProfileLoaded fires.
  }

  void _onToggle(bool val) {
    setState(() => _isAvailable = val);
    final status = val
        ? LawyerAvailabilityStatus.availableNow
        : LawyerAvailabilityStatus.unavailable;
    context.read<LawyerAvailabilityCubit>().updateAvailability(status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        // ✅ Listen to profile loading → sync toggle with real activityStatus
        BlocListener<LawyerProfileCubit, LawyerProfileState>(
          listener: (context, state) {
            if (state is LawyerProfileLoaded) {
              setState(() {
                _isAvailable = state.profile.activityStatus == 'available_now';
              });
            }
          },
        ),
        // Listen to availability update result
        BlocListener<LawyerAvailabilityCubit, LawyerAvailabilityState>(
          listener: (context, state) {
            if (state is UpdateAvailabilitySuccess) {
              setState(() {
                _isAvailable =
                    state.currentStatus == LawyerAvailabilityStatus.availableNow;
              });
            } else if (state is UpdateAvailabilityError) {
              // Roll back optimistic toggle
              setState(() => _isAvailable = !_isAvailable);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<LawyerAvailabilityCubit, LawyerAvailabilityState>(
        builder: (context, state) {
          final isLoading = state is UpdateAvailabilityLoading;

          return Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.h)),
            child: Row(
              children: [
                // ── Status dot ────────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isAvailable ? Colors.green : Colors.red,
                  ),
                ),
                Gap(12.w),
                // ── Labels ────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('حالة التوفر', style: theme.textTheme.titleMedium),
                      Text(
                        'هل أنت متاح الآن للإستشارات الفورية',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                // ── Toggle + label ────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: isLoading
                          ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                          : Text(
                        _isAvailable ? 'متاح' : 'غير متاح',
                        key: ValueKey(_isAvailable),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                      child: Switch(
                        value: _isAvailable,
                        onChanged: isLoading ? null : _onToggle,
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
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unchanged widgets below
// ─────────────────────────────────────────────────────────────────────────────

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
              border: Border.all(color: theme.colorScheme.outline, width: 1),
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
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
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
            child: Picture(getAssetIcon('wallet.svg'), width: 20.w, height: 20.w),
          ),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تم إضافة لمحفظتك', style: theme.textTheme.titleMedium),
                Text(
                  '1200 ريال',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: primary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Picture(getAssetIcon('Calendar.svg'), width: 20.h, height: 20.h),
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