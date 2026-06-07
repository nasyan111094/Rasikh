import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/core/theme/colors.dart';
import 'package:rasikh/core/widgets/general_divider.dart';
import 'package:size_config/size_config.dart';

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onTapArrow;

  final  bool ?  isBack;

  const GeneralAppBar({
    super.key,
    required this.title,
    this.onTapArrow,
 this.isBack =  true ,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      automaticallyImplyLeading: false,

      elevation: 0,
      titleSpacing: 0,
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

             isBack! ? Padding(
                padding:EdgeInsets.all(16.w),
                child: InkWell(
                  onTap: onTapArrow ?? (){Navigator.of(context).pop() ; },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: greyF4,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ) : const SizedBox.shrink(),

              Expanded(
                child: Text(
                  title,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),

              // كبسولة السهم

            ],
          ),
          GeneralDivider() ,
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child:GeneralDivider(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
