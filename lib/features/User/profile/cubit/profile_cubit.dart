import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/user_model.dart';

import '../models/update_profile_parameters.dart';
import '../models/user_model.dart';
import '../repo/profile_repo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ProfileState {
  final bool loading;
  final UserProfileData? data;
  final String? error;
  final bool updateSuccess; // true for one emit after a successful update

  const ProfileState({
    this.loading = false,
    this.data,
    this.error,
    this.updateSuccess = false,
  });

  ProfileState copyWith({
    bool? loading,
    UserProfileData? data,
    String? error,
    bool? updateSuccess,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      error: error,               // null clears the error
      updateSuccess: updateSuccess ?? false, // resets unless explicitly set
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileState());

  final ProfileRepo _repo;

  /// Convenience getter — used by CustomAppBar via getIt<ProfileCubit>().profile
  UserProfileData? get profile => state.data;

  /// Load profile data from the server.
  Future<void> loadProfile() async {
    emit(state.copyWith(loading: true, error: null));
    final res = await _repo.fetchProfile();
    res.fold(
          (error) => emit(state.copyWith(loading: false, error: error)),
          (data)  => emit(ProfileState(loading: false, data: data)),
    );
  }

  /// Update profile — emits updateSuccess=true so screens can react.
  Future<void> updateProfile(UpdateProfileParam params) async {
    emit(state.copyWith(loading: true, error: null));
    final res = await _repo.updateProfile(params);
    res.fold(
          (error) => emit(state.copyWith(loading: false, error: error)),
          (data)  => emit(ProfileState(
        loading: false,
        data: data,
        updateSuccess: true,
      )),
    );
  }
}