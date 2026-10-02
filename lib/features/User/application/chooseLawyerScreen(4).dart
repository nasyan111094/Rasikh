
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:shimmer/shimmer.dart';
import 'package:size_config/size_config.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';

import '../../../config/navigation/nav.dart';
import '../../../config/theme/colors.dart';

import '../../../core/widgets/error_state_widget.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart';
import 'widgets/consultation_flow_widgets.dart';
import 'widgets/selection_bottom_sheet.dart';

class ChooseLawyerScreen extends StatefulWidget {
  const ChooseLawyerScreen({super.key , required this.recommended});

  final bool recommended  ;


  @override
  State<ChooseLawyerScreen> createState() => _ChooseLawyerScreenState();
}

class _ChooseLawyerScreenState extends State<ChooseLawyerScreen> {
  final TextEditingController searchController = TextEditingController();
  String? _cityKey;
  _LawyerSortOption? _sort;

  List<_LawyerSortOption> get _sortOptions => [
        _LawyerSortOption(Loc.highestRated(), 'rating', 'desc'),
        _LawyerSortOption(Loc.lowestRated(), 'rating', 'asc'),
        _LawyerSortOption(Loc.mostExperienced(), 'experienceYears', 'desc'),
        _LawyerSortOption(Loc.leastExperienced(), 'experienceYears', 'asc'),
        _LawyerSortOption(Loc.nameAToZ(), 'fullName', 'asc'),
        _LawyerSortOption(Loc.nameZToA(), 'fullName', 'desc'),
        _LawyerSortOption(Loc.newest(), 'createdAt', 'desc'),
        _LawyerSortOption(Loc.oldest(), 'createdAt', 'asc'),
      ];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ConsultationApplicationCubit>();
    if (cubit.state.citiesStatus != ConsultationStatus.success) {
      cubit.loadCities();
    }
    if (widget.recommended) {
      cubit.loadRecommendedLawyer();
    } else {
      _reloadLawyers();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _reloadLawyers() {
    final search = searchController.text.trim();
    return context.read<ConsultationApplicationCubit>().loadLawyers(
          search: search.isEmpty ? null : search,
          city: _cityKey,
          sortBy: _sort?.sortBy,
          sortOrder: _sort?.sortOrder,
        );
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<ConsultationApplicationCubit>();
    await Future.wait([
      _reloadLawyers(),
      if (widget.recommended) cubit.loadRecommendedLawyer(),
    ]);
  }

  String _cityName(ConsultationState state, String? city) {
    if (city == null || city.isEmpty) return '—';
    for (final c in state.cities) {
      if (c.key == city) return c.value;
    }
    return city;
  }

  void _showSortBottomSheet(BuildContext context) {
    showSelectionBottomSheet(
      context: context,
      builder: (_) => SelectionBottomSheet<_LawyerSortOption>(
        title: Loc.sortBy(),
        searchHint: Loc.searchHint(),
        showSearch: false,
        items: _sortOptions,
        selectedId: _sort?.id,
        itemId: (o) => o.id,
        itemName: (o) => o.label,
        emptyTitle: Loc.noResults(),
        confirmText: Loc.applyFilter(),
        onConfirm: (option) {
          setState(() => _sort = option);
          _reloadLawyers();
        },
      ),
    );
  }

  void _showCityBottomSheet(BuildContext context) {
    final cubit = context.read<ConsultationApplicationCubit>();
    if (cubit.state.citiesStatus != ConsultationStatus.success) {
      cubit.loadCities();
    }
    showSelectionBottomSheet(
      context: context,
      builder: (_) => BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
        builder: (_, state) => SelectionBottomSheet<EnumValueModel>(
          title: Loc.chooseCityLabel(),
          searchHint: Loc.searchSpecificCity(),
          items: state.cities,
          selectedId: _cityKey,
          isLoading: state.citiesStatus == ConsultationStatus.loading ||
              state.citiesStatus == ConsultationStatus.initial,
          errorMessage: state.citiesStatus == ConsultationStatus.failure
              ? state.citiesError ?? Loc.unableToLoadCities()
              : null,
          onRetry: cubit.loadCities,
          itemId: (c) => c.key,
          itemName: (c) => c.value,
          emptyIcon: Icons.location_city_outlined,
          emptyTitle: Loc.noResults(),
          emptyMessage: Loc.noCitiesAvailable(),
          confirmText: Loc.applyFilter(),
          onConfirm: (city) {
            setState(() => _cityKey = city.key);
            _reloadLawyers();
          },
        ),
      ),
    );
  }


  Future<void> _showTypeBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);
    String? selectedOption = Loc.all();

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.onSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Loc.sortBy(),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Container(
                        decoration: BoxDecoration(
                            color: greyFA, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ],
                  ),
                  GeneralDivider(height: 20.h),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(Loc.applyFilter(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        });
      },
    );
  }


  void _onConsult(
      BuildContext context, ConsultationState state, dynamic lawyer) {
    if (lawyer is LawyerDetailModel) {
      context.read<ConsultationApplicationCubit>().selectLawyer(lawyer);
    } else if (lawyer is LawyerDetailModel) {
      context.read<ConsultationApplicationCubit>().selectLawyer(
        LawyerDetailModel(
          id: lawyer.id,
          fullName: lawyer.fullName,
          photoUrl: lawyer.photoUrl,
          city: lawyer.city,
          experienceYears: lawyer.experienceYears,
          rating: lawyer.rating,
          mainSpecializations: lawyer.mainSpecializations,
          consultationFee: lawyer.consultationFee,
          isCompany: lawyer.isCompany,
          bio: lawyer.bio, subSpecializations: [], ratings: [],
        ),
      );
    }

    if (state.selectedConsultationType == ConsultationType.scheduled) {
      Nav.appointmentBookingScreen(context);
    } else {
      context.read<ConsultationApplicationCubit>().createConsultation();
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: GeneralAppBar(
        title: Loc.chooseLawyer(),
        backIcon: Icons.arrow_back,
        backIconSize: 22,
      ),
      body: BlocListener<ConsultationApplicationCubit, ConsultationState>(
        listenWhen: (prev, curr) =>
        prev.createStatus != curr.createStatus,
        listener: (context, state) {
          if (state.createStatus == ConsultationStatus.loading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const PopScope(
                canPop: false,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
            return;
          }

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          if (state.createStatus == ConsultationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                elevation: 0,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                content: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14.h),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Loc.consultationCreatedSuccessfully(),
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.h,
                              ),
                            ),
                            Gap(2.h),
                            Text(
                              Loc.redirectingToPaymentPage(),
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.h,
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

            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) Nav.paymentScreen(context);
            });
            return;
          }

          if (state.createStatus == ConsultationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.createError ?? Loc.errorCreatingConsultation(),
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: Loc.retryAgain(),
                  textColor: Colors.white,
                  onPressed: () =>
                      context.read<ConsultationApplicationCubit>().createConsultation(),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ConsultationFlowSpacing.horizontal,
                ),
                child: Column(
                  children: [
                    const ConsultationFlowStepper(activeStep: 4),

                    TextField(
                      controller: searchController,
                      textAlign: TextAlign.right,
                      onChanged: (_) => _reloadLawyers(),
                      decoration: InputDecoration(
                        hintText: Loc.searchForSuitableLawyer(),
                        hintStyle: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.hintColor),
                        prefixIcon:
                        Icon(Icons.search, color: theme.hintColor),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ConsultationFlowSpacing.radius),
                          borderSide:
                          BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ConsultationFlowSpacing.radius),
                          borderSide:
                          BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ConsultationFlowSpacing.radius),
                          borderSide:
                          BorderSide(color: colorScheme.primary),
                        ),
                      ),
                    ),
                    Gap(ConsultationFlowSpacing.fieldGap),

                    SizedBox(
                      height: 45.h,
                      child: Row(

                        children: [
                          Expanded(
                            child: _FilterChip(
                              icon: "filter.svg",
                              title: Loc.sortBy(),
                              onTap: () => _showSortBottomSheet(context),
                            ),
                          ),
                          Expanded(
                            child: _FilterChip(
                              icon: "City.svg",
                              title: Loc.city(),
                              onTap: () => _showCityBottomSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(ConsultationFlowSpacing.sectionGap),

                    if (widget.recommended) _buildRecommendedSection(context, state),

                    if (!widget.recommended) Expanded(
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: _buildLawyersList(context, state),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildRecommendedSection(BuildContext context, ConsultationState state) {
    if (state.recommendedLawyerStatus == ConsultationStatus.loading) {
      final theme = Theme.of(context);
      final base = theme.brightness == Brightness.light
          ? Colors.grey.shade300
          : Colors.grey.shade700;
      final highlight = theme.brightness == Brightness.light
          ? Colors.grey.shade100
          : Colors.grey.shade600;
      return Padding(
        padding: EdgeInsets.only(bottom: ConsultationFlowSpacing.sectionGap),
        child: Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(
            height: 150.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.h),
            ),
          ),
        ),
      );
    }

    if (state.recommendedLawyerStatus == ConsultationStatus.failure) {
      return Padding(
        padding: EdgeInsets.only(bottom: ConsultationFlowSpacing.sectionGap),
        child: ErrorStateWidget(
          title: Loc.unableToLoadRecommendedLawyer(),
          message: state.recommendedLawyerError ?? Loc.errorConnectingToServer(),
          actionLabel: Loc.retryAgain(),
          onAction: () => context
              .read<ConsultationApplicationCubit>()
              .loadRecommendedLawyer(),
        ),
      );
    }

    if (state.recommendedLawyerStatus == ConsultationStatus.success &&
        state.recommendedLawyer == null) {
      return Padding(
        padding: EdgeInsets.only(bottom: ConsultationFlowSpacing.sectionGap),
        child: ConsultationEmptyState(
          icon: Icons.person_search_outlined,
          title: Loc.noRecommendedLawyerNow(),
          message: Loc.noSuitableLawyerForSpecialization(),
        ),
      );
    }

    if (state.recommendedLawyerStatus == ConsultationStatus.success && state.recommendedLawyer != null) {
      final lawyer = state.recommendedLawyer!;
      return Padding(
        padding: EdgeInsets.only(bottom: ConsultationFlowSpacing.sectionGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LawyerCard(
              name: lawyer.fullName,
              city: _cityName(state, lawyer.city),
              region: _cityName(state, lawyer.city),
              rating: lawyer.rating,
              specialization: lawyer.mainSpecializations.isNotEmpty
                  ? (lawyer.mainSpecializations.first.name ?? '—')
                  : '—',
              experience: lawyer.experienceYears != null
                  ? '${lawyer.experienceYears}'
                  : '—',
              price: lawyer.consultationFee ?? 0,
              imageUrl: lawyer.photoUrl ?? '',
              statusValue: lawyer.activityStatus,
              isRecommended: true,
              onConsult: () => _onConsult(context, state, lawyer),
              onCardTap: () => Nav.lawyerDetailsScreen(context, Id: lawyer.id),
            ),
            Gap(ConsultationFlowSpacing.cardGap),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }


  Widget _buildLawyersList(BuildContext context, ConsultationState state) {
    if (state.lawyersStatus == ConsultationStatus.loading) {
      return _buildLawyersShimmer(context);
    }

    if (state.lawyersStatus == ConsultationStatus.failure) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 60.h),
          ErrorStateWidget(
            title: Loc.unableToLoadLawyers(),
            message: state.lawyersError ?? Loc.errorConnectingToServer(),
            actionLabel: Loc.retryAgain(),
            onAction: _reloadLawyers,
          ),
        ],
      );
    }

    if (state.lawyers.isEmpty &&
        state.lawyersStatus == ConsultationStatus.success) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          ConsultationEmptyState(
            icon: Icons.person_search_outlined,
            title: Loc.noLawyersAvailable(),
            message: Loc.tryChangingSearchCriteria(),
          ),
        ],
      );
    }

    if (widget.recommended) {
      if (state.recommendedLawyerStatus == ConsultationStatus.success &&
          state.recommendedLawyer != null) {
        final lawyers = [state.recommendedLawyer!];
        return _buildLawyersListView(lawyers, state);
      } else {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 80.h),
            ConsultationEmptyState(
              icon: Icons.person_search_outlined,
              title: Loc.noRecommendedLawyer(),
              message: Loc.noSuitableLawyerFound(),
            ),
          ],
        );
      }
    }

    final recommendedId =
    state.recommendedLawyerStatus == ConsultationStatus.success
        ? state.recommendedLawyer?.id
        : null;
    final lawyers = state.lawyers;

    if (lawyers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          ConsultationEmptyState(
            icon: Icons.person_search_outlined,
            title: Loc.noAdditionalLawyers(),
            message: Loc.recommendedLawyerOnlyOption(),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: lawyers.length,
      separatorBuilder: (_, __) => Gap(ConsultationFlowSpacing.cardGap),
      itemBuilder: (context, index) {
        final lawyer = lawyers[index];
        return LawyerCard(
          name: lawyer.fullName,
          city: _cityName(state, lawyer.city),
          region: _cityName(state, lawyer.city),
          rating: lawyer.rating,
          specialization: lawyer.mainSpecializations.isNotEmpty
              ? (lawyer.mainSpecializations.first.name ?? '—')
              : '—',
          experience: lawyer.experienceYears != null
              ? '${lawyer.experienceYears}'
              : '—',
          price: lawyer.consultationFee ?? 0,
          imageUrl: lawyer.photoUrl ?? '',
          statusValue: lawyer.activityStatus,
          onConsult: () => _onConsult(context, state, lawyer),
          onCardTap: () => Nav.lawyerDetailsScreen(context, Id: lawyer.id),
        );
      },
    );
  }

  Widget _buildLawyersListView(List<LawyerDetailModel> lawyers, ConsultationState state) {
    return ListView.separated(
      itemCount: lawyers.length,
      separatorBuilder: (_, __) => Gap(ConsultationFlowSpacing.cardGap),
      itemBuilder: (context, index) {
        LawyerDetailModel lawyer = lawyers[index];
        return LawyerCard(
          name: lawyer.fullName,
          city: _cityName(state, lawyer.city),
          region: _cityName(state, lawyer.city),
          rating: lawyer.rating,
          specialization: lawyer.mainSpecializations.isNotEmpty
              ? (lawyer.mainSpecializations.first.name ?? '—')
              : '—',
          experience: lawyer.experienceYears != null
              ? '${lawyer.experienceYears}'
              : '—',
          price: lawyer.consultationFee ?? 0,
          imageUrl: lawyer.photoUrl ?? '',
          statusValue: lawyer.activityStatus,
          isRecommended: widget.recommended,
          onConsult: () => _onConsult(context, state, lawyer),
          onCardTap: () {
            Nav.lawyerDetailsScreen(context, Id: lawyer.id);
          },
        );
      },
    );
  }

  Widget _buildLoadingOrEmptyState(ConsultationState state) {
    if (state.recommendedLawyerStatus == ConsultationStatus.loading) {
      return _buildLawyersShimmer(context);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 48,
            color: Theme.of(context).hintColor,
          ),
          Gap(12.h),
          Text(
            Loc.noRecommendedLawyerNow(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLawyersShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final highlight = theme.brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade600;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => Gap(ConsultationFlowSpacing.cardGap),
        itemBuilder: (_, __) => Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }
}



class LawyerStatusInfo {
  final String label;
  final Color color;

  const LawyerStatusInfo(this.label, this.color);
}

LawyerStatusInfo? resolveLawyerStatus(String? value) {
  switch (value) {
    case 'available_now':
      return LawyerStatusInfo(Loc.availableNow(), Color(0xFF2E7D32));
    case 'busy':
    case 'in_consultation':
      return LawyerStatusInfo(Loc.busy(), Color(0xFFE08C00));
    case 'offline':
    case 'unavailable':
    case 'away':
      return LawyerStatusInfo(Loc.offline(), Color(0xFF9E9E9E));
    default:
      return null;
  }
}


class LawyerCard extends StatelessWidget {
  final String name;
  final String city;
  final String region;
  final double rating;
  final String specialization;
  final String experience;
  final double price;
  final String imageUrl;
  final String? statusValue;
  final bool isRecommended;
  final VoidCallback onConsult;
  final VoidCallback? onCardTap;

  const LawyerCard({
    super.key,
    required this.name,
    required this.city,
    required this.region,
    required this.rating,
    required this.specialization,
    required this.experience,
    required this.price,
    required this.imageUrl,
    this.statusValue,
    this.isRecommended = false,
    required this.onConsult,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final status = resolveLawyerStatus(statusValue);
    final hasPrice = price > 0;

    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isRecommended
              ? theme.colorScheme.primary.withOpacity(0.04)
              : null,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: isRecommended
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.dividerColor,
            width: isRecommended ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 14.h),
                      Gap(6.w),
                      Text(
                        Loc.bestMatchForRequest(),
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl.isNotEmpty
                            ? Picture(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.person,
                            size: 40.h,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    if (status != null)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: status.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.cardColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: -10.h,
                      left: 3.w,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10.h),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 18),
                            SizedBox(width: 4.w),
                            Text(
                              rating.toStringAsFixed(1),
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Gap(4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16.w, color: theme.hintColor),
                          Gap(4.w),
                          Expanded(
                            child: Text(
                              '$city - $region',
                              style: textTheme.bodySmall
                                  ?.copyWith(color: theme.hintColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (status != null) ...[
                        Gap(6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: status.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8.h),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: status.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Gap(5.w),
                              Text(
                                status.label,
                                style: textTheme.labelSmall?.copyWith(
                                  color: status.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Gap(12.h),
            GeneralDivider(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoColumn(title: Loc.yearsOfExperience(), value: experience),
                Container(
                    height: 40.h, width: 1, color: theme.dividerColor),
                _InfoColumn(title: Loc.specialization(), value: specialization),
                Container(
                    height: 40.h, width: 1, color: theme.dividerColor),
                _InfoColumn(
                  title: Loc.consultationPriceAlt(),
                  value: hasPrice
                      ? Loc.amountRiyal(price.toStringAsFixed(0))
                      : Loc.amountRiyal(context
                      .read<ConsultationApplicationCubit>()
                      .selectedPricing
                      ?.basePrice ?? 0),
                  valueColor: theme.colorScheme.primary,
                ),
              ],
            ),
            GeneralDivider(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1B28E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                ),
                onPressed: onConsult,
                child: Text(
                  Loc.consultNowAlt(),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoColumn(
      {required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: textTheme.bodySmall),
        Gap(4.h),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.0.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(10.h),
          ),
          child: Row(
            children: [
              Picture(
                getAssetIcon(icon),
                width: 20.w,
                height: 20.w,
                color: theme.colorScheme.onSurface,
              ),
              Gap(4.w),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
              ),
              Gap(4.w),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: greyF4,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.keyboard_arrow_down,
                    size: 13, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _LawyerSortOption {
  const _LawyerSortOption(this.label, this.sortBy, this.sortOrder);

  final String label;
  final String sortBy;
  final String sortOrder;

  String get id => '$sortBy-$sortOrder';
}
