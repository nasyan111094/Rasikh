import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/features/common/Auth/models/auth_model.dart';
import 'package:rasikh/features/common/account_type_selection/widgets/account_type_card.dart';
import 'package:size_config/size_config.dart';

import '../../../../../../core/utils/get_asset_path.dart';
import '../../../../../../core/widgets/picture.dart';
import '../../../../config/navigation/nav.dart';
import '../../../../core/get_it_service/get_it_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/widgets/user_selector/general_app_button.dart';
import '../models/account_type_model.dart';








class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    getIt<CacheHelper>().cachedVendorType = VendorType.user ;
    getIt<CacheHelper>().setCurrentVendorType(VendorType.user) ;

    Logger().i(getIt<CacheHelper>().cachedVendorType);
  }


  final List<AccountTypeModel> accountTypes = const [
    AccountTypeModel(
      type: VendorType.user,
      title: "التسجيل كمستخدم",
      subtitle: "احصل على استشارة قانونية سريعة وموثوقة.",
      icon: "user.svg",
    ),

    AccountTypeModel(
      type: VendorType.lawyer,
      title: "التسجيل كمحامي",
      subtitle: "قدّم استشاراتك القانونية بأمان وسهولة.",
      icon: "lawyer.svg",
    ),

    AccountTypeModel(
      type: VendorType.company,
      title: "التسجيل كشركة محاماه",
      subtitle: "احصل على استشارة قانونية سريعة وموثوقة.",
      icon: "City.svg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                SizedBox(height: 20.h),

                const AuthStepperWidget(
                  totalSteps: 3,
                  activeStep: 1,
                ),

                SizedBox(height: 20.h),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),

                      /// Logo + Title + Subtitle
                      Picture(
                        getAssetIcon("no_bg_logo.svg"),
                        width: 100.w,
                        height: 40.h,
                      ),

                      SizedBox(height: 24.h),

                      Text(
                        "اختر نوع الحساب",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      Text(
                        "مستخدم أو محامي أو شركة محاماه؟ حدد حسابك لتجربة آمنة وسلسة.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 32.h),

                      /// Account Types
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: accountTypes.length,
                          itemBuilder: (context, index) {
                            final item = accountTypes[index];

                            return AccountTypeCard(
                              item: item,
                              selectedValue: getIt<CacheHelper>().cachedVendorType!,
                              onChanged: (value) {
                                setState(() {

                                  getIt<CacheHelper>().cachedVendorType =value ;
                                  getIt<CacheHelper>().setCurrentVendorType(value) ;

                                });
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16.h),

                      /// Next Button
                      AppButton(
                        title: "التالي",
                        onPressed: () {
                          Nav.login(context);
                        },
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}