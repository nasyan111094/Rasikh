import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

import '../../../../config/theme/styles_manager.dart';

class CityDropdown extends StatelessWidget {
  final String label;
  final bool requiredMark;
  final String hint;
  final String? value;
  final List<String> cities;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const CityDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.cities,
    required this.onChanged,
    this.requiredMark = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final labelStyle = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.w600,
      color: const Color(0xFF777777),
      fontSize: 13.sp,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🏷️ Label + Required Mark
          Row(
            children: [
              Text(label, style: labelStyle),
              if (requiredMark) SizedBox(width: 4.w),
              if (requiredMark)
                Text(
                  '•',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13.sp,
                    height: 1,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),

          // 📍 Dropdown Field
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF9E9E9E),
              size: 20.w,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: getRegularGray16Style(),
              suffixIcon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: Icon(
                  Icons.location_city_outlined,
                  color: const Color(0xFF9E9E9E),
                  size: 20.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.h)),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            items: cities
                .map(
                  (c) => DropdownMenuItem(
                value: c,
                child: Text(
                  c,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            )
                .toList(),
            onChanged: onChanged,
            validator: validator,
          ),
        ],
      ),
    );
  }
}
