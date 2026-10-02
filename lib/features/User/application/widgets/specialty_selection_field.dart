import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/theme/colors.dart';
import 'consultation_flow_widgets.dart';

class SpecialtySelectionField extends StatelessWidget {
  const SpecialtySelectionField({
    super.key,
    required this.label,
    required this.hint,
    required this.onTap,
    this.value,
  });

  final String label;
  final String hint;
  final String? value;
  final VoidCallback? onTap;

  static const Color _textColor = Color(0xFF404040);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null && value!.isNotEmpty;
    final radius = BorderRadius.circular(ConsultationFlowSpacing.radius);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConsultationFieldLabel(label, isRequired: true),
        Gap(ConsultationFlowSpacing.titleToContent),
        InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            height: ConsultationFlowSpacing.buttonHeight,
            padding: EdgeInsetsDirectional.only(start: 12.w, end: 10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: radius,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: hasValue ? 14.sp : 12.sp,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                      color: hasValue ? _textColor : greyIconColors,
                    ),
                  ),
                ),
                Gap(8.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 24.w,
                  color: greyIconColors,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
