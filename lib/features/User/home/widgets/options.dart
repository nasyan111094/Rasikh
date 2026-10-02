import 'package:flutter/material.dart';
import 'package:rasikh/config/localization/loc_keys.dart';
import 'package:gap/gap.dart';

import '../../../../config/theme/styles_manager.dart';
import '../../../../core/utils/get_asset_path.dart';
import '../../../../core/widgets/picture.dart';
import 'package:size_config/size_config.dart';

class LegalConsultationCard extends StatelessWidget {
  final VoidCallback onPressed;

  const LegalConsultationCard({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final primaryGold = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Colors.white, Color(0xFFFBFAF8)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isRtl ? _chatIcon(primaryGold) : _questionMark(primaryGold, context),
          Gap(isRtl ? 12.w : 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Loc.professionalLegalConsultations(),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryGold,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    height: 1.4,
                  ),
                ),
                Gap(8.h),
                Text(
                  Loc.legalConsultationsBrief(),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7B7B7B),
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
                Gap(12.h),
                _consultButton(primaryGold),
              ],
            ),
          ),

          Gap(isRtl ? 8.w : 12.w),

          isRtl ? _questionMark(primaryGold, context) : _chatIcon(primaryGold),
        ],
      ),
    );
  }

  Widget _consultButton(Color color) {
    return SizedBox(
      height: 40.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Loc.consultNow(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                height: 1.2,
              ),
            ),
            Gap(8.w),
            Icon(Icons.arrow_forward, size: 18.w),
          ],
        ),
      ),
    );
  }

  Widget _questionMark(Color color, BuildContext context) {
    return GestureDetector(
      onTap: () => showServiceDetailsBottomSheet(context),
      child: Container(
        width: 26.w,
        height: 26.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Picture(
          getAssetIcon('Question_Circle.svg'),
          width: 17.w,
          height: 17.w,
          color: color,
        ),
      ),
    );
  }

  Widget _chatIcon(Color color) {
    return Container(
      width: 50.w,
      height: 50.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Picture(
        getAssetIcon('chat.svg'),
        width: 24.w,
        height: 24.w,
      ),
    );
  }

  void showServiceDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [

                      Text(
                        Loc.serviceDetails(),
                        style: getBoldBlack16Style(),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                  ),

                  const SizedBox(height: 30),

                  Container(

                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F4EE),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: const Center(
                        child: Icon(
                          Icons.help_outline_rounded,
                          size: 28,
                          color: Color(0xFFB89A63),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    Loc.professionalLegalConsultations(),
                    textAlign: TextAlign.center,
                    style: getBoldPrimary20Style(),
                  ),

                  const SizedBox(height: 16),

                 Text(
                    Loc.legalConsultationsDescription(),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: getBoldGreyD016Style(),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
