import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/paramaters/update_profile_parameters.dart';
import '../repo/profile_repo.dart';

class ProfileState {
  final bool loading;
  final UserProfileData? data;
  final String? error;

  const ProfileState({this.loading = false, this.data, this.error});

  ProfileState copyWith({bool? loading, UserProfileData? data, String? error}) {
    return ProfileState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileState());

  final ProfileRepo _repo;

  Future<void> loadProfile() async {
    emit(state.copyWith(loading: true, error: null));
    final res = await _repo.fetchProfile();
    res.fold(
          (l) => emit(state.copyWith(loading: false, error: l)),
          (r) => emit(ProfileState(loading: false, data: r)),
    );
  }

  Future<void> updateProfile(UpdateProfileParam params) async {
    emit(state.copyWith(loading: true, error: null));
    final res = await _repo.updateProfile(params);
    res.fold(
          (l) => emit(state.copyWith(loading: false, error: l)),
          (r) => emit(ProfileState(loading: false, data: r)),
    );
  }
}