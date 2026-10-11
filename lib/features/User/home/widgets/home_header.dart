import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/features/common/notifications/notifications_screen.dart';

import '../../../../config/navigation/nav.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/get_asset_path.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/picture.dart';
import '../../../common/notifications/bloc/notification_badge_cubit.dart';
import '../../profile/cubit/profile_cubit.dart';
import 'package:size_config/size_config.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  static double get _contentHeight => 83.h;

  @override
  Size get preferredSize => Size.fromHeight(_contentHeight + 1);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _contentHeight,
            child: Row(
              children: [
                const _HomeAvatar(),
                Gap(10.w),
                const Expanded(child: _HomeGreeting()),
                Gap(8.w),
                const _HomeNotificationButton(),
                Gap(14.w),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: greyF8),
        ],
      ),
    );
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 70.w,
      height: 62.h,
      padding: EdgeInsetsDirectional.only(end: 6.w),
      alignment: AlignmentDirectional.centerEnd,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.horizontal(
          end: Radius.circular(31.h),
        ),
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerEnd,
          end: AlignmentDirectional.centerStart,
          colors: [
            colors.primary.withOpacity(0.25),
            colors.primary.withOpacity(0.08),
          ],
        ),
      ),
      child: Container(
        width: 51.w,
        height: 51.w,
        padding: EdgeInsets.all(1.5.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: colors.primary, width: 1.2.w),
        ),
        child: ClipOval(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (previous, current) =>
                previous.data?.avatar != current.data?.avatar,
            builder: (context, state) {
              final avatarPath = state.data?.avatar;
              final placeholder = Image.asset(
                getAssetImage('avatar.png'),
                fit: BoxFit.cover,
              );

              if (avatarPath == null || avatarPath.isEmpty) return placeholder;

              return Image.network(
                avatarPath.startsWith('http')
                    ? avatarPath
                    : '${AppConfig.baseImgUrl}$avatarPath',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => placeholder,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeGreeting extends StatelessWidget {
  const _HomeGreeting();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) =>
          previous.data?.fullName != current.data?.fullName,
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Loc.homeGreeting(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF616161),
              ),
            ),
            Gap(4.h),
            Text(
              state.data?.fullName ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeNotificationButton extends StatelessWidget {
  const _HomeNotificationButton();

  bool get _isGuest => getIt<CacheHelper>().currentToken == null;

  void _onTap(BuildContext context, BuildContext badgeContext) {
    if (_isGuest) {
      Nav.soonDialog(
        context,
        Center(
          child: Container(
            color: Colors.transparent,
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width / 1.2,
            child: const CustomDialog(),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    ).then((_) {
      if (badgeContext.mounted) {
        badgeContext.read<NotificationBadgeCubit>().fetchUnreadCount();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final size = 33.w;

    return BlocProvider(
      create: (_) {
        final cubit = getIt<NotificationBadgeCubit>();
        if (!_isGuest) cubit.fetchUnreadCount();
        return cubit;
      },
      child: Builder(
        builder: (badgeContext) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onTap(context, badgeContext),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: colors.primary.withOpacity(0.12),
                      ),
                    ),
                    child: Picture(
                      getAssetIcon('Bell_Bing.svg'),
                      width: 20.w,
                      height: 20.w,
                      color: colors.primary,
                    ),
                  ),
                  BlocBuilder<NotificationBadgeCubit, NotificationBadgeState>(
                    builder: (context, state) {
                      int? count;
                      if (state is NotificationBadgeLoaded) {
                        count = state.count;
                      } else if (state is NotificationBadgeLoading) {
                        count = state.previousCount;
                      }
                      if (count == null || count <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        top: -1.w,
                        right: -1.w,
                        child: Container(
                          height: 11.w,
                          constraints: BoxConstraints(minWidth: 11.w),
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(6.w),
                          ),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onError,
                              fontWeight: FontWeight.w700,
                              fontSize: 7.sp,
                              height: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
