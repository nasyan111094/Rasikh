import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/widgets/fields/prefix_text_filed_icon.dart';
import 'package:size_config/size_config.dart';

import '../../../config/theme/styles_manager.dart';
import '../../utils/vaildData/valid_data.dart';

class EmailField extends StatefulWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.focusNode,
    this.showPreFixIcon = true,
    this.confirm,
    this.onValidated,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<bool>? onValidated;
  final bool? showPreFixIcon;

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  bool isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    // Listen to text changes for real-time validation
    widget.controller.addListener(() {
      widget.onValidated?.call(validate(widget.controller.text) == null);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: widget.confirm,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.emailAddress,
      textInputAction:
          widget.confirm == null ? TextInputAction.next : TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      validator: validate,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'البريد الإلكتروني',
        hintStyle: getRegularGray16Style().copyWith(color: greyIconColors) ??
            theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
        errorMaxLines: 3,
        errorStyle: theme.inputDecorationTheme.errorStyle ??
            theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),

        // ✅ Focused Border
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),

        // ✅ Enabled Border
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),

        // ✅ Error Border
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),

        // ✅ Focused Error Border
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),

        // ✅ Prefix Icon
        prefixIcon: widget.showPreFixIcon == false
            ? null
            : PrefixTextFiledIcon(
                icon: 'assets/icons/email.svg',

                colorIcon: isFocused
                    ? colorScheme.primary
                    : greyIconColors,
              ),

        // ✅ Transparent background
        fillColor: Colors.transparent,
        filled: true,
      ),
    );
  }

  String? validate(String? value) {
    if (!validString(value)) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (value != null && !isValidEmail(value)) {
      return 'الرجاء إدخال بريد إلكتروني صالح';
    }
    return null;
  }

  bool isValidEmail(String value) {
    // Email validation: username@domain.tld
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailPattern).hasMatch(value);
  }
}
