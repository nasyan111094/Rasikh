import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:size_config/size_config.dart';

class CustomCheckBoxTile extends StatelessWidget {
  const CustomCheckBoxTile(
      {super.key, required this.onChangeValue, required this.value, this.checkBoxColor, required this.text});

  final Function(bool) onChangeValue;
  final bool value;
  final String text;
  final Color? checkBoxColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChangeValue(!value);
      },
      child: Container(
        height: 60.h,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          child: Row(
            children: [
              Text(
                text,
                style: getRegularBlack16Style(),
              ),
              const Spacer(),
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: true,
                  activeColor: checkBoxColor ?? primary,
                  onChanged: (newValue) {
                    onChangeValue(newValue ?? false);
                  },
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return checkBoxColor ?? primary;
                      }
                      return Colors.grey.withOpacity(0.5); // Unselected color
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
