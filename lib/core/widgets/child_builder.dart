import 'package:flutter/material.dart';

class ChildBuilder extends StatelessWidget {
  const ChildBuilder({
    super.key,
    required this.builder,
    required this.child,
  });

  final Widget Function(Widget child) builder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return builder(child);
  }
}
