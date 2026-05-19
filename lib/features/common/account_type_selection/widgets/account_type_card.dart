import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

import '../../../../../../core/utils/get_asset_path.dart';
import '../../../../../../core/widgets/picture.dart';
import '../../Auth/models/auth_model.dart';
import '../models/account_type_model.dart';

class AccountTypeCard extends StatelessWidget {
  final AccountTypeModel item;
  final VendorType selectedValue;
  final ValueChanged<VendorType> onChanged;

  const AccountTypeCard({
    super.key,
    required this.item,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isSelected = selectedValue == item.type;

    return GestureDetector(
      onTap: () => onChanged(item.type),
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : theme.dividerColor,
            width: 1.w,
          ),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : theme.dividerColor,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Picture(
                getAssetIcon(item.icon),
                width: 20.w,
                height: 20.h,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    item.subtitle,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Radio<VendorType>(
              value: item.type,
              groupValue: selectedValue,
              activeColor: colorScheme.primary,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}