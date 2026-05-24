import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
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

  final List<Advertise> advertiseList = [
    Advertise(
      image:
      'https://cdn.maatloob.com/profile/portfolios/p650x650/img-66c22464c3f9c9-07578467.jpg',
      id: '1',
      date: '2025-10-01',
    ),
    Advertise(
      image:
      'https://files.cdn-files-a.com/uploads/6002121/normal_67e02259d9d54.png',
      id: '2',
      date: '2025-10-02',
    ),
    Advertise(
      image:
      'https://almehleky.sa/wp-content/uploads/2024/08/%D8%A3%D9%81%D8%B6%D9%84-%D9%85%D8%AD%D8%A7%D9%85%D9%8A-%D8%A7%D9%88%D9%86-%D9%84%D8%A7%D9%8A%D9%86-%D9%81%D9%8A-%D8%A7%D9%84%D8%B3%D8%B9%D9%88%D8%AF%D9%8A%D8%A9-%D9%84%D8%B9%D8%A7%D9%85-2024.webp',
      id: '3',
      date: '2025-10-03',
    ),
    Advertise(
      image:
      'https://files.cdn-files-a.com/uploads/6002121/800_67e01fdd5ec86_filter_67e0205c9fa7c.png',
      id: '4',
      date: '2025-10-04',
    ),
  ];

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
                return SizedBox(
                  height: 220.h,
                  width: double.infinity,
                  child: Center(child: AdsSlider(imageUrls: advertiseList)),
                );
              } else if (state is HomeFailedState) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Center(
                    child: Text(
                      Loc.noAds(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              } else if (state is HomeSuccessState) {
                return AdsSlider(
                  imageUrls: state.advertismentResponseModel.data.listData,
                );
              }
              return const SizedBox.shrink();
            },
          ),

          Gap(30.h),

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