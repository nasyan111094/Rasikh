// ─────────────────────────────────────────────────────────────────────────────
// choose_lawyer_screen.dart  (Step 4)
// Changes:
//  • Shimmer loading skeleton for lawyer cards
//  • Pull-to-refresh on the lawyers list
//  • City bottom sheet now loads cities from /api/v1/enums/cities
//    with shimmer while loading and retry on failure
//  • "استشر الآن" button on LawyerCard:
//    - Scheduled  → selectLawyer then navigate to appointmentBookingScreen (NO createConsultation)
//    - Instant/Written → selectLawyer then createConsultation → navigate to paymentScreen on success
//  • BlocListener handles loading dialog, success navigation, and error snackbar
//  • LawyerCard onTap navigates to LawyerDetailsScreen AND passes lawyerId
//    to cubit so the details screen can show "استشر الآن" correctly
// ─────────────────────────────────────────────────────────────────────────────

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
import '../../../core/widgets/auth_stepper.dart';

import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart';

class ChooseLawyerScreen extends StatefulWidget {
  const ChooseLawyerScreen({super.key});

  @override
  State<ChooseLawyerScreen> createState() => _ChooseLawyerScreenState();
}

class _ChooseLawyerScreenState extends State<ChooseLawyerScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<ConsultationCubit>().loadLawyers(
      search: searchController.text.isEmpty ? null : searchController.text,
    );
  }

  // ── Sort bottom sheet ─────────────────────────────────────────────────────

  Future<void> _showSortBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);
    String? selectedOption = 'الأعلى تقييماً';

    final options = [
      'الأعلى تقييماً',
      'الأقل سعراً',
      'الأكثر خبرة',
      'الأقرب موقعاً',
      'المتاح الآن',
    ];

    final sortMap = {
      'الأعلى تقييماً': ('rating', 'desc'),
      'الأقل سعراً': ('consultationFee', 'asc'),
      'الأكثر خبرة': ('experienceYears', 'desc'),
      'المتاح الآن': ('rating', 'desc'),
    };

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.onSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الترتيب حسب',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Container(
                        decoration:
                        BoxDecoration(color: greyFA, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  GeneralDivider(height: 20.h),
                  ...options.map(
                        (opt) => InkWell(
                      onTap: () => setModalState(() => selectedOption = opt),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 10.w),
                            child: Row(
                              children: [
                                Text(
                                  opt,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: selectedOption == opt
                                        ? theme.colorScheme.primary
                                        : null,
                                    fontWeight: selectedOption == opt
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const Spacer(),
                                Checkbox(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  side: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.5)),
                                  activeColor: theme.colorScheme.primary,
                                  value: selectedOption == opt,
                                  onChanged: (_) =>
                                      setModalState(() => selectedOption = opt),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        final sort = sortMap[selectedOption];
                        context.read<ConsultationCubit>().loadLawyers(
                          sortBy: sort?.$1,
                          sortOrder: sort?.$2,
                        );
                      },
                      child: Text('تطبيق التصفية',
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

  // ── City bottom sheet – cities from /api/v1/enums/cities ─────────────────

  Future<void> _showCityBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);
    String? selectedOption;
    final citySearchController = TextEditingController();

    // Trigger city load from API
    context.read<ConsultationCubit>().loadCities();

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.onSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocBuilder<ConsultationCubit, ConsultationState>(
          builder: (ctx, state) {
            final allCities =
            state.cityNames.isNotEmpty ? state.cityNames : <String>[];
            return StatefulBuilder(builder: (ctx, setModalState) {
              final filtered = citySearchController.text.isEmpty
                  ? allCities
                  : allCities
                  .where((c) => c.contains(citySearchController.text))
                  .toList();

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
                          Text('اختر المدينة',
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
                      TextField(
                        controller: citySearchController,
                        textAlign: TextAlign.right,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: 'بحث عن مدينة محددة...',
                          hintStyle: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.hintColor),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(15.0.h),
                            child: Picture(getAssetIcon("search.svg"),
                                width: 20.h, height: 20.h),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.h),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.h),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.h),
                            borderSide:
                            BorderSide(color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                      Gap(10.h),
                      // ── Cities list with shimmer / error / data ────
                      SizedBox(
                        height: 300.h,
                        child: _buildCitiesContent(
                          ctx,
                          state,
                          theme,
                          filtered,
                          selectedOption,
                              (opt) => setModalState(() => selectedOption = opt),
                        ),
                      ),
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
                          onPressed: () {
                            Navigator.pop(ctx);
                            context
                                .read<ConsultationCubit>()
                                .loadLawyers(city: selectedOption);
                          },
                          child: Text('تطبيق التصفية',
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
      },
    );
  }

  Widget _buildCitiesContent(
      BuildContext ctx,
      ConsultationState state,
      ThemeData theme,
      List<String> filtered,
      String? selectedOption,
      void Function(String) onSelect,
      ) {
    // Shimmer
    if (state.citiesStatus == ConsultationStatus.loading) {
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
          itemCount: 8,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (_, __) => Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Error
    if (state.citiesStatus == ConsultationStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: theme.colorScheme.error, size: 36),
            Gap(8.h),
            Text(
              state.citiesError ?? 'تعذر تحميل المدن',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Gap(12.h),
            TextButton(
              onPressed: () =>
                  context.read<ConsultationCubit>().loadCities(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // Empty
    if (filtered.isEmpty) {
      return Center(
        child: Text('لا توجد نتائج',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.hintColor)),
      );
    }

    // Data
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (ctx, index) {
        final opt = filtered[index];
        final selected = selectedOption == opt;
        return InkWell(
          onTap: () => onSelect(opt),
          child: Container(
            height: 60.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.w),
            child: Row(
              children: [
                Text(
                  opt,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: selected ? theme.colorScheme.primary : null,
                    fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Checkbox(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.5)),
                  activeColor: theme.colorScheme.primary,
                  value: selected,
                  onChanged: (_) => onSelect(opt),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Type bottom sheet ─────────────────────────────────────────────────────

  Future<void> _showTypeBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);
    String? selectedOption = 'الكل';
    final types = ['الكل', 'محامي', 'محامية'];

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
                      Text('الترتيب حسب',
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
                  SizedBox(
                    height: 60.h,
                    child: ListView.separated(
                      itemCount: types.length,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (ctx, index) {
                        final opt = types[index];
                        final selected = selectedOption == opt;
                        return InkWell(
                          onTap: () =>
                              setModalState(() => selectedOption = opt),
                          child: Container(
                            height: 30.h,
                            width: 125.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border:
                              Border.all(color: theme.dividerColor),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 10.w),
                            child: Row(
                              children: [
                                Text(
                                  opt,
                                  style: theme.textTheme.bodyLarge
                                      ?.copyWith(
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : null,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const Spacer(),
                                Checkbox(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(6)),
                                  side: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.5)),
                                  activeColor: theme.colorScheme.primary,
                                  value: selected,
                                  onChanged: (_) => setModalState(
                                          () => selectedOption = opt),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                      child: Text('تطبيق التصفية',
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

  // ── "استشر الآن" handler ──────────────────────────────────────────────────
  //
  // • Scheduled  → selectLawyer only, then go to appointmentBookingScreen.
  //                createConsultation is NOT called here; the booking screen
  //                will call it after the user picks a time slot.
  //
  // • Instant / Written → selectLawyer, then call createConsultation.
  //                       Navigation is handled by the BlocListener below
  //                       once createStatus becomes success.

  void _onConsult(
      BuildContext context, ConsultationState state, dynamic lawyer) {
    // ── 1. Normalise lawyer type and select it in the cubit ──────────────
    if (lawyer is LawyerModel) {
      context.read<ConsultationCubit>().selectLawyer(lawyer);
    } else if (lawyer is LawyerDetailModel) {
      context.read<ConsultationCubit>().selectLawyer(
        LawyerModel(
          id: lawyer.id,
          fullName: lawyer.fullName,
          photoUrl: lawyer.photoUrl,
          city: lawyer.city,
          experienceYears: lawyer.experienceYears,
          rating: lawyer.rating,
          mainSpecializations: lawyer.mainSpecializations,
          consultationFee: lawyer.consultationFee,
          isCompany: lawyer.isCompany,
          bio: lawyer.bio,
        ),
      );
    }

    // ── 2. Branch on consultation type ───────────────────────────────────
    if (state.selectedConsultationType == ConsultationType.scheduled) {
      // Scheduled: skip createConsultation, go straight to booking screen.
      Nav.appointmentBookingScreen(context);
    } else {
      // Instant / Written: create the consultation now.
      // The BlocListener will navigate to paymentScreen on success.
      context.read<ConsultationCubit>().createConsultation();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const GeneralAppBar(title: "اختر المحامي"),
      body: BlocListener<ConsultationCubit, ConsultationState>(
        // Only react when createStatus actually changes
        listenWhen: (prev, curr) =>
        prev.createStatus != curr.createStatus,
        listener: (context, state) {
          // ── Loading: show a non-dismissible progress dialog ──────────
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

          // Dismiss the loading dialog for both success and failure
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          // ── Success: show snackbar then navigate to payment screen ──────
          // (Only instant/written reach this point — scheduled never calls
          // createConsultation from this screen.)
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
                              'تم إنشاء الاستشارة بنجاح',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.h,
                              ),
                            ),
                            Gap(2.h),
                            Text(
                              'سيتم تحويلك إلى صفحة الدفع',
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

            // Navigate after snackbar has time to show
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) Nav.paymentScreen(context);
            });
            return;
          }

          // ── Failure: show error snackbar with retry action ────────────
          if (state.createStatus == ConsultationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.createError ?? 'حدث خطأ أثناء إنشاء الاستشارة',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'إعادة المحاولة',
                  textColor: Colors.white,
                  onPressed: () =>
                      context.read<ConsultationCubit>().createConsultation(),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: BlocBuilder<ConsultationCubit, ConsultationState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: const AuthStepperWidget(
                          activeStep: 4, totalSteps: 5),
                    ),

                    // ── Search ─────────────────────────────────────────
                    TextField(
                      controller: searchController,
                      textAlign: TextAlign.right,
                      onChanged: (value) => context
                          .read<ConsultationCubit>()
                          .loadLawyers(search: value),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن المحامي المناسب...',
                        hintStyle: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.hintColor),
                        prefixIcon:
                        Icon(Icons.search, color: theme.hintColor),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.h),
                          borderSide:
                          BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.h),
                          borderSide:
                          BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.h),
                          borderSide:
                          BorderSide(color: colorScheme.primary),
                        ),
                      ),
                    ),
                    Gap(12.h),

                    // ── Filter chips ───────────────────────────────────
                    SizedBox(
                      height: 45.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            icon: "filter.svg",
                            title: 'الترتيب حسب',
                            onTap: () => _showSortBottomSheet(context),
                          ),
                          _FilterChip(
                            icon: "users.svg",
                            title: 'محامي أو محامية',
                            onTap: () => _showTypeBottomSheet(context),
                          ),
                          _FilterChip(
                            icon: "City.svg",
                            title: 'المدينة',
                            onTap: () => _showCityBottomSheet(context),
                          ),
                        ],
                      ),
                    ),
                    Gap(20.h),

                    // ── Recommended lawyer banner ──────────────────────
                    if (state.recommendedLawyerStatus ==
                        ConsultationStatus.success &&
                        state.recommendedLawyer != null)
                      _RecommendedBanner(
                        lawyer: state.recommendedLawyer!,
                        onConsult: () =>
                            _onConsult(context, state, state.recommendedLawyer!),
                      ),

                    // ── Lawyers list with pull-to-refresh ──────────────
                    Expanded(
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

  // ── Lawyers list ──────────────────────────────────────────────────────────

  Widget _buildLawyersList(BuildContext context, ConsultationState state) {
    if (state.lawyersStatus == ConsultationStatus.loading) {
      return _buildLawyersShimmer(context);
    }

    if (state.lawyersStatus == ConsultationStatus.failure) {
      return ListView(
        children: [
          SizedBox(height: 60.h),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: Theme.of(context).colorScheme.error, size: 48),
                Gap(12.h),
                Text(state.lawyersError ?? 'حدث خطأ ما'),
                Gap(12.h),
                ElevatedButton(
                  onPressed: () =>
                      context.read<ConsultationCubit>().loadLawyers(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state.lawyers.isEmpty &&
        state.lawyersStatus == ConsultationStatus.success) {
      return ListView(
        children: [
          SizedBox(height: 80.h),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_search,
                    size: 48, color: Theme.of(context).hintColor),
                Gap(12.h),
                const Text('لا يوجد محامون متاحون'),
              ],
            ),
          ),
        ],
      );
    }

    final lawyers = state.lawyers;

    return ListView.separated(
      itemCount: lawyers.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final lawyer = lawyers[index];
        return LawyerCard(
          name: lawyer.fullName,
          city: lawyer.city ?? '—',
          region: lawyer.city ?? '—',
          rating: lawyer.rating,
          specialization: lawyer.mainSpecializations.isNotEmpty
              ? (lawyer.mainSpecializations.first.name ?? '—')
              : '—',
          experience: lawyer.experienceYears != null
              ? '${lawyer.experienceYears}'
              : '—',
          price: lawyer.consultationFee ?? 0,
          imageUrl: lawyer.photoUrl ?? '',
          available: true,
          onConsult: () => _onConsult(context, state, lawyer),
          onCardTap: () {
            Nav.lawyerDetailsScreen(context , Id: lawyer.id);
          },
        );
      },
    );
  }

  // ── Shimmer for lawyer cards ──────────────────────────────────────────────

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
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
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

// ─────────────────────────────────────────────────────────────────────────────
// Recommended banner
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendedBanner extends StatelessWidget {
  final LawyerDetailModel lawyer;
  final VoidCallback onConsult;

  const _RecommendedBanner({required this.lawyer, required this.onConsult});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.h),
        border:
        Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome,
              color: theme.colorScheme.primary, size: 18.h),
          Gap(8.w),
          Expanded(
            child: Text(
              'مقترح: ${lawyer.fullName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: onConsult,
            child: const Text('استشر الآن'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LawyerCard
// ─────────────────────────────────────────────────────────────────────────────

class LawyerCard extends StatelessWidget {
  final String name;
  final String city;
  final String region;
  final double rating;
  final String specialization;
  final String experience;
  final double price;
  final String imageUrl;
  final bool available;
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
    required this.available,
    required this.onConsult,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onCardTap ?? () => onCardTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      padding: const EdgeInsets.all(2), // border thickness
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
                    ) ,
                    if (available)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
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
                          Text(
                            '$city - $region',
                            style: textTheme.bodySmall
                                ?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
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
                _InfoColumn(title: 'سنوات الخبرة', value: experience),
                Container(
                    height: 40.h, width: 1, color: theme.dividerColor),
                _InfoColumn(title: 'التخصص', value: specialization),
                Container(
                    height: 40.h, width: 1, color: theme.dividerColor),
                _InfoColumn(
                  title: 'سعر الإستشارة',
                  value: '${price.toStringAsFixed(0)} ريال',
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
                // onConsult already handles the scheduled/non-scheduled
                // branching and createConsultation call — no extra logic here.
                onPressed: onConsult,
                child: const Text(
                  'استشر الآن',
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
              Picture(getAssetIcon(icon), color: theme.colorScheme.onSurface),
              Gap(4.w),
              Text(title,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurface)),
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