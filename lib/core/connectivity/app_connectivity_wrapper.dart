import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/main.dart';

import '../../config/navigation/nav.dart';
import 'cubit/connectivity_cubit.dart';
import 'no_internet_screen.dart';
import 'no_connectivity_screen.dart';

class AppWithOverlay extends StatefulWidget {
  const AppWithOverlay({super.key});

  @override
  State<AppWithOverlay> createState() => _AppWithOverlayState();
}

class _AppWithOverlayState extends State<AppWithOverlay> {
  OverlayEntry? _overlayEntry;
  late StreamSubscription<ConnectionStatus> _subscription;
  String? _currentType;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });

    final cubit = context.read<ConnectivityCubit>();

    _subscription = cubit.stream.listen((state) {
      // بناءً على الحالة من enum
      if (state == ConnectionStatus.connectedWithInternet) {

        _removeOverlay();
      } else if (state == ConnectionStatus.connectedNoInternet) {
        _showOverlay("wifi_off"); // حالة متصل بدون انترنت
      } else if (state == ConnectionStatus.disconnected) {
        _showOverlay("no_internet"); // حالة عدم وجود اتصال
      }
    });
  }

  void _showOverlay(String type) {
    if (_currentType == type) return;

    _removeOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _overlayEntry = OverlayEntry(
        builder: (_) {
          if (type == "wifi_off") {
            return  NoInternetScreen();
          } else {
            return  NoConnectionScreen();
          }
        },
      );

      _currentType = type;
      final overlayState = Nav.mainNavKey.currentState?.overlay;
      if (overlayState != null && _overlayEntry != null) {
        overlayState.insert(_overlayEntry!);
      } else {
        _currentType = null;
      }
    });
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _currentType = null;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const RashikhApp();
  }
}
