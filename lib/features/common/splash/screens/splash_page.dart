import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'package:rasikh/config/navigation/nav.dart';
import 'package:rasikh/config/theme/consts.dart';
import 'package:rasikh/core/cache/cache_helper.dart';
import 'package:rasikh/core/get_it_service/get_it_service.dart';

import '../bloc/splash_bloc.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ── Animation ──────────────────────────────────────────────────────────────
  late final AnimationController _controller;

  // ── Bloc ───────────────────────────────────────────────────────────────────
  // Store once; never call getIt inside build/timer callbacks
  late final SplashBloc _splashBloc;

  // ── State ──────────────────────────────────────────────────────────────────
  late ThemeData _cachedTheme;

  // Resolved after BlocListener fires
  bool _hasUser = false;
  bool _onBoardingDone = false;
  bool _stateResolved = false; // true once bloc emits success

  // ── Timer ──────────────────────────────────────────────────────────────────
  Timer? _navTimer;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();



    _splashBloc = getIt<SplashBloc>();
    _controller = AnimationController(vsync: this);

    // Hide navigation bar during splash; keep status bar visible
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );

    // Trigger the single check — reads currentToken + onBoardingDone from cache
    _splashBloc.checkUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedTheme = Theme.of(context);
    _applySystemUi(_cachedTheme);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();

    // Restore full system UI on exit
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _applySystemUi(_cachedTheme);

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _applySystemUi(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: theme.brightness,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  /// Called once both the animation ends AND the bloc has responded.
  void _navigate() {
    if (!mounted) return;

    // Restore full system UI before navigating away
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _applySystemUi(_cachedTheme);

    // Check if user is already logged in
    final currentToken = getIt<CacheHelper>().currentToken;
    if (currentToken != null && currentToken.isNotEmpty) {
      Nav.layout(context);
      return;
    }

    // Check if onboarding is done
    if (getIt<CacheHelper>().onBoardingDone) {
      Nav.account_type_screen(context);
    } else {
      Nav.onBoarding(context);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider<SplashBloc>.value(
      value: _splashBloc,
      child: BlocListener<SplashBloc, SplashState>(

        listenWhen: (prev, curr) =>
        prev.isLoading != curr.isLoading ||
            prev.hasUser != curr.hasUser ||
            prev.isOnBoardingSkipped != curr.isOnBoardingSkipped,
        listener: (_, state) {
          if (state.isLoading) return;

          // Capture resolved values from bloc state
          _hasUser = state.hasUser == true;
          _onBoardingDone = state.isOnBoardingSkipped == true;
          _stateResolved = true;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: SizedBox.fromSize(
            size: size,
            child: Lottie.asset(
              splashScreen,
              fit: BoxFit.cover,
              width: size.width,
              height: size.height,
              controller: _controller,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward();

                // Wait for the animation to finish, then navigate
                _navTimer = Timer(composition.duration, () {
                  if (_stateResolved) {
                    _navigate();
                  } else {
                    // Bloc hasn't responded yet — wait for it with a short poll
                    _waitForStateAndNavigate();
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Fallback: if animation finishes before bloc responds, poll briefly.
  void _waitForStateAndNavigate() {
    const pollInterval = Duration(milliseconds: 100);
    const maxWait = Duration(seconds: 3);
    var elapsed = Duration.zero;

    Timer.periodic(pollInterval, (timer) {
      elapsed += pollInterval;

      if (_stateResolved || elapsed >= maxWait) {
        timer.cancel();
        _navigate();
      }
    });
  }
}