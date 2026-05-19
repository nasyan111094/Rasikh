import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final bool requiredMark;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters; // ✅ جديد

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.requiredMark = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.inputFormatters, // ✅ جديد
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF777777),
                ),
              ),
              if (requiredMark) const SizedBox(width: 4),
              if (requiredMark) const Text('•', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.right,
            inputFormatters: inputFormatters, // ✅ جديد
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: (suffixIcon == null)
                  ? null
                  : const Padding(
                padding: EdgeInsetsDirectional.only(end: 12),
                child: Icon(Icons.person_outline, color: Color(0xFF9E9E9E)),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
