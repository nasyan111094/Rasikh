import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';


import '../../utils/vaildData/valid_data.dart';

class NationalityField extends StatelessWidget {
  const NationalityField({
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
    this.enableState = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<String>? onChange;
  final ValueChanged<bool>? onValidated;
  final String? label;
  final Color? color;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final int? maxLines;
  final Widget? suffix;
  final bool autoFocus;

  final bool enableState;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: confirm,
      textAlign: textAlign ?? TextAlign.start,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: maxLines,
      onChanged: onChange,
      autofocus: autoFocus,
      textInputAction:
          confirm == null ? TextInputAction.next : TextInputAction.go,
      autofillHints: const [
        AutofillHints.name,
        AutofillHints.middleName,
        AutofillHints.familyName,
        AutofillHints.givenName,
        AutofillHints.nickname,
        AutofillHints.username,
        AutofillHints.newUsername,
      ],
      validator: (value) {
        final result = validate(value);
        onValidated?.call(result == null);
        return result;
      },
      decoration: InputDecoration(
        hintText: Loc.nationality(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primary.withOpacity(0.1),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(
              5,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primary.withOpacity(0.1),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(
              5,
            ),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primary.withOpacity(0.1),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(
              5,
            ),
          ),
        ),
        labelStyle: getRegularBlack14Style(),
        fillColor: Colors.white,
        filled: true,
        enabled: enableState,
      ),
    );
  }

  String? validate(String? value) {
    if (!validString(value)) {
      return Loc.emptyNationality();
    }
    return null;
  }
}
