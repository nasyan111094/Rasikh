import 'package:rasikh/core/widgets/error_state_widget.dart';
import 'package:rasikh/core/widgets/loading_widget.dart';

import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/features/User/home/widgets/ads_slider.dart';
import 'package:rasikh/features/User/home/widgets/home_header.dart';
import 'package:rasikh/features/User/home/widgets/home_section_title.dart';
import 'package:rasikh/features/User/home/widgets/options.dart';
import 'package:size_config/size_config.dart';

import '../../../config/navigation/nav.dart';
import '../profile/cubit/profile_cubit.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';

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
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void didPopNext() {
    context.read<HomeCubit>().getAdevertisingDataWithDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeHeader(),
      body: AnimationLimiter(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: 22.h, bottom: 24.h),
          children: [
            BlocConsumer<HomeCubit, HomeState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is HomeLoadingState) {
                  return const LoadingWidget();
                } else if (state is HomeFailedState) {
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
            Gap(24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: HomeSectionTitle(title: Loc.howCanWeHelpYou()),
            ),
            Gap(12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: AnimationConfiguration.staggeredList(
                position: 0,
                duration: const Duration(milliseconds: 1000),
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: LegalConsultationCard(
                      onPressed: () {
                        Nav.chooseSpecialtyScreen(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
