import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:size_config/size_config.dart';

import '../../utils/get_asset_path.dart';
import '../../utils/vaildData/valid_data.dart';
import '../picture.dart';

class DateField extends StatelessWidget {
  DateField(
      {super.key,
      required this.controller,
      this.focusNode,
      this.confirm,
      this.onValidated,
      this.onTap,
      this.icon_path});

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<bool>? onValidated;
  final VoidCallback? onTap;

  String? icon_path;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: true,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: confirm,
      style: getBoldBlue12Style(),
      onTap: onTap,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.emailAddress,
      textInputAction:
          confirm == null ? TextInputAction.next : TextInputAction.done,
      autofillHints: const [
        AutofillHints.email,
      ],
      validator: (value) {
        final result = validate(value);
        onValidated?.call(result == null);
        return result;
      },
      decoration: InputDecoration(
        hintText: '00 : 00 ',
        alignLabelWithHint: true,
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorSBTn),
            borderRadius: BorderRadius.all(Radius.circular(12.w))),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: colorSBTn),
          borderRadius: BorderRadius.all(
            Radius.circular(12.w),
          ),
        ),
        labelStyle: getBoldBlue14Style(),
        prefixIcon: Container(
          width: 50.w,
          margin: EdgeInsets.only(
              left: context.locale.languageCode == 'en' ? 0 : 10.w,
              right: context.locale.languageCode == 'en' ? 10.w : 0),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(12.w),
                bottomRight: Radius.circular(12.w)),
            border: const Border(
              left: BorderSide(color: colorSBTn),
            ),
          ),
          child: Picture(
            getAssetIcon(icon_path ?? "calendar.svg"),
            height: 24.h,
            width: 24.w,
          ),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  String? validate(String? value) {
    if (!validString(
      value,
    )) {
      return '';
    }
    if (value != null &&
        !validEmail(
          value,
        )) {
      // return Loc.invalid_email();
      return '';
    }
    return null;
  }
}
