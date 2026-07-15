import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/error_state_widget.dart';
import 'package:rasikh/core/widgets/loading_widget.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/features/User/home/widgets/ads_slider.dart';
import 'package:rasikh/features/User/home/widgets/custom_app_bar_widget.dart';
import 'package:rasikh/features/User/home/widgets/options.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../profile/cubit/profile_cubit.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'models/advertising_response_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().getAdevertisingDataWithDataBase();
    // Load profile once so CustomAppBar has real data immediately.
    // ProfileCubit must be provided above this widget (e.g. in the
    // bottom-nav scaffold) as a singleton via getIt.
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void didPopNext() {
    context.read<HomeCubit>().getAdevertisingDataWithDataBase();
  }



  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      // CustomAppBar uses BlocBuilder<ProfileCubit> internally —
      // no params needed; it reads the singleton cubit from context.
      appBar: CustomAppBar<ProfileCubit, ProfileState>(
        getFullName: (state) => state.data?.fullName,
        getAvatar: (state) => state.data?.avatar,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(10.h),

          /// 🔹 سلايدر الإعلانات
          BlocConsumer<HomeCubit, HomeState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is HomeLoadingState) {
                return const LoadingWidget();
              }
              else if (state is HomeFailedState) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Center(
                    child: ErrorStateWidget(title: state.error!),
                  ),
                );
              } else if (state is HomeSuccessState) {

                return AdsSlider(
                  imageUrls: state.advertismentResponseModel.data,
                );
              }
              return const SizedBox.shrink();
            },
          ),

          Gap(30.h),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'كيف نقدر نخدمك ؟',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ) ,
          Gap(10.h),

          /// 🔹 قائمة الاستشارات القانونية
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimationLimiter(
                child: ListView.separated(
                  itemCount: 1,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 1000),
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: SingleChildScrollView(
                            child: LegalConsultationCard(
                              onPressed: () {
                                Nav.chooseSpecialtyScreen(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => Gap(24.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}