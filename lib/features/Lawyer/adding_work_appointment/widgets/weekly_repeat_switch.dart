

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

class WeeklyRepeatSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const WeeklyRepeatSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("تكرار أسبوعي ؟",
            style: TextStyle(fontSize: 18.
            sp, fontWeight: FontWeight.w500)),
        Switch(
          value: value,
          inactiveTrackColor: Colors.transparent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
