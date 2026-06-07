// ─────────────────────────────────────────────────────────────────────────────
// features/User/application/dialogs/call_summary_dialog.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:size_config/size_config.dart';

/// Shows the call summary dialog and calls [onSubmit] with the typed summary
/// when the user taps "إرسال". Does nothing if the field is empty.
Future<void> showCallSummaryDialog(
    BuildContext context, {
      required void Function(String summary) onSubmit, required Future<Null> Function() onSkip,
    }) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CallSummaryDialog(onSubmit: onSubmit),
  );
}

class _CallSummaryDialog extends StatefulWidget {
  const _CallSummaryDialog({Key? key, required this.onSubmit}) : super(key: key);

  final void Function(String summary) onSubmit;

  @override
  State<_CallSummaryDialog> createState() => _CallSummaryDialogState();
}

class _CallSummaryDialogState extends State<_CallSummaryDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _scaleAnimation;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onSend() {
    final summary = _textController.text.trim();

    if (summary.isEmpty) return;

    if (summary.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب ألا يقل ملخص المكالمة عن 50 حرفاً'),
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    widget.onSubmit(summary);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final direction = Directionality.of(context);

    return Material(
      color: Colors.black.withOpacity(0.25),
      child: SlideTransition(
        position: _offsetAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400.w),
              child: Directionality(
                textDirection: direction,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15.h,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ❌ Close button
                      Align(
                        alignment: direction == TextDirection.rtl
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: cs.onSurface.withOpacity(.6),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),

                      // 🩶 Title
                      Center(
                        child: Text(
                          'ملخص المكالمة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // 📝 Label
                      Text.rich(
                        TextSpan(
                          text: 'اكتب ملخصاً للمكالمة',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style:
                              TextStyle(color: cs.error, fontSize: 14.sp),
                            ),
                          ],
                        ),
                        textAlign: direction == TextDirection.rtl
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                      SizedBox(height: 8.h),

                      // 🧾 TextField
                      TextField(
                        controller: _textController,
                        maxLines: 5,
                        textDirection: direction,
                        decoration: InputDecoration(
                          hintText: 'اكتب هنا ملخص المكالمة...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(.4),
                            fontSize: 13.sp,
                          ),
                          filled: true,
                          fillColor: cs.surfaceVariant.withOpacity(.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.w),
                            borderSide: BorderSide(
                              color: cs.outlineVariant.withOpacity(.4),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.w),
                            borderSide: BorderSide(
                              color: cs.outlineVariant.withOpacity(.4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.w),
                            borderSide: BorderSide(color: cs.primary),
                          ),
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // 🧩 Buttons row
                      Row(
                        children: [
                          // Cancel
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.fromHeight(46.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.h),
                                ),
                                backgroundColor:
                                cs.surfaceVariant.withOpacity(.2),
                                side: BorderSide.none,
                              ),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withOpacity(.6),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          // Send
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onSend,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.fromHeight(46.h),
                                elevation: 0,
                                backgroundColor: const Color(0xFFBFA171),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.h),
                                ),
                              ),
                              child: Text(
                                'إرسال',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
