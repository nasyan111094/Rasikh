// ─────────────────────────────────────────────────────────────────────────────
// features/common/app_version/bloc/app_version_state.dart
// ─────────────────────────────────────────────────────────────────────────────

part of 'app_version_cubit.dart';

sealed class AppVersionState {
  const AppVersionState();
}

final class AppVersionInitial extends AppVersionState {}

final class AppVersionChecking extends AppVersionState {}

final class AppVersionUpToDate extends AppVersionState {
  final AppVersionCheck info;
  const AppVersionUpToDate({required this.info});
}

final class AppVersionOptionalUpdate extends AppVersionState {
  final AppVersionCheck info;
  const AppVersionOptionalUpdate({required this.info});
}

final class AppVersionForceUpdate extends AppVersionState {
  final AppVersionCheck info;
  const AppVersionForceUpdate({required this.info});
}
