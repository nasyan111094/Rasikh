import 'package:flutter/material.dart';
import 'package:rasikh/core/theme/sizes.dart';

class TransparentIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const TransparentIconButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary, // Theme color for icon
      ),
      label: Text(
        text,
       style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.primary , fontWeight: FontWeight.w700),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,          // Transparent background
        shadowColor: Colors.transparent,             // No shadow
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
