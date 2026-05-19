// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/presentation/screens/lawyer_update_licence_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rasikh/config/app_config.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/widgets/fields/prefix_text_filed_icon.dart';
import 'package:rasikh/core/widgets/general_app_bar.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:rasikh/features/Lawyer/adding_work_appointment/widgets/date_picker_field.dart';
import 'package:rasikh/features/common/account_type_selection/screens/account_type_screen.dart';
import 'package:size_config/size_config.dart';

import '../../../../core/get_it_service/get_it_service.dart';
import '../bloc/Profile_cubit/lawyer_cubit.dart';
import '../bloc/Profile_cubit/lawyer_state.dart';
import '../models/lawyer_profile_model.dart';

class LawyerUpdateLicenceScreen extends StatefulWidget {
  const LawyerUpdateLicenceScreen({super.key});

  @override
  State<LawyerUpdateLicenceScreen> createState() =>
      _LawyerUpdateLicenceScreenState();
}

class _LawyerUpdateLicenceScreenState
    extends State<LawyerUpdateLicenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _licenseController = TextEditingController();
  final _commercialController = TextEditingController();
  DateTime? _expiryDate;

  // ── Locally picked files (override the API url when set) ─────────────────
  File? _licenseImageFile;
  File? _nationalIdDocFile;
  File? _commercialRegDocFile;

  // ── Existing network URLs from API ────────────────────────────────────────
  // These are shown until the user picks a new file OR explicitly removes them.
  String? _existingLicenseUrl;
  String? _existingNationalIdUrl;
  String? _existingCommercialUrl;

  // ── Track which existing URLs the user explicitly cleared ─────────────────
  bool _licenseUrlCleared = false;
  bool _nationalIdUrlCleared = false;
  bool _commercialUrlCleared = false;

  static const Color kGrey60 = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _prefillFromCache();
  }

  void _prefillFromCache() {
    final profile = context.read<LawyerProfileCubit>().cachedProfile;
    if (profile == null) return;

    _idController.text = profile.nationalId ?? '';
    _licenseController.text = profile.license?.number ?? '';
    _commercialController.text = profile.commercialRegistrationNumber ?? '';

    // Load existing document URLs from API
    _existingLicenseUrl = profile.license?.imageUrl;
    _existingNationalIdUrl = profile.nationalIdDocumentUrl;
    _existingCommercialUrl = profile.commercialRegistrationDocumentUrl;

    // Load expiry date if available
    if (profile.license?.expiryDate != null) {
      try {
        _expiryDate = DateTime.parse(profile.license!.expiryDate!);
      } catch (e) {
        // If parsing fails, leave as null
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _licenseController.dispose();
    _commercialController.dispose();
    super.dispose();
  }

  // ── Pick image ────────────────────────────────────────────────────────────

  Future<void> _pickImage({required _DocType type}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    final file = File(picked.path);
    setState(() {
      switch (type) {
        case _DocType.license:
          _licenseImageFile = file;
          _licenseUrlCleared = false; // new file replaces cleared state
        case _DocType.nationalId:
          _nationalIdDocFile = file;
          _nationalIdUrlCleared = false;
        case _DocType.commercial:
          _commercialRegDocFile = file;
          _commercialUrlCleared = false;
      }
    });
  }

  // ── Remove (clears both local file AND hides network image) ───────────────

  void _removeFile(_DocType type) {
    setState(() {
      switch (type) {
        case _DocType.license:
          _licenseImageFile = null;
          _licenseUrlCleared = true;
        case _DocType.nationalId:
          _nationalIdDocFile = null;
          _nationalIdUrlCleared = true;
        case _DocType.commercial:
          _commercialRegDocFile = null;
          _commercialUrlCleared = true;
      }
    });
  }

  // ── Resolve what each card should display ─────────────────────────────────

  /// Returns the local [File] if the user just picked one, otherwise null.
  File? _fileFor(_DocType type) {
    switch (type) {
      case _DocType.license:
        return _licenseImageFile;
      case _DocType.nationalId:
        return _nationalIdDocFile;
      case _DocType.commercial:
        return _commercialRegDocFile;
    }
  }

  /// Returns the API network URL if it exists AND has not been cleared/replaced.
  String? _networkUrlFor(_DocType type) {
    switch (type) {
      case _DocType.license:
        return (_licenseImageFile == null && !_licenseUrlCleared)
            ? _existingLicenseUrl
            : null;
      case _DocType.nationalId:
        return (_nationalIdDocFile == null && !_nationalIdUrlCleared)
            ? _existingNationalIdUrl
            : null;
      case _DocType.commercial:
        return (_commercialRegDocFile == null && !_commercialUrlCleared)
            ? _existingCommercialUrl
            : null;
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Format expiry date to ISO string if selected
    String? expiryDateString;
    if (_expiryDate != null) {
      expiryDateString = _expiryDate!.toIso8601String();
    }

    final request = UpdateLicenceRequest(
      nationalId: _idController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      commercialRegistrationNumber: _commercialController.text.trim(),
      expiryDate: expiryDateString,
    );

    context.read<LawyerProfileCubit>().updateLicence(
      request: request,
      licenseImage: _licenseImageFile,
      nationalIdDocument: _nationalIdDocFile,
      commercialRegistrationDocument: _commercialRegDocFile,
    );
  }

  // ── Styles ────────────────────────────────────────────────────────────────

  TextStyle _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
      );

  TextStyle get _labelStarStyle =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
      );

  TextStyle get _hintStyle => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.24,
    color: kGrey60,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocListener<LawyerProfileCubit, LawyerProfileState>(
      listener: (context, state) {
        if (state is UpdateLicenceSuccess) {
          if (!context.mounted) return;

          /// Clear cached data
          context.read<LawyerProfileCubit>().cachedProfile = null;

          getIt<CacheHelper>().currentToken = "";
           getIt<CacheHelper>().setUserToken("");

        /// Show success toast/snackbar
        ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
        SnackBar(
        content: Text(
        "أصبح حسابك الأن قيد المراجعه",
        style: theme.textTheme.bodyMedium?.copyWith(
        color: cs.onPrimary,
        ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.h),
        ),
        ),
        );

        /// Wait 1 second then navigate
        Future.delayed(const Duration(seconds: 1));

        if (!context.mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
        builder: (_) => const AccountTypeScreen(),
        ),
        (route) => false,
        );
        }

        if (state is UpdateLicenceError) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onError,
                  ),
                ),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.h),
                ),
              ),
            );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: const GeneralAppBar(title: 'تعديل رخصة مزاولة المهنه'),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(30.h),

                    // ── National ID ─────────────────────────────────────────
                    _FieldLabel(
                      'رقم الهوية',
                      requiredMark: true,
                      labelStyle: _labelStyle(context),
                      starStyle: _labelStarStyle,
                    ),
                    Gap(8.h),
                    _buildTextField(
                      controller: _idController,
                      hint: 'أدخل رقم الهوية',
                      icon: 'assets/icons/user_id.svg',
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'من فضلك أدخل رقم الهوية'
                          : null,
                      inputType: TextInputType.number,
                    ),
                    Gap(20.h),

                    // ── License number ──────────────────────────────────────
                    _FieldLabel(
                      'رقم الترخيص',
                      requiredMark: true,
                      labelStyle: _labelStyle(context),
                      starStyle: _labelStarStyle,
                    ),
                    Gap(8.h),
                    _buildTextField(
                      controller: _licenseController,
                      hint: 'أدخل رقم الترخيص',
                      icon: 'assets/icons/user_id.svg',
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'من فضلك أدخل رقم الترخيص'
                          : null,
                      inputType: TextInputType.number,
                    ),
                    Gap(20.h),

                    // ── License expiry date ────────────────────────────────
                    _FieldLabel(
                      'تاريخ انتهاء الرخصة',
                      requiredMark: true,
                      labelStyle: _labelStyle(context),
                      starStyle: _labelStarStyle,
                    ),
                    Gap(8.h),
                    _buildDatePickerField(),
                    Gap(20.h),

                    // ── Commercial reg number ───────────────────────────────
                    _FieldLabel(
                      'رقم السجل التجاري',
                      requiredMark: true,
                      labelStyle: _labelStyle(context),
                      starStyle: _labelStarStyle,
                    ),
                    Gap(8.h),
                    _buildTextField(
                      controller: _commercialController,
                      hint: 'أدخل رقم السجل التجاري',
                      icon: 'assets/icons/City.svg',
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'من فضلك أدخل رقم السجل التجاري'
                          : null,
                      inputType: TextInputType.number,
                    ),
                    Gap(28.h),

                    // ── Upload section label ────────────────────────────────
                    _FieldLabel(
                      'يرجى إرفاق الصور المطلوبة',
                      requiredMark: true,
                      labelStyle: _labelStyle(context),
                      starStyle: _labelStarStyle,
                    ),
                    Gap(8.h),
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• صورة الهوية',
                              style: theme.textTheme.bodyMedium),
                          Text('• صورة الترخيص',
                              style: theme.textTheme.bodyMedium),
                          Text('• صورة السجل التجاري',
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Gap(16.h),

                    // ── Upload cards ────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _UploadCard(
                            label: 'الهوية',
                            localFile: _fileFor(_DocType.nationalId),
                            networkUrl: _networkUrlFor(_DocType.nationalId),
                            onPick: () => _pickImage(type: _DocType.nationalId),
                            onRemove: () => _removeFile(_DocType.nationalId),
                          ),
                        ),
                        Gap(20.w),
                        Expanded(
                          child: _UploadCard(
                            label: 'الترخيص',
                            localFile: _fileFor(_DocType.license),
                            networkUrl: _networkUrlFor(_DocType.license),
                            onPick: () => _pickImage(type: _DocType.license),
                            onRemove: () => _removeFile(_DocType.license),
                          ),
                        ),
                        Gap(20.w),
                        Expanded(
                          child: _UploadCard(
                            label: 'السجل',
                            localFile: _fileFor(_DocType.commercial),
                            networkUrl: _networkUrlFor(_DocType.commercial),
                            onPick: () => _pickImage(type: _DocType.commercial),
                            onRemove: () => _removeFile(_DocType.commercial),
                          ),
                        ),
                      ],
                    ),
                    Gap(30.h),
                  ],
                ),
              ),
            ),
          ),

          // ── Save Button ───────────────────────────────────────────────────
          bottomNavigationBar:
          BlocBuilder<LawyerProfileCubit, LawyerProfileState>(
            buildWhen: (p, c) =>
            c is UpdateLicenceLoading ||
                c is UpdateLicenceSuccess ||
                c is UpdateLicenceError,
            builder: (context, state) {
              final isLoading = state is UpdateLicenceLoading;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w , vertical: 6.h),
                child: AppButton(
                  title: isLoading ? '' : 'حفظ',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String icon,
    required String? Function(String?) validator,
    TextInputType inputType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _hintStyle,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.primary, width: 1.4),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.error, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.error, width: 1.8),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        prefixIcon: PrefixTextFiledIcon(
          icon: icon,
          colorBorer: cs.outline,
          colorIcon: cs.onSurface,
        ),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
      ),
    );
  }

  Widget _buildDatePickerField() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final displayDate = _expiryDate != null
        ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
        : '';

    return DatePickerField(label: "", value: _expiryDate, onSelect:(date)
    {
      if (date != null) {
        setState(() => _expiryDate = date);
      }
    } );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UploadCard
//
// Priority:  localFile  >  networkUrl  >  empty placeholder
//
// Tapping the placeholder OR the "replace" icon → triggers onPick.
// The ✕ button removes whatever is shown and calls onRemove.
// A small "replace" badge appears on existing images so the intent is clear.
// ─────────────────────────────────────────────────────────────────────────────

class _UploadCard extends StatelessWidget {
  final String label;

  /// File the user just picked from gallery — takes priority over [networkUrl].
  final File? localFile;

  /// Existing image URL from the API — shown when [localFile] is null.
  final String? networkUrl;

  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _UploadCard({
    required this.label,
    required this.localFile,
    required this.networkUrl,
    required this.onPick,
    required this.onRemove,
  });

  bool get _hasImage =>
      localFile != null || (networkUrl != null && networkUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Card body ─────────────────────────────────────────────────────
          GestureDetector(
            // Tapping an existing image does nothing; use the replace badge.
            // Tapping an empty card opens the picker.
            onTap: _hasImage ? null : onPick,
            child: Container(
              height: 110.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(
                  color: _hasImage ? cs.primary : theme.dividerColor,
                  width: _hasImage ? 1.5 : 1,
                ),
                color: _hasImage
                    ? cs.primary.withOpacity(0.04)
                    : cs.onPrimary,
              ),
              child: _hasImage
                ? _ImageContent(localFile: localFile, networkUrl: networkUrl)
                : _EmptyContent(label: label, cs: cs, theme: theme),
            ),
          ),

// ── Smart Single Action Button (Add / Update) ──────────────────────────────

          Positioned(
            top: -6.h,
            right: -6.w,

            child: Material(
              color: Colors.transparent,

              child: InkWell(
                borderRadius: BorderRadius.circular(100.h),

                onTap: onPick,

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),

                  padding: EdgeInsets.all(5.w),

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: _hasImage
                        ? cs.primary
                        : cs.surfaceContainerHighest,

                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),

                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                        color: Colors.black.withOpacity(0.12),
                      ),
                    ],
                  ),

                  child: Icon(
                    _hasImage
                        ? Icons.edit_rounded
                        : Icons.add_rounded,

                    color: _hasImage
                        ? Colors.white
                        : cs.primary,

                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image content (local file OR network) ─────────────────────────────────────

class _ImageContent extends StatelessWidget {
  final File? localFile;
  final String? networkUrl;

  const _ImageContent({this.localFile, this.networkUrl});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10.h);

    if (localFile != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          localFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // Validate and construct complete URL if needed
    String? validUrl;
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      if (networkUrl!.startsWith('http://') || networkUrl!.startsWith('https://')) {
        validUrl = networkUrl;
      } else {
        // Relative path - prepend baseImgUrl
        validUrl = AppConfig.baseImgUrl + networkUrl!;
      }
    }

    // If no valid URL, show error
    if (validUrl == null || validUrl.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Container(
        color: cs.errorContainer.withOpacity(0.15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined,
                size: 28.sp,
                color: cs.error.withOpacity(0.6)),
            Gap(4.h),
            Text(
              'لا توجد صورة',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.error.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Network image with loading + error states
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        validUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // ── Loading placeholder ──────────────────────────────────────────
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          final cs = Theme.of(context).colorScheme;
          return Container(
            color: cs.surface,
            child: Center(
              child: SizedBox(
                width: 22.h,
                height: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        // ── Error fallback ───────────────────────────────────────────────
        errorBuilder: (context, error, stackTrace) {
          final cs = Theme.of(context).colorScheme;
          return Container(
            color: cs.errorContainer.withOpacity(0.15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined,
                    size: 28.sp,
                    color: cs.error.withOpacity(0.6)),
                Gap(4.h),
                Text(
                  'تعذّر التحميل',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.error.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Empty placeholder ─────────────────────────────────────────────────────────

class _EmptyContent extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  final ThemeData theme;

  const _EmptyContent({
    required this.label,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 28.sp, color: cs.onSurface.withOpacity(0.4)),
            Gap(6.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Doc type enum ─────────────────────────────────────────────────────────────

enum _DocType { license, nationalId, commercial }

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool requiredMark;
  final TextStyle labelStyle;
  final TextStyle starStyle;

  const _FieldLabel(
      this.text, {
        this.requiredMark = false,
        required this.labelStyle,
        required this.starStyle,
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        text: text,
        style: labelStyle,
        children: requiredMark
            ? [
          TextSpan(
            text: '  *',
            style: starStyle.copyWith(color: theme.colorScheme.error),
          )
        ]
            : const [],
      ),
    );
  }
}