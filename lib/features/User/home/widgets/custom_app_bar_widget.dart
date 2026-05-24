import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/localization/loc_keys.dart';
import '../../../../config/navigation/nav.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/utils/get_asset_path.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/my_custom_icon.dart';
import '../../../../core/widgets/picture.dart';

class CustomAppBar<C extends StateStreamable<S>, S>
    extends StatelessWidget
    implements PreferredSizeWidget {
  final String? Function(S state) getFullName;
  final String? Function(S state) getAvatar;

  const CustomAppBar({
    super.key,
    required this.getFullName,
    required this.getAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bool isRtl = context.locale.languageCode != 'en';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: AppBar(
        elevation: 0,
        toolbarHeight: 80.h,

        /// Avatar
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(isRtl ? 0 : 3.14159),
            child: Container(
              height: 60.h,
              width: 60.w,
              padding: EdgeInsets.all(5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isRtl ? 50 : 0),
                  bottomLeft: Radius.circular(isRtl ? 50 : 0),
                  topRight: Radius.circular(isRtl ? 0 : 50),
                  bottomRight: Radius.circular(isRtl ? 0 : 50),
                ),
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withOpacity(0.3),
                    colors.surface,
                  ],
                  begin:
                  isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  end:
                  isRtl ? Alignment.centerLeft : Alignment.centerRight,
                ),
              ),
              child: BlocBuilder<C, S>(
                builder: (context, state) {
                  final avatarPath = getAvatar(state);

                  return ClipOval(
                    child: avatarPath != null && avatarPath.isNotEmpty
                        ? Image.network(
                      avatarPath.startsWith('http')
                          ? avatarPath
                          : 'http://89.117.60.202:3050$avatarPath',
                      fit: BoxFit.cover,
                      height: 70.h,
                      width: 70.h,
                      errorBuilder: (_, __, ___) => Image.asset(
                        getAssetImage('avatar.png'),
                        fit: BoxFit.cover,
                        height: 70.h,
                        width: 70.h,
                      ),
                    )
                        : Image.asset(
                      getAssetImage('avatar.png'),
                      fit: BoxFit.cover,
                      height: 70.h,
                      width: 70.h,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        /// Title
        title: Row(
          children: [
            BlocBuilder<C, S>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'هلا ومرحباً فيك! 👋',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(5.h),
                    Text(
                      getFullName(state) ?? '-',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),

            const Spacer(),

            /// Search
            MyCustomIconsWidget(
              backGround: Colors.transparent,
              height: 40.h,
              width: 40.w,
              onTap: () {
                if (getIt<CacheHelper>().currentToken == null) {
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
                } else {
                  // Nav.searchPage(context);
                }
              },
              childWidget: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Picture(
                  getAssetIcon('search.svg'),
                  width: 24.h,
                  height: 24.h,
                  color: colors.primary,
                ),
              ),
            ),

            Gap(10.w),

            /// Notification
            MyCustomIconsWidget(
              backGround: Colors.transparent,
              height: 40.h,
              width: 40.w,
              onTap: () {
                if (getIt<CacheHelper>().currentToken == null) {
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
                } else {
                  // Nav.notificationPage(context);
                }
              },
              childWidget: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Picture(
                      getAssetIcon('bell.svg'),
                      width: 24.h,
                      height: 24.h,
                      color: colors.primary,
                    ),
                  ),
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.surface,
                          width: 1.2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          '5',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onError,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}