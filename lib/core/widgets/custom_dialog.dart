import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:size_config/size_config.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 700.w,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                "عزيزنا العميل ",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[900],
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                "يرجي تسجبل الدخول للوصول لخدماتنا",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              SizedBox(
                height: 55.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Agree button
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                          ),
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Nav.login(context);
                        },
                        child: Text(
                          Loc.agree(),
                          style: getBoldGreyD014Style().copyWith(color: white),
                        ),
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: DottedBorder(
                          padding: const EdgeInsets.all(0),
                          color: greyEE,
                          strokeWidth: 1,
                          dashPattern: const [3, 3],
                          borderType: BorderType.RRect,
                          radius: Radius.circular(10.h),
                          child: Center(
                            child: TextButton(
                              onPressed: null,
                              child: Text(
                                Loc.cancel(),
                                style: getBoldGreyD014Style(),
                              ),
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
      ),
    );
  }
}
