// features/Lawyer/lawyer-home/lawyer_home.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/config/theme/colors.dart';

import 'package:size_config/size_config.dart';
import '../../../config/navigation/nav.dart';
import '../../User/home/widgets/custom_app_bar_widget.dart';
import '../lawyer_Settings/bloc/Profile_cubit/lawyer_cubit.dart';
import '../lawyer_Settings/bloc/Profile_cubit/lawyer_state.dart';
import 'bloc/avaiabilty_cubit.dart';
import 'bloc/avaiabilty_state.dart';
import 'bloc/lawyer_consultations_cubit.dart';
import 'bloc/lawyer_consultations_state.dart';
import 'models/avaiability_status_model.dart';
import 'models/consultation_model.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key});

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  @override
  void initState() {
    super.initState();
    final profileCubit = context.read<LawyerProfileCubit>();
    if (profileCubit.cachedProfile == null) {
      profileCubit.getProfile();
    }
    // Fetch consultations once profile is available, or directly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LawyerConsultationsCubit>().fetchConsultations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: BlocListener<LawyerConsultationsCubit, LawyerConsultationsState>(
          listener: (context, state) {
            // Handle accept consultation success
            if (state is AcceptConsultationSuccess) {
              final accepted = state.acceptedConsultation;
              
              // Get lawyer profile for video call screen
              final profileState = context.read<LawyerProfileCubit>().state;
              String? lawyerName;
              String? lawyerPhoto;
              if (profileState is LawyerProfileLoaded) {
                lawyerName = profileState.profile.fullName;
                lawyerPhoto = profileState.profile.photoUrl;
              }
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم قبول الاستشارة بنجاح'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              
              // Navigate to video call screen
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Nav.videoCallScreen(
                    context,
                    consultationId: context.read<LawyerConsultationsCubit>().acceptedConsultationId!,
                    lawyerName: accepted.client.fullName,
                    lawyerPhotoUrl: AppConfig.baseImgUrl+(accepted.client.avatar),
                  );
                }
              });
            } 
            // Handle accept consultation error
            else if (state is AcceptConsultationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل قبول الاستشارة: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: Column(
            children: [
              const GeneralDivider(),
              const _AvailabilityCard(),
              const GeneralDivider(),
              Gap(20.h),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        title: 'استشارات جديدة',
                        onViewAll: null, // optional, can add pagination screen
                      ),
                      Gap(10.h),
                      BlocBuilder<LawyerConsultationsCubit, LawyerConsultationsState>(
                        builder: (context, state) {
                          if (state is LawyerConsultationsLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is LawyerConsultationsError) {
                            return Center(
                              child: Text(
                                'حدث خطأ: ${state.message}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (state is LawyerConsultationsLoaded) {
                            if (state.consultations.isEmpty) {
                              return const Center(
                                child: Text('لا توجد استشارات جديدة حالياً'),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.consultations.length,
                              separatorBuilder: (_, __) => Gap(10.h),
                              itemBuilder: (context, index) {
                                final consultation = state.consultations[index];
                                return _ConsultationCard(
                                  consultation: consultation,
                                  onAccept: () => _onAccept(context, consultation),
                                  onDetails: () => _showDetails(consultation),
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      Gap(24.h),
                      const _SectionHeader(
                        title: 'أقرب 3 مواعيد اليوم',
                        onViewAll: null,
                      ),
                      Gap(10.h),
                      // TODO: replace with real appointments data when API ready
                      const _AppointmentCard(title: 'استشارات كتابية', time: '٢:٣٠ م'),
                      Gap(10.h),
                      const _AppointmentCard(title: 'استشارات كتابية', time: '٥:٣٠ م'),
                      Gap(24.h),
                      const _SectionHeader(title: 'آخر حركة مالية', onViewAll: null),
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

  void _onAccept(BuildContext context, Consultation consultation) async {



    final cubit = context.read<LawyerConsultationsCubit>();
    // Call the cubit method - BlocListener will handle success/error feedback and navigation
    await cubit.acceptConsultation(consultation);
  }

  void _showDetails(Consultation consultation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(consultation.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('التفاصيل: ${consultation.details}'),
              Gap(8.h),
              Text('العميل: ${consultation.client.fullName}'),
              Text('الهاتف: ${consultation.client.phone}'),
              Text('المدينة: ${consultation.client.city}'),
              Gap(8.h),
              Text('المدة: ${consultation.durationMin} دقيقة'),
              Text('السعر: ${consultation.priceAmountHalala / 100} ر.س'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

// ── Availability Card (unchanged logic, but kept as is) ──────────────────

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
    final cached = context.read<LawyerProfileCubit>().cachedProfile;
    if (cached != null) {
      _isAvailable = cached.activityStatus == 'available_now';
    }
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
        BlocListener<LawyerProfileCubit, LawyerProfileState>(
          listener: (context, state) {
            if (state is LawyerProfileLoaded) {
              setState(() {
                _isAvailable = state.profile.activityStatus == 'available_now';
              });
            }
          },
        ),
        BlocListener<LawyerAvailabilityCubit, LawyerAvailabilityState>(
          listener: (context, state) {
            if (state is UpdateAvailabilitySuccess) {
              setState(() {
                _isAvailable = state.currentStatus == LawyerAvailabilityStatus.availableNow;
              });
            } else if (state is UpdateAvailabilityError) {
              setState(() => _isAvailable = !_isAvailable);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('حالة التوفر', style: theme.textTheme.titleMedium),
                      Text(
                        'هل أنت متاح الآن للإستشارات الفورية',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
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

// ── Consultation Card (updated to use real data) ─────────────────────────

class _ConsultationCard extends StatelessWidget {
  final Consultation consultation;
  final VoidCallback onAccept;
  final VoidCallback onDetails;

  const _ConsultationCard({
    required this.consultation,
    required this.onAccept,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeText = consultation.type == 'instant' ? 'استشارات فورية' : 'استشارات كتابية';
    final formattedTime = _formatTime(consultation.createdAt);

    return BlocBuilder<LawyerConsultationsCubit, LawyerConsultationsState>(
      builder: (context, state) {
        final isAccepting = state is AcceptConsultationLoading && state.consultationId == consultation.id;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(typeText, style: theme.textTheme.titleMedium),
                    Gap(4.h),
                    Text(
                      consultation.title,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(4.h),
                    Text(
                      formattedTime,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              Gap(10.w),
              Row(
                children: [
                  if (isAccepting)
                    SizedBox(
                      width: 80.w,
                      height: 40.h,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.h)),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text('قبول', style: theme.textTheme.titleSmall?.copyWith(color: Colors.white)),
                    ),
                    Gap(10.w),
                    OutlinedButton(
                      onPressed: onDetails,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.h)),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text('التفاصيل', style: theme.textTheme.titleSmall?.copyWith(color: primary)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// ── Section Header (unchanged) ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.onViewAll});

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
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            child: Text('عرض الكل',
                style: theme.textTheme.bodySmall?.copyWith(color: primary)),
          ),
      ],
    );
  }
}

// ── Appointment & Transaction Cards (unchanged) ───────────────────────────

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