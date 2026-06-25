// error_widget.dart

import 'package:flutter/material.dart';
import 'package:rasikh/core/widgets/no_data_widget.dart';

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return NoDataWidget(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      color: Colors.red,
    );
  }
}