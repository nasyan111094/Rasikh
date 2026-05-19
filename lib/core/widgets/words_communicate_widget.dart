import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:size_config/size_config.dart';



class WordsCommunicateWithWidget extends StatelessWidget {
  const WordsCommunicateWithWidget(
      {super.key, required this.onRemove, required this.word});
  final VoidCallback onRemove;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: const BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Row(
        children: [
          Text(
            word,
            style: getRegularWhite14Style(),
          ),
          Gap(7.w),
          GestureDetector(
            onTap: () {
              onRemove.call();
            },
            child: Text(
              'x',
              style: getRegularWhite14Style(),
            ),
          )
        ],
      ),
    );
  }
}
