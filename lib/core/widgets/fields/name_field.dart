import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/core/widgets/fields/prefix_text_filed_icon.dart';
import 'package:size_config/size_config.dart';

import '../../utils/vaildData/valid_data.dart';

class NameField extends StatefulWidget {
  const NameField({
    super.key,
    required this.controller,
    this.focusNode,
    this.confirm,
    this.onChange,
    this.onValidated,
    this.label,
    this.color,
    this.textAlign,
    this.keyboardType,
    this.maxLines,
    this.suffix,
    this.autoFocus = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<String>? onChange;
  final String? Function(String?)? onValidated;
  final String? label;
  final Color? color;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final int? maxLines;
  final Widget? suffix;
  final bool autoFocus;

  @override
  _NameFieldState createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> {
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

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: widget.confirm,
      textAlign: widget.textAlign ?? TextAlign.start,
      keyboardType: widget.keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: widget.maxLines,
      autofocus: widget.autoFocus,
      textInputAction:
      widget.confirm == null ? TextInputAction.next : TextInputAction.go,
      autofillHints: const [
        AutofillHints.name,
        AutofillHints.middleName,
        AutofillHints.familyName,
        AutofillHints.givenName,
        AutofillHints.nickname,
        AutofillHints.username,
        AutofillHints.newUsername,
      ],
      validator: _validate,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: Loc.userName(),
        hintStyle: theme.inputDecorationTheme.hintStyle ??
            theme.textTheme.bodySmall?.copyWith(
              color: greyIconColors,
            ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.5),
          ),
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
          icon: 'assets/icons/user_outline.svg',

          colorIcon: isFocused ? colorScheme.primary : greyIconColors,
        ),
        labelStyle: theme.textTheme.bodySmall,
        fillColor: Colors.transparent, // شفاف
        filled: true,
      ),
    );
  }

  String? _validate(String? value) {
    if (!validString(value)) {
      return Loc.emptyName();
    }
    if (value == null || value.length < 3) {
      return Loc.invalidName();
    }
    return null;
  }
}
