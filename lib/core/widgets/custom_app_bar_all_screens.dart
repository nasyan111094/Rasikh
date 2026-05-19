import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';
import '../../config/theme/colors.dart';
import '../../config/theme/styles_manager.dart';

class CustomAppBarAllScreens extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isFilter;
  final Function() onTap;
  final Color? filterColor;
  final Color? colorTextFilter;
  final Color? colorIconFilter;
  final VoidCallback? onFilterTap;

  const CustomAppBarAllScreens({
    super.key,
    required this.title,
    this.isFilter = false,
    this.filterColor = colorSBTn,
    this.onFilterTap,
    this.colorTextFilter,
    this.colorIconFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.only(top: 24.h, start: 16.w, end: 16.w),
        child: Column(
          children: [
            Row(
              children: [
                // زر الرجوع
                Container(
                  width: 40.w,
                  height: 40.h,
                  padding: EdgeInsetsDirectional.all(10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.w),
                    ),
                    color: const Color(0xffE8EEEE),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/arrow_right.svg',
                    width: 24.w,
                    height: 24.h,
                    color: primary,
                  ),
                ),
                Gap(16.w),
                Text(title, style: getPrimaryRegular18Style()),
                const Spacer(),
                if (isFilter)
                  GestureDetector(
                    onTap: onFilterTap,
                    child: Container(
                      width: 100.w,
                      height: 40.h,
                      padding: EdgeInsetsDirectional.all(8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.w)),
                        color: filterColor,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/filter.svg',
                            width: 24.w,
                            height: 24.h,
                            color: colorIconFilter,
                          ),
                          Gap(4.w),
                          Text(
                            'تصفية',
                            style: getPrimaryRegular16Style()
                                .copyWith(color: colorTextFilter),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Gap(8.h),
            const Divider(height: 1, color: colorBorders)
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(85.h);
}
