import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/widgets/fields/email_field.dart';
import 'package:rasikh/core/widgets/fields/name_field.dart';

import 'package:size_config/size_config.dart';
import '../../../../core/widgets/fields/prefix_text_filed_icon.dart';
import '../widgets/header_capsule_appbar_widget.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _city;

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
    r"\s'’\-]+",
  );

  final _nameFormatter = FilteringTextInputFormatter.allow(
    _nameRegex,
  );

  static const Color kGrey60 = Color(0xFF9E9E9E);

  TextStyle _labelStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.6,
      letterSpacing: -0.28,
      color: theme.colorScheme.onBackground.withOpacity(0.7),
      fontSize: 14.sp,
    );
  }

  TextStyle get _labelStarStyle => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    height: 1.6,
    letterSpacing: -0.28,
    color: const Color(0xFF777777),
  );

  TextStyle get _hintStyle => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.24,
    color: kGrey60,
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const HeaderCapsuleAppBar(title: 'تعديل الملف الشخصي'),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(40.h) ,
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 50.h,
                          backgroundColor: const Color(0xFFF3EFE8),
                          backgroundImage:
                          const AssetImage('assets/images/avatar.png'),
                        ),
                        Positioned(
                          bottom: -2.h,
                          right: -2.w,
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB29569),
                              borderRadius: BorderRadius.circular(14.h),
                              border: Border.all(color: Colors.white, width: 2.w),
                            ),
                            child: Icon(Icons.camera_alt_rounded,
                                size: 14.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Name Field
                  _FieldLabel(
                    'الاسم كامل',
                    labelStyle: _labelStyle(context),
                    starStyle: _labelStarStyle,
                    requiredMark: true,
                  ),
                  SizedBox(height: 8.h),

                  NameField(controller: _nameCtrl , ) ,
                  
         

                  SizedBox(height: 30.h),
 
                  // Email Field
                  _FieldLabel(
                    'البريد الإلكتروني',
                    labelStyle: _labelStyle(context),
                    starStyle: _labelStarStyle,
                  ),
                  SizedBox(height: 8.h),
                  EmailField(controller: _emailCtrl),

                  SizedBox(height: 30.h),
                  // City Dropdown
                  _FieldLabel(
                    'اختر المدينة',
                    labelStyle: _labelStyle(context),
                    starStyle: _labelStarStyle,
                    requiredMark: true,
                  ),
                  SizedBox(height: 8.h) ,
                 CityDropdownField(onChanged: (val){},) ,




                SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.h),
                ),
                padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 16.h),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
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
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                    ),
                  );
                  Navigator.of(context).maybePop();
                }
              },
              child: const Text('تحديث البيانات'),
            ),
          ),
        ),
      ),
    );
  }
}

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
            style: starStyle.copyWith(
              color: theme.colorScheme.error,
            ),
          )
        ]
            : const [],
      ),
    );
  }
}



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
  bool isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Focus(
      focusNode: _focusNode,
      child: DropdownButtonFormField<String>(
        value: widget.value,
        isExpanded: true,
        dropdownColor: Theme.of(context).colorScheme.onSecondary,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isFocused
              ? colorScheme.primary.withOpacity(0.8)
              : colorScheme.onSurfaceVariant,
          size: 20.sp,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.sp),
        decoration: InputDecoration(
          hintText: 'اختر المدينة',
          hintStyle: theme.inputDecorationTheme.hintStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15.sp,
              ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error, width: 1.8),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          prefixIcon: PrefixTextFiledIcon(
            icon: 'assets/icons/City.svg',
            colorBorer: isFocused
                ? colorScheme.primary.withOpacity(.6)
                : colorScheme.outline,
            colorIcon:
            isFocused ? colorScheme.primary : colorScheme.onSurface,
          ),
          fillColor: Colors.transparent,
          filled: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 18.h, // 👈 زودناها (كانت 12.h)
          ),
        ),

        items: const [
          DropdownMenuItem(value: 'الرياض', child: Text('الرياض') ),
          DropdownMenuItem(value: 'جدة', child: Text('جدة')),
          DropdownMenuItem(value: 'الدمام', child: Text('الدمام')),
          DropdownMenuItem(value: 'مكة', child: Text('مكة')),
        ],

        onChanged: widget.onChanged,
        validator: widget.validator ??
                (v) => (v == null) ? 'من فضلك اختر المدينة' : null,
      ),
    );
  }
}
