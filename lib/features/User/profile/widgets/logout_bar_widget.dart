import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoutBar extends StatelessWidget {
  final VoidCallback? onTap;
  const LogoutBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xFFF54141);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: errorColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: errorColor, width: 1),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/Logout_icon.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(errorColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'تسجيل الخروج',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
