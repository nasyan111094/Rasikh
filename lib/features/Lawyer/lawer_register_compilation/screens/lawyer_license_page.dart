// ─────────────────────────────────────────────────────────────────────────────
// lawyer_completion/pages/lawyer_license_page.dart
//
// Step 2 – Professional License (رخصة مزاولة المهنة)
// UI is 100% identical to Sign_Up_Screen__Professional_License_.png
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';
import 'package:rasikh/core/utils/get_asset_path.dart';
import 'package:rasikh/core/widgets/auth_stepper.dart';
import 'package:rasikh/core/widgets/fields/gender_field.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:rasikh/core/widgets/snack_bar.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/navigation/nav.dart';
import '../cubit/lawyer_registeration_complation_cubit.dart';

class LawyerLicensePage extends StatefulWidget {
  const LawyerLicensePage({super.key});

  @override
  State<LawyerLicensePage> createState() => _LawyerLicensePageState();
}

class _LawyerLicensePageState extends State<LawyerLicensePage> {
  final _formKey = GlobalKey<FormState>();
  late final LawyerCompletionCubit _cubit;
  final _picker = ImagePicker();

  // Documents
  File? _nationalIdFile;
  File? _licenseImageFile;
  File? _commercialRegFile;

  // Always show commercial reg field based on image (visible in screenshot)
  // The checkbox triggers showing/hiding the commercial reg document tile
  bool _isCompany = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LawyerCompletionCubit>();
  }

  Future<File?> _pickImage() async {
    final picked = await _picker.pickImage(
      source:       ImageSource.gallery,
      imageQuality: 80,
    );
    return picked != null ? File(picked.path) : null;
  }

  // ── All document slots (always: ID + License; company: + CommercialReg) ──
  List<_DocSlot> get _docSlots => [
    _DocSlot(
      label:    'صورة الهوية',
      file:     _nationalIdFile,
      onPick:   () async {
        final f = await _pickImage();
        if (f != null) setState(() => _nationalIdFile = f);
      },
      onRemove: () => setState(() => _nationalIdFile = null),
    ),
    _DocSlot(
      label:    'صورة الترخيص',
      file:     _licenseImageFile,
      onPick:   () async {
        final f = await _pickImage();
        if (f != null) setState(() => _licenseImageFile = f);
      },
      onRemove: () => setState(() => _licenseImageFile = null),
    ),
    if (_isCompany)
      _DocSlot(
        label:    'صورة السجل التجاري',
        file:     _commercialRegFile,
        onPick:   () async {
          final f = await _pickImage();
          if (f != null) setState(() => _commercialRegFile = f);
        },
        onRemove: () => setState(() => _commercialRegFile = null),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(16.h),

                // ── Stepper ─────────────────────────────────────────────
                const AuthStepperWidget(totalSteps: 7, activeStep: 5),

                Gap(16.h),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Logo ────────────────────────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: Picture(
                              getAssetIcon("no_bg_logo.svg"),
                              width:  120.w,
                              height: 48.h,
                            ),
                          ),

                          Gap(12.h),

                          Text(
                            "رخصة مزاولة المهنة",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color:      colorScheme.primary,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(4.h),

                          Text(
                            "نحتاج رخصة مزاولة المهنة لتفعيل حسابك بالكامل.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(24.h),

                          // ── رقم الهوية ───────────────────────────────────

                          Gap(6.h),
                          GeneralField(
                            controller:     _cubit.nationalIdController,
                            hintText:       "99384859283",
                            textInputType:  TextInputType.number,
                            iconPath:       "user_id.svg",
                            label:          "رقم الهوية ",
                            isRequired: true ,
                            fieldValidator: (v) =>
                            v!.isEmpty ? "أدخل رقم الهوية" : null,
                          ),

                          Gap(16.h),

                          // ── رقم الترخيص ──────────────────────────────────

                          Gap(6.h),
                          GeneralField(
                            controller:     _cubit.licenseController,
                            hintText:       "LAW-4567",
                            textInputType:  TextInputType.text,
                            iconPath:       "user_id.svg",
                            label:          "رقم الترخيص ",
                            isRequired: true ,
                            fieldValidator: (v) =>
                            v!.isEmpty ? "أدخل رقم الترخيص" : null,
                          ),

                          Gap(16.h),

                          // ── رقم السجل التجاري (always visible like image) ─

                          Gap(6.h),
                          GeneralField(
                            controller:     _cubit.commercialRegController,
                            hintText:       "1092837477384",
                            textInputType:  TextInputType.number,
                            iconPath:       "City.svg",
                            label:          "رقم السجل التجاري ",
                            isRequired: true ,
                            fieldValidator: (_isCompany)
                                ? (v) => v!.isEmpty
                                ? "أدخل رقم السجل التجاري"
                                : null
                                : null,
                          ),

                          Gap(30.h),

                          // ── Company checkbox ─────────────────────────────
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     SizedBox(
                          //       width:  24.w,
                          //       height: 24.w,
                          //       child: Checkbox(
                          //         value:      _isCompany,
                          //         onChanged:  (v) =>
                          //             setState(() => _isCompany = v ?? false),
                          //         activeColor: colorScheme.primary,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(4),
                          //         ),
                          //       ),
                          //     ),
                          //     Gap(10.w) ,
                          //     Text(
                          //       "حساب شركة",
                          //       style: theme.textTheme.bodyMedium,
                          //     ),
                          //
                          //   ],
                          // ),

                          Gap(24.h),

                          // ── Document uploads label ───────────────────────
                          Text(
                            "يرجى إرفاق الصور المطلوبة *",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.right,
                          ),

                          Gap(8.h),

                          // ── Bullet list of required docs ─────────────────
                          ...[
                            "صورة الهوية",
                            "صورة الترخيص",
                            if (_isCompany) "صورة السجل التجاري",
                          ].map(
                                (label) => Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [  Icon(
                                  Icons.circle,
                                  size:  6.sp,
                                  color: colorScheme.primary,
                                ), Gap(6.w),
                                  Text(
                                    label,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(color: theme.hintColor),
                                  ),


                                ],
                              ),
                            ),
                          ),

                          Gap(12.h),

                          // ── Document tiles (horizontal scroll) ───────────
                          DottedBorder(
                            radius: Radius.circular(20.h),
                            borderType: BorderType.RRect,
                            color: borderColor,

                            // 👇 التحكم في شكل الـ dashes
                            dashPattern: [12, 8],
strokeWidth: 2,
                            child: Padding(
                              padding: EdgeInsets.all(10.0.w),
                              child: SizedBox(
                                height: 100.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _docSlots.length,
                                  separatorBuilder: (_, __) => Gap(30.w),
                                  itemBuilder: (context, index) {
                                    return _DocumentTile(
                                      slot: _docSlots[index],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          Gap(32.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Next button (outside scroll) ─────────────────────────
                AppButton(
                  title: "التالي",
                 onPressed: () {
                    if (_nationalIdFile == null) {
                      SnackBarBuilder.showFeedBackMessage(
                        context,
                        'يرجى رفع صورة الهوية',
                        isSuccess: false,
                      );
                      return;
                    }
                    if (_licenseImageFile == null) {
                      SnackBarBuilder.showFeedBackMessage(
                        context,
                        'يرجى رفع صورة رخصة المزاولة',
                        isSuccess: false,
                      );
                      return;
                    }
                    if (_isCompany && _commercialRegFile == null) {
                      SnackBarBuilder.showFeedBackMessage(
                        context,
                        'يرجى رفع صورة السجل التجاري',
                        isSuccess: false,
                      );
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      _cubit.saveLicenseInfo(
                        licenseImage:                   _licenseImageFile,
                        nationalIdDocument:             _nationalIdFile,
                        commercialRegistrationDocument: _commercialRegFile,
                        isCompany:                      _isCompany,
                      );
                      Nav.qualificationsSExperienceScreen(context);
                    }
                  },
                ),

                Gap(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Document slot model ───────────────────────────────────────────────────────

class _DocSlot {
  final String     label;
  final File?      file;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  const _DocSlot({
    required this.label,
    required this.file,
    required this.onPick,
    required this.onRemove,
  });
}

// ── Document tile widget (matches image: document icon card with delete badge) ─

class _DocumentTile extends StatelessWidget {
  final _DocSlot slot;
  const _DocumentTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFile     = slot.file != null;

    return GestureDetector(
      onTap: hasFile ? null : slot.onPick,
      child: SizedBox(
        width: 100.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Main card ─────────────────────────────────────────────────
            Container(
              width:  100.w,
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasFile
                      ? colorScheme.primary.withOpacity(0.5)
                      : colorScheme.outlineVariant,
                ),
                color: hasFile
                    ? colorScheme.primary.withOpacity(0.06)
                    : colorScheme.surfaceContainerLowest,
              ),
              child: hasFile
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  slot.file!,
                  fit: BoxFit.cover,
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Document illustration (matches image)
                 Picture(
                   getAssetImage("docs.png" ) ,
                   fit: BoxFit.cover,

                  ),
                ],
              ),
            ),

            // ── Delete badge ─────────────────────────────────────────────
            Positioned(
              top:   -6,
              right: -6,
              child: GestureDetector(
                onTap: hasFile ? slot.onRemove : slot.onPick,
                child: Container(
                  width:       24.w,
                  height:      24.w,
                  decoration:  BoxDecoration(
                    color: hasFile ? colorScheme.error : colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasFile ? Icons.delete_rounded : Icons.add_rounded,
                    size:  14.sp,
                    color: colorScheme.onPrimary,
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

// ── Field label helper ────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String    label;
  final ThemeData theme;
  const _FieldLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color:      theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.right,
    );
  }
}