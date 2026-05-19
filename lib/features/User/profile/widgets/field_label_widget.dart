import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  final bool requiredMark;
  const FieldLabel(this.text, {super.key, this.requiredMark = false});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF777777));
    return Row(
      children: [
        Text(text, style: style),
        if (requiredMark) const SizedBox(width: 4),
        if (requiredMark) const Text('•', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
