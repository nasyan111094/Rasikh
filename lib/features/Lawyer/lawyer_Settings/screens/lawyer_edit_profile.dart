// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/profile/presentation/screens/lawyer_edit_profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rasikh/core/widgets/fields/email_field.dart';
import 'package:rasikh/core/widgets/fields/name_field.dart';
import 'package:rasikh/core/widgets/gradiant_button.dart';
import 'package:rasikh/core/widgets/user_selector/general_app_button.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/app_config.dart';
import '../../../../core/widgets/fields/prefix_text_filed_icon.dart';
import '../../../../core/widgets/general_app_bar.dart';

import '../bloc/Profile_cubit/lawyer_cubit.dart';
import '../bloc/Profile_cubit/lawyer_state.dart';
import '../models/lawyer_profile_model.dart';


class LawyerEditProfileScreen extends StatefulWidget {
  const LawyerEditProfileScreen({super.key});

  @override
  State<LawyerEditProfileScreen> createState() =>
      _LawyerEditProfileScreenState();
}

class _LawyerEditProfileScreenState extends State<LawyerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String? _selectedCity;
  File? _pickedPhoto;

  // Regex for Arabic & English names
  static final RegExp _nameRegex = RegExp(
    r"[A-Za-z"
    r"\u0600-\u06FF"
    r"\u0750-\u077F"
    r"\u08A0-\u08FF"
    r"\uFB50-\uFDFF"
    r"\uFE70-\uFEFF"
    r"\u064B-\u0652"
    r"\u0670"
    r"\u0640"
    r"\s''\-]+",
  );

  final _nameFormatter = FilteringTextInputFormatter.allow(_nameRegex);

  @override
  void initState() {
    super.initState();
    _prefillFromCache();
  }

  /// Pre-fill form fields from the cached profile
  void _prefillFromCache() {
    final profile = context.read<LawyerProfileCubit>().cachedProfile;
    if (profile == null) return;
    _nameCtrl.text = profile.fullName;
    _emailCtrl.text = profile.email ?? '';
    _experienceCtrl.text =
    profile.experienceYears != null ? '${profile.experienceYears}' : '';
    _bioCtrl.text = profile.bio ?? '';
    _selectedCity = profile.city;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _experienceCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedPhoto = File(picked.path));
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = UpdateProfileRequest(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      city: _selectedCity,
      bio: _bioCtrl.text.trim(),
      experienceYears: int.tryParse(_experienceCtrl.text.trim()),
    );

    context.read<LawyerProfileCubit>().updateProfile(
      request: request,
      photo: _pickedPhoto,
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onBackground.withOpacity(0.7),
      height: 2.h,
    );
  }

  TextStyle get _labelStarStyle =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 15.sp,
        color: const Color(0xFF777777),
      );

  TextStyle get _hintStyle =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        height: 1.3,
        fontSize: 13.sp,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LawyerProfileCubit, LawyerProfileState>(
      listener: (context, state) {
        // Use WidgetsBinding.instance to schedule the snackbar after the frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          
          if (state is UpdateProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم تحديث البيانات بنجاح',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.h),
                ),
              ),
            );
            Navigator.of(context).maybePop();
          } else if (state is UpdateProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onError,
                  ),
                ),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.h),
                ),
              ),
            );
          }
        });
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: GeneralAppBar(title: 'تعديل الملف الشخصي'),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Gap(16.h),

                  // ── Avatar ───────────────────────────────────────────────
                  Center(
                    child: BlocBuilder<LawyerProfileCubit, LawyerProfileState>(
                      buildWhen: (p, c) =>
                      c is LawyerProfileLoaded ||
                          c is UpdateProfileSuccess,
                      builder: (context, state) {
                        final photoUrl = context
                            .read<LawyerProfileCubit>()
                            .cachedProfile
                            ?.photoUrl;
                        return _AvatarWithOverlay(
                          photoUrl: _pickedPhoto != null ? null : photoUrl,
                          pickedFile: _pickedPhoto,
                          radius: 50.h,
                          onTap: _pickImage,
                        );
                      },
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 12.h),

                            // ── Name ───────────────────────────────────────
                            _FieldLabel(
                              'الاسم كامل',
                              labelStyle: _labelStyle(context),
                              starStyle: _labelStarStyle,
                              requiredMark: true,
                            ),
                            SizedBox(height: 6.h),
                            NameField(controller: _nameCtrl),
                            SizedBox(height: 18.h),

                            // ── Email ──────────────────────────────────────
                            _FieldLabel(
                              'البريد الإلكتروني',
                              labelStyle: _labelStyle(context),
                              starStyle: _labelStarStyle,
                            ),
                            SizedBox(height: 6.h),
                            EmailField(controller: _emailCtrl),
                            SizedBox(height: 18.h),

                            // ── City ───────────────────────────────────────
                            _FieldLabel(
                              'اختر المدينة',
                              labelStyle: _labelStyle(context),
                              starStyle: _labelStarStyle,
                              requiredMark: true,
                            ),
                            SizedBox(height: 6.h),
                            CityDropdownField(
                              value: _selectedCity,
                              onChanged: (val) =>
                                  setState(() => _selectedCity = val),
                            ),
                            SizedBox(height: 18.h),

                            // ── Experience ─────────────────────────────────
                            _FieldLabel(
                              'سنوات الخبرة',
                              labelStyle: _labelStyle(context),
                              starStyle: _labelStarStyle,
                              requiredMark: true,
                            ),
                            SizedBox(height: 6.h),
                            TextFormField(
                              controller: _experienceCtrl,
                              decoration: InputDecoration(
                                hintText: '10 سنوات',
                                hintStyle: _hintStyle,
                                prefixIcon: PrefixTextFiledIcon(
                                  icon: 'assets/icons/experience_years.svg',
                                  colorBorer: theme.colorScheme.outline,
                                  colorIcon: theme.colorScheme.onSurface,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.5)),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.w)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 1.2),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.w)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.error,
                                      width: 1.2),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.w)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 18.h),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'من فضلك أدخل سنوات الخبرة'
                                  : null,
                            ),
                            SizedBox(height: 18.h),

                            // ── Bio ────────────────────────────────────────
                            _FieldLabel(
                              'نبذة عنك',
                              labelStyle: _labelStyle(context),
                              starStyle: _labelStarStyle,
                            ),
                            SizedBox(height: 6.h),
                            TextFormField(
                              controller: _bioCtrl,
                              decoration: InputDecoration(
                                hintText: 'اكتب هنا ...',
                                hintStyle: _hintStyle,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.5)),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.w)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 1.2),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.w)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 18.h),
                              ),
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Save Button ────────────────────────────────────────────────────
          bottomNavigationBar:
          BlocBuilder<LawyerProfileCubit, LawyerProfileState>(
            buildWhen: (p, c) =>
            c is UpdateProfileLoading ||
                c is UpdateProfileSuccess ||
                c is UpdateProfileError,
            builder: (context, state) {
              final isLoading = state is UpdateProfileLoading;
              return Padding(
                padding:  EdgeInsets.symmetric(horizontal:16.w),
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
}

// ── Avatar with overlay for picked file ──────────────────────────────────────

class _AvatarWithOverlay extends StatelessWidget {
  final String? photoUrl;
  final File? pickedFile;
  final double radius;
  final VoidCallback onTap;

  const _AvatarWithOverlay({
    this.photoUrl,
    this.pickedFile,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider image;
    if (pickedFile != null) {
      image = FileImage(pickedFile!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      // Check if URL is complete (starts with http/https)
      if (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://')) {
        image = NetworkImage(photoUrl!);
      } else {
        // Relative path - prepend baseImgUrl
        image = NetworkImage(AppConfig.baseImgUrl + photoUrl!);
      }
    } else {
      image = const AssetImage('assets/images/avatar.png');
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFF3EFE8),
          backgroundImage: image,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 30.h,
              height: 30.h,
              decoration: BoxDecoration(
                color: const Color(0xFFB29569),
                borderRadius: BorderRadius.circular(30.h),
                border: Border.all(color: Colors.white, width: 1.5.w),
              ),
              child: Icon(Icons.camera_alt_rounded,
                  size: 11.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

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

// ── City Dropdown ─────────────────────────────────────────────────────────────

class CityDropdownField extends StatefulWidget {
  final String? value;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const CityDropdownField({
    super.key,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  State<CityDropdownField> createState() => _CityDropdownFieldState();
}

class _CityDropdownFieldState extends State<CityDropdownField> {
  bool _isFocused = false;
  late final FocusNode _focusNode;

  // Mapping between English and Arabic city names
  static const Map<String, String> cityMapping = {
    'RIYADH': 'الرياض',
    'JEDDAH': 'جدة',
    'DAMMAM': 'الدمام',
    'MECCA': 'مكة',
  };

  /// Normalize the value to match dropdown items (Arabic names)
  String? _normalizeValue(String? value) {
    if (value == null) return null;
    
    // If it's already an Arabic city name, return it
    if (cityMapping.values.contains(value)) {
      return value;
    }
    
    // If it's an English city name, convert to Arabic
    return cityMapping[value];
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    // Normalize the value for dropdown matching
    final normalizedValue = _normalizeValue(widget.value);

    return Focus(
      focusNode: _focusNode,
      child: DropdownButtonFormField<String>(
        value: normalizedValue,
        isExpanded: true,
        dropdownColor: theme.colorScheme.surface,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _isFocused ? cs.primary.withOpacity(0.8) : cs.onSurfaceVariant,
          size: 18.sp,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'اختر المدينة',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 14.sp,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: cs.primary, width: 1.2),
            borderRadius: BorderRadius.all(Radius.circular(8.w)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: cs.outline.withOpacity(0.5)),
            borderRadius: BorderRadius.all(Radius.circular(8.w)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: cs.error, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(8.w)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: cs.error, width: 1.8),
            borderRadius: BorderRadius.all(Radius.circular(8.w)),
          ),
          prefixIcon: PrefixTextFiledIcon(
            icon: 'assets/icons/City.svg',
            colorBorer:
            _isFocused ? cs.primary.withOpacity(.6) : cs.outline,
            colorIcon: _isFocused ? cs.primary : cs.onSurface,
          ),
          fillColor: Colors.transparent,
          filled: true,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
        ),
        items: const [
          DropdownMenuItem(value: 'الرياض', child: Text('الرياض')),
          DropdownMenuItem(value: 'جدة', child: Text('جدة')),
          DropdownMenuItem(value: 'الدمام', child: Text('الدمام')),
          DropdownMenuItem(value: 'مكة', child: Text('مكة')),
        ],
        onChanged: widget.onChanged,
        validator:
        widget.validator ?? (v) => (v == null) ? 'من فضلك اختر المدينة' : null,
      ),
    );
  }
}