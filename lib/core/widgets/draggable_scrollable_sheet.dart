import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 1,
      minChildSize: 0.4,
      snap: true,
      shouldCloseOnMinExtent: false,
      snapSizes: const [
        0.5,
        0.6,
        0.8,
      ],
      builder: (context, scrollController) {
        return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: child);
      },
    );
  }
}
