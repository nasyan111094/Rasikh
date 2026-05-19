import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:size_config/size_config.dart';

import '../../utils/vaildData/valid_data.dart';

class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.controller,
    this.onCompleted,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PinCodeTextField(
        appContext: context,
        controller: controller,
        validator: (value) {
          if (validString(value)) {
            if (value!.length < 6) {
              return '';
            }
          }
          return null;
        },
        backgroundColor: Colors.transparent,
        autoDismissKeyboard: true,
        autoFocus: false,
        autoUnfocus: true,
        errorTextSpace: 30.h,
        errorTextDirection: Directionality.of(context),
        autoDisposeControllers: false,
        length: 6,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          fieldHeight: 50.w,
          fieldWidth: 50.w,
          borderWidth: 1,
          activeBorderWidth: 1,
          disabledBorderWidth: 1,
          errorBorderWidth: 1,
          inactiveBorderWidth: 1,
          selectedBorderWidth: 1,
          inactiveColor: Colors.black12,
          activeFillColor: greyD9,
          inactiveFillColor: greyD9,
          selectedFillColor: greyD9,
          activeColor: primary,
          selectedColor: Theme.of(context).primaryColor,
        ),
        keyboardType: TextInputType.number,
        textStyle: TextStyle(
          // fontFamily: kUrbanist,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
        enableActiveFill: true,
        onCompleted: (value) {
          // onCompleted?.call(value);
        },
        onChanged: (value) {},
      ),
    );
  }
}
