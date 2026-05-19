import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/widgets/fields/prefix_text_filed_icon.dart';
import 'package:size_config/size_config.dart';

class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.showHint = false,
    this.autoFocus = false,
    this.isAddPersonPage = false,
    this.focusNode,
    this.confirm,
    this.onValidated,
    this.getChosenPhoneCode,
    this.addPenIcon,
    this.onChange,
    this.initialValue,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<String>? getChosenPhoneCode;
  final String? Function(String?)? onValidated;
  final ValueChanged<String>? onChange;
  final String? initialValue;
  final bool showHint;
  final bool autoFocus;
  final bool isAddPersonPage;
  final bool? addPenIcon;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;

  bool isFocused = false;
  bool hasText = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();

    hasText = widget.controller.text.isNotEmpty;

    _focusNode.addListener(_handleFocus);

    widget.controller.addListener(_handleText);
  }

  void _handleFocus() {
    if (mounted) {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _handleText() {
    if (mounted) {
      setState(() {
        hasText = widget.controller.text.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    widget.controller.removeListener(_handleText);

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderColor = isFocused
        ? colorScheme.primary
        : colorScheme.outline.withOpacity(.25);

    final shadowColor = isFocused
        ? colorScheme.primary.withOpacity(.12)
        : Colors.black.withOpacity(.03);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.h),
        color: Colors.transparent
      ),

      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        autofocus: widget.autoFocus,

        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,

        keyboardType: TextInputType.phone,

        onTapOutside: (_) =>
            FocusScope.of(context).unfocus(),

        onFieldSubmitted: widget.confirm,

        onChanged: widget.onChange,

        textInputAction: widget.confirm == null
            ? TextInputAction.next
            : TextInputAction.done,

        autovalidateMode:
        AutovalidateMode.onUserInteraction,

        autofillHints: const [
          AutofillHints.telephoneNumber,
          AutofillHints.telephoneNumberLocal,
        ],

        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],

        validator: widget.onValidated ?? validate,

        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),

        cursorColor: colorScheme.primary,

        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.w,
          ),





          hintText: '5XXXXXXXX',

          labelText:
          widget.showHint ? 'رقم الجوال' : null,

          floatingLabelBehavior:
          FloatingLabelBehavior.auto,

          hintStyle:
          theme.textTheme.bodyMedium?.copyWith(
            color:
            colorScheme.onSurfaceVariant.withOpacity(.7),
            fontWeight: FontWeight.w500,
          ),

          labelStyle:
          theme.textTheme.bodyMedium?.copyWith(
            color: isFocused
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),

          errorMaxLines: 3,

          errorStyle:
          theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w600,
          ),

          // ─────────────────────────────────────
          // Borders
          // ─────────────────────────────────────

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.h),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.h),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.8,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.h),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1.4,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.h),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2,
            ),
          ),

          // ─────────────────────────────────────
          // Prefix
          // ─────────────────────────────────────

          prefixIcon: Padding(
            padding: EdgeInsetsDirectional.only(
              start: 14.w,
            ),
            child: PrefixTextFiledIcon(
              icon: 'assets/icons/mobile.svg',

              colorBorer: isFocused
                  ? colorScheme.primary.withOpacity(.18)
                  : colorScheme.outline.withOpacity(.15),

              colorIcon: isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),

          // ─────────────────────────────────────
          // Country Code
          // ─────────────────────────────────────

          suffixIcon: Container(
            margin: EdgeInsets.all(8.w),

            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),

            decoration: BoxDecoration(

              borderRadius:
              BorderRadius.circular(14.h),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '+966',
                    style:
                    theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isFocused
                          ? primary
                          : colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ),


                Gap(8.w),

                Container(
                  width: 1,
                  height: 18.h,
                  color: colorScheme.outline
                      .withOpacity(.2),
                ),

                Gap(8.w),
                Text(
                  '🇸🇦',
                  style: TextStyle(
                    fontSize: 18.sp,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الجوال';
    }

    final phone = value.trim();

    final regex = RegExp(
      r'^(5\d{8}|05\d{8})$',
    );

    if (!regex.hasMatch(phone)) {
      return 'رقم الجوال السعودي غير صحيح';
    }

    return null;
  }
}