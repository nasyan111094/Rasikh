import 'package:flutter/material.dart';
import '../../../../config/theme/colors.dart' as AppColors;

class PrimaryPillButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryPillButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // ← متعرفة في colors.dart
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
