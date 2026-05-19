import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/core/utils/extensions/text_theme_extension.dart';

import '../../utils/vaildData/valid_data.dart';

class SendMassageField extends StatelessWidget {
  const SendMassageField(
      {super.key,
      required this.controller,
      this.focusNode,
      this.confirm,
      this.onValidated,
      this.label,
      this.color,
      this.textAlign,
      this.keyboardType,
      this.maxLines,
      this.autoFocused});

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<bool>? onValidated;
  final String? label;
  final Color? color;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final bool? autoFocused;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: confirm,
      textAlign: textAlign ?? TextAlign.start,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autofocus: autoFocused ?? false,
      textInputAction:
          confirm == null ? TextInputAction.next : TextInputAction.done,
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
          // labelText: label,
          alignLabelWithHint: true,
          labelStyle: context.bodyGreyMedium!,
          hintText: label,
          hintStyle: context.bodyGreyMedium!,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade100),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade100),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          fillColor: Colors.white),
    );
  }

  String? validate(String? value) {
    if (!validString(value)) {
      if (value!.isEmpty) {
        return Loc.messageIsEmpty();
      }
    }
    return null;
  }
}
