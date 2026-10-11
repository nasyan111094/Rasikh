// ─────────────────────────────────────────────────────────────────────────────
// lawyer_completion/pages/lawyer_specialization_page.dart
//
// Step 4 (final) – Specializations (التخصصات)
//
// مطابقة تماماً لشاشة تعديل التخصصات عبر SpecializationBookingForm المشترك:
//  • تخصص رئيسي واحد فقط (مطلوب)
//  • تخصص فرعي (اختياري — متعدد)
//  • نوع دعوى (اختياري — متعدد)
//  • "إرسال للمراجعة" مفعّل عند اختيار الرئيسي.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/snack_bar.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:rasikh/features/common/Auth/screens/auth_page.dart';
import 'package:size_config/size_config.dart';

import '../../../../Shared/bottom_sheets/terms_conditions_button_sheet.dart';
import '../../../../Shared/widgets/lawyer_specializations_selector.dart';
import '../../../../Shared/widgets/specialization_booking_form.dart';
import '../cubit/lawyer_registeration_complation_cubit.dart';
import '../cubit/lawyer_registeration_complation_state.dart';
import '../models/lawyer_registeration_complation_model.dart'
    show SpecializationModel;

class LawyerSpecializationPage extends StatefulWidget {
  const LawyerSpecializationPage({super.key});

  @override
  State<LawyerSpecializationPage> createState() =>
      _LawyerSpecializationPageState();
}

class _LawyerSpecializationPageState extends State<LawyerSpecializationPage> {
  late final LawyerCompletionCubit _cubit;
  LawyerSpecSelection? _selection;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LawyerCompletionCubit>()..fetchSpecializations();
  }

  List<LawyerSpecMain> _toCatalog(
      List<SpecializationModel> specializations) {
    return specializations.map((s) {
      final subs = s.subSpecializations.map((sub) {
        final lawsuits = sub.lawsuitTypes
            .map((l) => LawyerSpecLawsuit(id: l.id, name: l.name))
            .toList();
        return LawyerSpecSub(
            id: sub.id, name: sub.name, lawsuits: lawsuits);
      }).toList();
      return LawyerSpecMain(id: s.id, name: s.name, subs: subs);
    }).toList();
  }

  Map<String, Set<String>> _lawsuitsBySub(
      List<LawyerSpecMain> catalog, List<String> lawsuitIds) {
    final subOfLawsuit = <String, String>{};
    for (final m in catalog) {
      for (final s in m.subs) {
        for (final l in s.lawsuits) {
          subOfLawsuit[l.id] = s.id;
        }
      }
    }
    final map = <String, Set<String>>{};
    for (final id in lawsuitIds) {
      final subId = subOfLawsuit[id];
      if (subId != null) {
        map.putIfAbsent(subId, () => <String>{}).add(id);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<LawyerCompletionCubit, LawyerCompletionState>(
          listener: (context, state) {
            if (state is LawyerProfileCompleted) {
              _showCongratulationDialog(context);
            } else if (state is LawyerCompletionError) {
              SnackBarBuilder.showFeedBackMessage(
                context,
                state.message,
                isSuccess: false,
              );
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Fixed header ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthStepperWidget(totalSteps: 7, activeStep: 7),
                        Gap(16.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Picture(
                            getAssetIcon("no_bg_logo.svg"),
                            width:  120.w,
                            height: 48.h,
                          ),
                        ),
                        Gap(10.h),
                        Text(
                          "التخصصات",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:      colorScheme.primary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Gap(4.h),
                        Text(
                          "نحتاج التخصصات لتفعيل حسابك بالكامل.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Gap(16.h),
                      ],
                    ),
                  ),

                  // ── Scrollable list ──────────────────────────────────
                  Expanded(
                    child: BlocBuilder<LawyerCompletionCubit,
                        LawyerCompletionState>(
                      builder: (context, state) {
                        if (state is LawyerSpecializationLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                                color: colorScheme.primary),
                          );
                        }
                        if (state is LawyerSpecializationError) {
                          return _ErrorView(
                            message: state.message,
                            onRetry: _cubit.fetchSpecializations,
                          );
                        }
                        if (state is LawyerSpecializationLoaded) {
                          final mains = _toCatalog(state.specializations);
                          if (mains.isEmpty) {
                            return Center(
                              child: Text(
                                'لم يتم العثور على تخصصات متاحة',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: theme.hintColor),
                              ),
                            );
                          }
                          final savedMains =
                              _cubit.formData.mainSpecializationIds;
                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                                20.w, 0, 20.w, 8.h),
                            children: [
                              SpecializationBookingForm(
                                catalog: mains,
                                initialMainId: savedMains.isEmpty
                                    ? null
                                    : savedMains.first,
                                initialSubIds: _cubit
                                    .formData.subSpecializationIds
                                    .toSet(),
                                initialLawsuitsBySub: _lawsuitsBySub(
                                  mains,
                                  _cubit.formData.lawsuitTypeIds,
                                ),
                                onChanged: (sel) =>
                                    setState(() => _selection = sel),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  // ── Fixed footer ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                    child: Column(
                      children: [
                        _SubmitButton(
                          cubit: _cubit,
                          selection: _selection,
                        ),
                        Gap(14.h),
                        Text.rich(
                          TextSpan(
                            text: "من خلال التسجيل، فإنك ",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()..onTap=
                                    ()
                                {
                                  showModalBottomSheet(
                                    context:          context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const TermsBottomSheet(),
                                  );
                                },
                                text: "توافق على شروط الخدمة ",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:      colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                  text: "واتفاقية معالجة البيانات."),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCongratulationDialog(BuildContext context) {
    showDialog(
      context:            context,
      barrierDismissible: false,
      barrierColor:       Colors.black54,
      builder: (ctx) => _CongratulationDialog(
        onDone: () {
          Navigator.of(ctx, rootNavigator: true).pop();
          // Show a snackbar that we're retrying
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("شكرا للك : حسابك قيد المراجعه حاليا"),

              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => AuthPage(),
            ),
                (route) => false,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SubmitButton — "إرسال للمراجعة"
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final LawyerCompletionCubit cubit;
  final LawyerSpecSelection? selection;
  const _SubmitButton({required this.cubit, required this.selection});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return BlocBuilder<LawyerCompletionCubit, LawyerCompletionState>(
      builder: (context, state) {
        final canProceed   = (selection?.isValid ?? false);
        final isSubmitting = state is LawyerProfileSubmitting;

        return SizedBox(
          width:  double.infinity,
          height: 54.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: (canProceed && !isSubmitting)
                  ? LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(0.82)],
                begin:  Alignment.centerRight,
                end:    Alignment.centerLeft,
              )
                  : null,
              color: (!canProceed || isSubmitting)
                  ? cs.outlineVariant.withOpacity(0.3)
                  : null,
            ),
            child: AppButton(
              onPressed: (canProceed && !isSubmitting)
                  ? () {
                cubit.saveSpecializations(
                  mainIds: selection!.mainIds,
                  subIds:  selection!.subIds,
                  lawsuitIds: selection!.lawsuitIds,
                );
                cubit.completeProfile();
              }
                  : null,

              title : "إرسال للمراجعه" ,
              isLoading: isSubmitting,

            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CongratulationDialog — matches Congratulation_TO_USER.png exactly
// ─────────────────────────────────────────────────────────────────────────────

class _CongratulationDialog extends StatefulWidget {
  final VoidCallback onDone;
  const _CongratulationDialog({required this.onDone});

  @override
  State<_CongratulationDialog> createState() => _CongratulationDialogState();
}

class _CongratulationDialogState extends State<_CongratulationDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      backgroundColor: cs.onPrimary,
      insetPadding:    EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with light blue gradient background + gold border
            Container(
              width:      116.w,
              height:     116.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [Color(0xFFB8D8EE), Color(0xFFD6ECF7)],
                ),
                border: Border.all(
                  color: const Color(0xFFB5A47A),
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/avatar.png",
                  fit:          BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person_rounded,
                    size:  56.sp,
                    color: cs.primary,
                  ),
                ),
              ),
            ),

            Gap(24.h),

            Text(
              "عزيزي المحامي، تهانينا 🎉",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color:      cs.primary,
              ),
              textAlign: TextAlign.center,
            ),

            Gap(14.h),

            Text(
              "شكراً لك، لقد استلمنا طلبك وسنقوم بمراجعته في أقرب وقت ممكن.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color:  cs.onSurfaceVariant,
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),

            Gap(30.h),

            SizedBox(
              width:  34.w,
              height: 34.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color:       cs.primary,
              ),
            ),

            Gap(4.h),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorView
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 52.sp, color: cs.error.withOpacity(0.45)),
            Gap(12.h),
            Text(message,
                style:
                theme.textTheme.bodyMedium?.copyWith(color: cs.error),
                textAlign: TextAlign.center),
            Gap(20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:      const Icon(Icons.refresh_rounded),
              label:     const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
