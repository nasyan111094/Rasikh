import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/loading_widget.dart';
import 'package:size_config/size_config.dart';

class GradiantButton extends StatefulWidget {
  final String text;
  final void Function()? onTap;
  final double? height;
  bool isPrimary;
  bool? processing;

  GradiantButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height,
    this.isPrimary = false,
    this.processing = false,
  });

  @override
  State<GradiantButton> createState() => _GradiantButtonState();
}

class _GradiantButtonState extends State<GradiantButton> {
  @override
  Widget build(BuildContext context) {
    return widget.processing == true
        ? Center(child: const /*LoadingWidget()*/ CircularProgressIndicator(color: Colors.white,))
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0 , vertical: 8),
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
                width: double.maxFinite,
                height: widget.height ?? 50.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.h),

                ),
                child: Center(
                  child: Text(
                    widget.text,
                    style: getW700White16Style(),
                  ),
                ),
              ),
          ),
        );
  }
}
