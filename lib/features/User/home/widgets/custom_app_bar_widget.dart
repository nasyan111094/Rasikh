import 'package:rasikh/core/widgets/custom_dialog.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/my_custom_icon.dart';
import 'package:rasikh/core/widgets/picture.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/get_it_service/get_it_service.dart';




class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const  CustomAppBar({super.key});

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

        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(isRtl ?  0:3.14159), // ✅ flip horizontally for RTL
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
                  begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  getAssetImage("avatar.png"),
                  fit: BoxFit.cover,
                  height: 70.h,
                  width: 70.h,
                ),
              ),
            ),
          )
          ,
        ),
        title: Row(
          children: [
            /// ===== بيانات المستخدم أو العميل =====
            getIt<CacheHelper>().currentToken != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Picture(
                      getAssetIcon('location.svg'),
                      width: 20.h,
                      height: 20.h,
                      color: colors.primary,
                    ),
                    Gap(5.w),
                    Text(
                      Loc.myLocation(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                Gap(5.h),
                SizedBox(
                  width: 250.w,
                  child: Text(
                    Loc.noTitle(),
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "هلا ومرحباً فيك! 👋",
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(5.h),
                Text(
                  "فهد بن فيصل",
                  style: textTheme.bodyMedium?.copyWith(

                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),

            /// ===== أيقونة البحث =====
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

            /// ===== أيقونة الإشعارات =====
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
                        color: colors.error, // من الثيم (أحمر الثيم)
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
                            height: 1.0,
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
