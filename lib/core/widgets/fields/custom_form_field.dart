import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:size_config/size_config.dart';

import '../../utils/widget_utils.dart';

class CustomFormField extends StatefulWidget {
  final FormFieldBuilder builder;
  final String? Function(String?)? validator;

  final String? initial;
  final double marginHeight;
  final double marginWidth;
  final TextAlign errorAlign;

  //0,1,2,3,4,6,8,9,12,16,24 allowed values for elevation 3shanak ya ele nasy
  final double? elevation;

  const CustomFormField({
    super.key,
    required this.validator,
    this.errorAlign = TextAlign.center,
    this.marginHeight = 0.0,
    this.elevation = 0.0,
    this.marginWidth = 0.0,
    this.initial,
    required this.builder,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> with SingleTickerProviderStateMixin {
  // late AnimationController animationController ;
  //  @override
  // void initState() {
  //    animationController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 1),
  //     upperBound: pi * 2,
  //     lowerBound: 0,
  //   );
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     animationController.repeat();
  //   });
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   animationController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      initialValue: widget.initial,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: widget.builder(field),
          ),
          if (field.hasError) SizedBox(height: 15.h),
          if (field.hasError)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 5.h,
              ),
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: red,
                // border: Border.all(color: Colors.red.shade900,width: 1),
                borderRadius: BorderRadius.circular(
                  getLowBorderRadius(),
                ),
                // boxShadow: kElevationToShadow[8],
              ),
              child: Text(
                field.errorText!,
                textAlign: widget.errorAlign,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
