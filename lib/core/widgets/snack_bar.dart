import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';

class SnackBarBuilder {
  static showFeedBackMessage(BuildContext context, String message,
      {bool addBehaviour = true, bool isSuccess = true}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                textAlign: TextAlign.start,
                message,
                style: getRegularWhite14Style(),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? primary : Colors.red,
        dismissDirection: DismissDirection.up,
        duration: const Duration(seconds: 1),
        behavior: addBehaviour ? SnackBarBehavior.floating : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
