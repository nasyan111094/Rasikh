import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

class MainWidget extends StatelessWidget {
  MainWidget(
      {super.key, required this.title, required this.iconPath, this.onTap});
  String title;
  String iconPath;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: SizedBox(
          width: double.infinity,
          height: 80.h,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 80.h,
                decoration: BoxDecoration(
                    color: greyFA, borderRadius: BorderRadius.circular(1000.h)),
              ),
              Row(
                children: [
                  Container(
                    height: 80.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xff56B948),
                          Color(0xff195950),
                        ]),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(1000.h),
                          bottomRight: Radius.circular(1000.h),
                          topLeft: Radius.circular(300.h),
                          bottomLeft: Radius.circular(300.h),
                        )),
                    child: Center(
                      child: Container(
                        height: 40.h,
                        width: 40.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: greyFA,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.h),
                          child: Picture(getAssetIcon(iconPath)),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 80.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1000.h)),
                    child: Center(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: greyFA,
                        ),
                        child: IconButton(
                            onPressed: onTap,
                            icon: const Icon(Icons.arrow_forward_sharp)),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 70,
                top: 5,
                bottom: 5.h,
                child: Container(
                  height: 40.h,
                  width: 40.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: greyFA,
                  ),
                ),
              ),
              Positioned(
                right: 80,
                top: 10.h,
                bottom: 10.h,
                child: SizedBox(
                    height: 60.h,
                    child: Center(
                        child: Text(
                      title,
                      style: getBoldPrimary14Style(),
                    ))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
