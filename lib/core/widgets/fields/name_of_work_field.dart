import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/styles_manager.dart';


import '../../utils/vaildData/valid_data.dart';

class JobField extends StatelessWidget {
  const JobField(
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: confirm,
      textAlign: textAlign ?? TextAlign.start,
      keyboardType: keyboardType,
      onChanged: onChange,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
        final result = validate(value);
        onValidated?.call(result == null);
        return result;
      },
      decoration: InputDecoration(
          labelText: Loc.whatDoYouWork(),
          alignLabelWithHint: true,
          labelStyle: getRegularGrey14Style(),
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
      return Loc.jobValidationMassage();
    }
    return null;
  }
}
