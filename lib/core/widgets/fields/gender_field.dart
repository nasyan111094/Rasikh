import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/picture.dart';
import 'package:size_config/size_config.dart';
import '../../utils/get_asset_path.dart';

class GeneralField extends StatelessWidget {
  GeneralField({
    super.key,
    this.isRequired = false,
    required this.hintText,
    required this.textInputType,
    required this.controller,
    this.focusNode,
    this.showPreFixIcon = true,
    this.confirm,
    this.onValidated,
    required this.iconPath,
    required this.label,
    this.enableStatus = true,
    this.fieldValidator,
    this.inputFormatters,
    this.textDirection,
    this.maxLines = 1, // ✅ أضفنا maxLines هنا كـ optional parameter
  });

  final bool isRequired;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<bool>? onValidated;
  final bool? showPreFixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final String hintText;
  final String iconPath;
  final TextInputType textInputType;
  final String label;
  final bool? enableStatus;
  final String? Function(String?)? fieldValidator;
  final int maxLines; // ✅ تعريف maxLines

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // تحسين بسيط
      children: [
        Row(
          children: [
            Text(
              label,
              style: getMediumBlack16Style(),
            ),
            if (isRequired)
              Text(
                "*",
                style: getMeduimRed18Style(),
              ),
          ],
        ),
        Gap(10.h),
        TextFormField(
          controller: controller,
          inputFormatters: inputFormatters,
          enabled: enableStatus,
          focusNode: focusNode,
          maxLines: maxLines, // ✅ تم تفعيل maxLines هنا
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          onFieldSubmitted: confirm,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textDirection: textDirection ?? TextDirection.rtl,
          textAlign: TextAlign.start,
          keyboardType: textInputType,
          textInputAction:
          confirm == null ? TextInputAction.next : TextInputAction.done,
          autofillHints: const [
            AutofillHints.email,
          ],
          validator: fieldValidator,
          decoration: InputDecoration(
            hintTextDirection: textDirection ?? TextDirection.rtl,
            hintText: hintText,
            hintStyle: getRegularGray16Style().copyWith(color: greyIconColors),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: primary.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.h),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: primary.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.h),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: primary.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.h),
              ),
            ),
            labelStyle: getRegularBlack14Style(),
            prefixIcon: showPreFixIcon == false
                ? null
                : Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(

                  horizontal:15.w,
                ),
                child: SizedBox(
                  width: 20.h,
                  height: 20.h,
                  child: Picture(
                    getAssetIcon(iconPath),
                    fit: BoxFit.contain,
                    color: greyIconColors,
                  ),
                ),
              ),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }
}
