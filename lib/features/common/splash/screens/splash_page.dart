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
import '../../app_version/bloc/app_version_cubit.dart';
import '../../app_version/widgets/app_update_dialog.dart';

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
  late final AppVersionCubit _appVersionCubit;

  // ── State ──────────────────────────────────────────────────────────────────
  late ThemeData _cachedTheme;

  // Resolved after BlocListener fires
  bool _hasUser = false;
  bool _onBoardingDone = false;
  bool _stateResolved = false; // true once bloc emits success

  // ── Timer ──────────────────────────────────────────────────────────────────
  Timer? _navTimer;
  Timer? _fallbackTimer;
  bool _navigated = false;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();



    _splashBloc = getIt<SplashBloc>();
    _appVersionCubit = getIt<AppVersionCubit>();
    _controller = AnimationController(vsync: this);

    // Hide navigation bar during splash; keep status bar visible
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );

    // Trigger the single check — reads currentToken + onBoardingDone from cache
    _splashBloc.checkUser();

    // Fallback: never trap the user on splash. If the Lottie animation
    // fails to load (missing asset, codec issue), still navigate.
    _fallbackTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && !_navigated) {
        _navigate();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedTheme = Theme.of(context);

  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _fallbackTimer?.cancel();
    _controller.dispose();
    _appVersionCubit.close();

    // Restore full-screen system UI for the rest of the app
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );



    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────



  /// Called once both the animation ends AND the bloc has responded.
  /// Runs the app-version gate first: FORCE blocks, OPTIONAL asks, NONE
  /// (or any check failure) proceeds normally.
  Future<void> _navigate() async {
    if (!mounted || _navigated) return;

    final proceed = await _handleVersionCheck();
    if (!mounted) return;

    if (!proceed) {
      // FORCE update dialog is on screen — stay on splash, never navigate.
      _navTimer?.cancel();
      _fallbackTimer?.cancel();
      return;
    }

    _navigated = true;
    _navTimer?.cancel();
    _fallbackTimer?.cancel();



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

  /// Version gate — returns false only for a FORCE update (stay blocked).
  /// Any failure (offline, timeout, bad response) proceeds normally so the
  /// user is never trapped on splash.
  Future<bool> _handleVersionCheck() async {
    try {
      await _appVersionCubit.checkVersion().timeout(
            const Duration(seconds: 10),
          );
      if (!mounted) return true;

      final state = _appVersionCubit.state;
      if (state is AppVersionForceUpdate) {
        await showForceUpdateDialog(context, state.info);
        return false;
      }
      if (state is AppVersionOptionalUpdate) {
        await showOptionalUpdateDialog(context, state.info);
      }
      return true;
    } catch (_) {
      return true;
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
              errorBuilder: (context, error, stackTrace) {
                // If the animation can't render, don't trap the user —
                // navigate on the next frame.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_stateResolved) {
                    _navigate();
                  } else {
                    _waitForStateAndNavigate();
                  }
                });
                return const SizedBox.shrink();
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