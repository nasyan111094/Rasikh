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

import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/no_data_widget.dart';
import 'bloc/consulation_application_cubit.dart';
import 'bloc/consulation_application_state.dart';
import 'models/consultation_model.dart';

class ChooseLawyerScreen extends StatefulWidget {
  const ChooseLawyerScreen({super.key , required this.recommended});

  final bool recommended  ;


  @override
  State<ChooseLawyerScreen> createState() => _ChooseLawyerScreenState();
}

class _ChooseLawyerScreenState extends State<ChooseLawyerScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ Previously nothing triggered these — the screen depended entirely
    // on a search/filter/refresh action to populate anything at all.
    // Load the regular lawyers list AND the AI-recommended lawyer for the
    // chosen specialization the moment this screen opens.
    final cubit = context.read<ConsultationApplicationCubit>();
    cubit.loadLawyers();
    if (widget.recommended) {
      cubit.loadRecommendedLawyer();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<ConsultationApplicationCubit>();
    final futures = [
      cubit.loadLawyers(
        search: searchController.text.isEmpty ? null : searchController.text,
      ),
    ];
    if (widget.recommended) {
      futures.add(cubit.loadRecommendedLawyer());
    }
    await Future.wait(futures);
  }

  // ── Sort bottom sheet ─────────────────────────────────────────────────────

  Future<void> _showSortBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);
    String? selectedOption = 'الأعلى تقييماً';

    final options = [
      'الأعلى تقييماً',
      'الأقل تقييماً',
      'الأكثر خبرة',
      'الأقل خبرة',
      'الاسم أ-ي',
      'الاسم ي-أ',
      'الأحدث',
      'الأقدم',
    ];

    final sortMap = {
      'الأعلى تقييماً': ('rating', 'desc'),
      'الأقل تقييماً': ('rating', 'asc'),
      'الأكثر خبرة': ('experienceYears', 'desc'),
      'الأقل خبرة': ('experienceYears', 'asc'),
      'الاسم أ-ي': ('fullName', 'asc'),
      'الاسم ي-أ': ('fullName', 'desc'),
      'الأحدث': ('createdAt', 'desc'),
      'الأقدم': ('createdAt', 'asc'),
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
                        context.read<ConsultationApplicationCubit>().loadLawyers(
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
    context.read<ConsultationApplicationCubit>().loadCities();

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.onSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocBuilder<ConsultationApplicationCubit, ConsultationState>(
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
                                .read<ConsultationApplicationCubit>()
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
    // ── Loading State ───────────────────────────────────────────────────────
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

    // ── Error State ─────────────────────────────────────────────────────────
    if (state.citiesStatus == ConsultationStatus.failure) {
      return Center(
        child: ErrorStateWidget(
          title: 'تعذر تحميل المدن',
          message: state.citiesError ?? 'حدث خطأ أثناء الاتصال بالخادم',
          actionLabel: 'إعادة المحاولة',
          onAction: () => context.read<ConsultationApplicationCubit>().loadCities(),
        ),
      );
    }

    // ── Empty State ─────────────────────────────────────────────────────────
    if (filtered.isEmpty) {
      return Center(
        child: NoDataWidget(
          icon: Icons.location_city_outlined,
          title: 'لا توجد نتائج',
          message:  'لا توجد مدن متاحة حالياً'
            ,
        ),
      );
    }

    // ── Success with Data ───────────────────────────────────────────────────
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
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
   /* final types = ['الكل', 'محامي', 'محامية'];*/

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
                /*  SizedBox(
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
                  ),*/
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

    // ── 2. Branch on consultation type ───────────────────────────────────
    if (state.selectedConsultationType == ConsultationType.scheduled) {
      // Scheduled: skip createConsultation, go straight to booking screen.
      Nav.appointmentBookingScreen(context);
    } else {
      // Instant / Written: create the consultation now.
      // The BlocListener will navigate to paymentScreen on success.
      context.read<ConsultationApplicationCubit>().createConsultation();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const GeneralAppBar(title: "اختر المحامي"),
      body: BlocListener<ConsultationApplicationCubit, ConsultationState>(
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
                          .read<ConsultationApplicationCubit>()
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
                      child: Row(

                        children: [
                          Expanded(
                            child: _FilterChip(
                              icon: "filter.svg",
                              title: 'الترتيب حسب',
                              onTap: () => _showSortBottomSheet(context),
                            ),
                          ),
                      /*    _FilterChip(
                            icon: "users.svg",
                            title: 'محامي أو محامية',
                            onTap: () => _showTypeBottomSheet(context),
                          ),*/
                          Expanded(
                            child: _FilterChip(
                              icon: "City.svg",
                              title: 'المدينة',
                              onTap: () => _showCityBottomSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(20.h),

                    // ── Recommended lawyer section ──────────────────────
                    if (widget.recommended) _buildRecommendedSection(context, state),

                    // ── Lawyers list with pull-to-refresh ──────────────
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

  // ── Recommended lawyer section ────────────────────────────────────────────
  //
  // loading  → shimmer placeholder (keeps layout stable, no abrupt pop-in)
  // success  → highlighted LawyerCard (isRecommended: true) + header
  // failure  → render nothing. A failure here is typically a 404 ("no
  //            eligible lawyer found"), which is a normal outcome, not a
  //            real error — the regular list below still works on its own.
  // initial  → render nothing.

  Widget _buildRecommendedSection(BuildContext context, ConsultationState state) {
    // ── Loading State ───────────────────────────────────────────────────────
    if (state.recommendedLawyerStatus == ConsultationStatus.loading) {
      final theme = Theme.of(context);
      final base = theme.brightness == Brightness.light
          ? Colors.grey.shade300
          : Colors.grey.shade700;
      final highlight = theme.brightness == Brightness.light
          ? Colors.grey.shade100
          : Colors.grey.shade600;
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
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

    // ── Error State ─────────────────────────────────────────────────────────
    if (state.recommendedLawyerStatus == ConsultationStatus.failure) {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: ErrorStateWidget(
          title: 'تعذر تحميل المحامي المقترح',
          message: state.recommendedLawyerError ?? 'حدث خطأ أثناء الاتصال بالخادم',
          actionLabel: 'إعادة المحاولة',
          onAction: () => context
              .read<ConsultationApplicationCubit>()
              .loadRecommendedLawyer(),
        ),
      );
    }

    // ── Empty State ─────────────────────────────────────────────────────────
    if (state.recommendedLawyerStatus == ConsultationStatus.success &&
        state.recommendedLawyer == null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: const NoDataWidget(
          icon: Icons.person_search_outlined,
          title: 'لا يوجد محامي مقترح حالياً',
          message: 'لم نتمكن من العثور على محامي مناسب لتخصصك في الوقت الحالي',
        ),
      );
    }

    // ── Success with Data ───────────────────────────────────────────────────
    if (state.recommendedLawyerStatus == ConsultationStatus.success &&
        state.recommendedLawyer != null) {
      final lawyer = state.recommendedLawyer!;
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LawyerCard(
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
              statusValue: lawyer.activityStatus,
              isRecommended: true,
              onConsult: () => _onConsult(context, state, lawyer),
              onCardTap: () => Nav.lawyerDetailsScreen(context, Id: lawyer.id),
            ),
            Gap(16.h),
          ],
        ),
      );
    }

    // ── Initial / Default ───────────────────────────────────────────────────
    return const SizedBox.shrink();
  }

  // ── Lawyers list ──────────────────────────────────────────────────────────

  Widget _buildLawyersList(BuildContext context, ConsultationState state) {
    // ── Loading State ───────────────────────────────────────────────────────
    if (state.lawyersStatus == ConsultationStatus.loading) {
      return _buildLawyersShimmer(context);
    }

    // ── Error State ─────────────────────────────────────────────────────────
    if (state.lawyersStatus == ConsultationStatus.failure) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
        children: [
          SizedBox(height: 60.h),
          ErrorStateWidget(
            title: 'تعذر تحميل المحامين',
            message: state.lawyersError ?? 'حدث خطأ أثناء الاتصال بالخادم',
            actionLabel: 'إعادة المحاولة',
            onAction: () => context
                .read<ConsultationApplicationCubit>()
                .loadLawyers(),
          ),
        ],
      );
    }

    // ── Empty State ─────────────────────────────────────────────────────────
    if (state.lawyers.isEmpty &&
        state.lawyersStatus == ConsultationStatus.success) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
        children: [
          SizedBox(height: 80.h),
          const NoDataWidget(
            icon: Icons.person_search_outlined,
            title: 'لا يوجد محامون متاحون',
            message: 'جرّب تغيير معايير البحث أو الفلاتر المستخدمة',
          ),
        ],
      );
    }

    // ── Success with Data ───────────────────────────────────────────────────
    // If widget.recommended is true, show only the recommended lawyer.
    if (widget.recommended) {
      if (state.recommendedLawyerStatus == ConsultationStatus.success &&
          state.recommendedLawyer != null) {
        final lawyers = [state.recommendedLawyer!];
        return _buildLawyersListView(lawyers, state);
      } else {
        // This shouldn't happen if _buildRecommendedSection is shown above,
        // but handle gracefully
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 80.h),
            const NoDataWidget(
              icon: Icons.person_search_outlined,
              title: 'لا يوجد محامي مقترح',
              message: 'لم نتمكن من العثور على محامي مناسب',
            ),
          ],
        );
      }
    }

    // Show all lawyers, excluding the recommended one from the main list
    final recommendedId =
    state.recommendedLawyerStatus == ConsultationStatus.success
        ? state.recommendedLawyer?.id
        : null;
    final lawyers = recommendedId == null
        ? state.lawyers
        : state.lawyers.where((l) => l.id != recommendedId).toList();

    // Double-check empty after filtering
    if (lawyers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          const NoDataWidget(
            icon: Icons.person_search_outlined,
            title: 'لا يوجد محامون إضافيون',
            message: 'المحامي المقترح هو الخيار الوحيد المتاح حالياً',
          ),
        ],
      );
    }

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
          statusValue: lawyer.activityStatus,
          onConsult: () => _onConsult(context, state, lawyer),
          onCardTap: () => Nav.lawyerDetailsScreen(context, Id: lawyer.id),
        );
      },
    );
  }

  // ── Helper: Build lawyers list view ──────────────────────────────────────────
  Widget _buildLawyersListView(List<LawyerDetailModel> lawyers, ConsultationState state) {
    return ListView.separated(
      itemCount: lawyers.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        LawyerDetailModel lawyer = lawyers[index];
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

  // ── Helper: Build loading or empty state for recommended view ──────────────
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
            'لا يوجد محامي مقترح حالياً',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
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
// LawyerCard
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Lawyer status badge
//
// Maps the backend's `activityStatus` enum value to a label + color.
// Only 'available_now' is confirmed from the live API sample — the other
// cases are best-guess placeholders. If your backend uses different values
// (or a different field name on LawyerModel / LawyerDetailModel), update the
// switch below and the `statusValue:` argument passed into LawyerCard.
// Unknown/null values intentionally return null so no misleading badge is
// shown rather than guessing.
// ─────────────────────────────────────────────────────────────────────────────

class LawyerStatusInfo {
  final String label;
  final Color color;

  const LawyerStatusInfo(this.label, this.color);
}

LawyerStatusInfo? resolveLawyerStatus(String? value) {
  switch (value) {
    case 'available_now':
      return const LawyerStatusInfo('متاح الآن', Color(0xFF2E7D32));
    case 'busy':
    case 'in_consultation':
      return const LawyerStatusInfo('مشغول', Color(0xFFE08C00));
    case 'offline':
    case 'unavailable':
    case 'away':
      return const LawyerStatusInfo('غير متصل', Color(0xFF9E9E9E));
    default:
      return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LawyerCard
//
// Single card used for BOTH the recommended lawyer and the regular list.
// Pass isRecommended: true to show the "الأنسب لطلبك" badge — everything
// else about the card stays identical so users recognize the same shape.
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
      // ✅ Fixed: the old `() => onCardTap` never actually invoked the
      // callback — it just returned the function reference, so tapping
      // the card silently did nothing when onCardTap was provided this way.
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
            // ── Recommendation badge ──────────────────────────────────
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
                        'الأنسب لطلبك',
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
                    ),
                    // ── Status dot ───────────────────────────────────
                    // Only rendered when the value maps to a known
                    // status, so an unrecognized/null value never shows
                    // a misleading green "available" dot.
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
                      // ── Status badge ────────────────────────────────
                      // Text label + dot — clearer than a color-only dot,
                      // and never shown for an unrecognized/null status.
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
                _InfoColumn(title: 'سنوات الخبرة', value: experience),
                Container(
                    height: 40.h, width: 1, color: theme.dividerColor),
                _InfoColumn(title: 'التخصص', value: specialization),
                Container(
                    height: 40.h, width: 1, color: theme.dividerColor),
                _InfoColumn(
                  title: 'سعر الإستشارة',
                  // The /recommended endpoint doesn't return a fee, so a
                  // missing/zero price shows a friendly label instead of
                  // a literal "0 ريال".
                  value: hasPrice
                      ? '${price.toStringAsFixed(0)} ريال'
                      : '${context
                      .read<ConsultationApplicationCubit>()
                      .selectedPricing
                      ?.basePrice ?? 0} ريال',
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
              Expanded(
                child: Text(title,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurface)),
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