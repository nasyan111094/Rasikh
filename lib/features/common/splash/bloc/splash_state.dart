import 'package:equatable/equatable.dart';

import '../../../../core/utils/loading_state.dart';

class SplashState extends Equatable {
  const SplashState({
    this.hasUser,
    this.isOnBoardingSkipped,
    this.loadingState = const LoadingState(),
    this.error,
  });

  final bool? hasUser;
  final bool? isOnBoardingSkipped;
  final LoadingState loadingState;
  final String? error;

  // ── Convenience getters ───────────────────────────────────────────────────

  bool get isLoading => loadingState.isLoading;
  bool get isSuccess => loadingState.isSuccess;
  bool get isFailure => error != null;

  // ── State transitions ─────────────────────────────────────────────────────

  SplashState asLoading() => copyWith(
    loadingState: const LoadingState.loading(),
    clearError: true,
  );

  SplashState asLoadingSuccess(
      bool hasUser,
      bool isOnBoardSkipped,
      ) =>
      copyWith(
        hasUser: hasUser,
        isOnBoardingSkipped: isOnBoardSkipped,
        loadingState: const LoadingState.success(),
        clearError: true,
      );

  SplashState asLoadingFailed(String error) => copyWith(
    loadingState: const LoadingState.failure(),
    error: error,
  );

  // ── copyWith ──────────────────────────────────────────────────────────────

  SplashState copyWith({
    bool? hasUser,
    bool? isOnBoardingSkipped,
    LoadingState? loadingState,
    String? error,
    bool clearError = false,
  }) {
    return SplashState(
      hasUser: hasUser ?? this.hasUser,
      isOnBoardingSkipped: isOnBoardingSkipped ?? this.isOnBoardingSkipped,
      loadingState: loadingState ?? this.loadingState,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
    hasUser,
    isOnBoardingSkipped,
    loadingState,
    error,
  ];
}



class LoadingState extends Equatable {
  const LoadingState({
    this.isLoading = false,
    this.isSuccess = false,
  });

  const LoadingState.loading()
      : isLoading = true,
        isSuccess = false;

  const LoadingState.success()
      : isLoading = false,
        isSuccess = true;

  const LoadingState.failure()
      : isLoading = false,
        isSuccess = false;

  final bool isLoading;
  final bool isSuccess;

  @override
  List<Object?> get props => [isLoading, isSuccess];
}