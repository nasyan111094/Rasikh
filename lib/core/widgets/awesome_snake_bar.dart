import 'package:flutter/material.dart';
import '../../config/theme/colors.dart';

enum SnackBarType { success, error, info }

void showAwesomeSnackBar(
    BuildContext context, String message, SnackBarType type) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _AwesomeSnackBar(
      message: message,
      type: type,
      onDismiss: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class _AwesomeSnackBar extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final VoidCallback onDismiss;

  const _AwesomeSnackBar({
    Key? key,
    required this.message,
    required this.type,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_AwesomeSnackBar> createState() => _AwesomeSnackBarState();
}

class _AwesomeSnackBarState extends State<_AwesomeSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // Colors and icons by type
  LinearGradient _getGradient() {
    switch (widget.type) {
      case SnackBarType.success:
        return LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SnackBarType.error:
        return LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SnackBarType.info:
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Auto dismiss after 2 sec
    Future.delayed(const Duration(seconds: 2), () async {
      await _controller.reverse();
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: _getGradient(),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(_getIcon(), color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
