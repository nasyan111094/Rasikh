import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/styles_manager.dart';

import '../../utils/vaildData/valid_data.dart';

class PersonNoteField extends StatelessWidget {
  const PersonNoteField(
      {super.key,
      required this.controller,
      this.focusNode,
      this.confirm,
      this.onValidated,
      this.label,
      this.color,
      this.textAlign,
      this.keyboardType,
      this.hintText,
      this.maxLines,
      this.onChange});

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<bool>? onValidated;
  final String? label;
  final Color? color;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final int? maxLines;
  final ValueChanged<String>? onChange;
  final String? hintText;

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
      onChanged: onChange,
      textInputAction: confirm == null ? TextInputAction.next : TextInputAction.done,
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
        return null;
      
        // final result = validate(value);
        // onValidated?.call(result == null);
        // return result;
      },
      decoration: InputDecoration(
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.only(
              top: 20,
              right: context.locale.languageCode == 'ar' ? 15 : 0,
              bottom: 20,
              left: context.locale.languageCode == 'en' ? 15 : 0),
          hintText: hintText ?? '${Loc.noteAboutPerson()}\n${Loc.noteAboutPersonExample()}',
          hintStyle: getRegularGrey13Style(),
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
      return Loc.notesValidationMassage();
    }
    return null;
  }
}
