// ─────────────────────────────────────────────────────────────────────────────
// features/common/app_version/bloc/app_version_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/app_version_model.dart';
import '../repo/app_version_repo.dart';

part 'app_version_state.dart';

/// Checks the installed app version against the backend on startup.
/// Any failure resolves to [AppVersionUpToDate] so the user is never trapped.
class AppVersionCubit extends Cubit<AppVersionState> {
  AppVersionCubit(this._repo) : super(AppVersionInitial());

  final AppVersionRepo _repo;

  Future<void> checkVersion() async {
    if (state is AppVersionChecking) return;
    emit(AppVersionChecking());

    final result = await _repo.checkCurrentVersion();

    result.fold(
      // Never block the user when the check itself fails (offline, 400...).
      (_) => emit(const AppVersionUpToDate(
        info: AppVersionCheck(
          updateRequired: false,
          updateType: AppUpdateType.none,
        ),
      )),
      (info) {
        if (info.isForceUpdate) {
          emit(AppVersionForceUpdate(info: info));
        } else if (info.isOptionalUpdate) {
          emit(AppVersionOptionalUpdate(info: info));
        } else {
          emit(AppVersionUpToDate(info: info));
        }
      },
    );
  }
}
