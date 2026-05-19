import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:rasikh/config/theme/styles_manager.dart';

import '../../utils/vaildData/valid_data.dart';

class PlaceOfBirthField extends StatelessWidget {
  const PlaceOfBirthField({
    super.key,
    required this.controller,
    this.focusNode,
    this.confirm,
    this.onValidated,
    this.label,
    this.color,
    this.textAlign,
    this.keyboardType,
    this.maxLines,
    this.readOnly = true,
    required this.onClicked,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<bool>? onValidated;
  final String? label;
  final Color? color;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final int? maxLines;
  final VoidCallback onClicked;
  final bool readOnly;
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTap: () {
        onClicked.call();
      },
      readOnly: readOnly,
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
          hintStyle:  const TextStyle(color: Color(0xFF808080)),
          labelText: Loc.placeOfBirth(),
          alignLabelWithHint: true,
          labelStyle: getRegularGrey14Style(),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                onClicked.call();
              },
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
              ),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade100),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade100),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          fillColor: Colors.white),
    );
  }

  String? validate(String? value) {
    if (!validString(value)) {
      // return Loc.placeOfBirthValidateMassage();
    }
    return null;
  }
}
