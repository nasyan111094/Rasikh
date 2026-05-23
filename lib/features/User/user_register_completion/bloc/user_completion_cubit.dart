// ─────────────────────────────────────────────────────────────────────────────
// user_completion/bloc/user_completion_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasikh/core/models/user_model.dart';

import '../../../../Shared/models/city_model.dart';
import '../model/user_completion_model.dart';
import '../repo/user_completion_repo.dart';
import 'user_completion_state.dart';

class UserCompletionCubit extends Cubit<UserCompletionState> {
  final UserCompletionRepo _repo;

  UserCompletionCubit(this._repo) : super(const UserCompletionInitial());

  // ── Text controllers ──────────────────────────────────────────────────────
  // Declared here so they survive widget rebuilds; disposed by get_it teardown.
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController    = TextEditingController();

  // ── Internal cache of loaded cities ───────────────────────────────────────
  // Kept so we can re-attach them to ProfileSubmitting / ProfileError states,
  // ensuring the dropdown never empties while a request is in flight.
  List<CityEnumModel> _cachedCities = [];

  // ── City loading ──────────────────────────────────────────────────────────

  Future<void> fetchCities() async {
    emit(const CityLoading());
    final result = await _repo.getCities();
    result.fold(
          (err)    => emit(CityError(err)),
          (cities) {
        _cachedCities = cities;
        emit(CityLoaded(cities));
      },
    );
  }

  // ── Profile submission ────────────────────────────────────────────────────

  /// [cityDisplayValue] is the Arabic display name exactly as returned by
  /// the /enums/cities endpoint (e.g. "الرياض").
  Future<void> completeProfile({required String cityDisplayValue}) async {
    // Keep the cached cities in the state so the dropdown never disappears.
    emit(ProfileSubmitting(cities: _cachedCities));

    final result = await _repo.completeProfile(
      fullName:         fullNameController.text.trim(),
      email:            emailController.text.trim(),
      cityDisplayValue: cityDisplayValue,
    );

    result.fold(
          (err) => emit(ProfileError(message: err, cities: _cachedCities)),
          (profile) => emit(ProfileCompleted(profile)),
    );
  }

  @override
  Future<void> close() {
    // Registered as a singleton — controllers must NOT be disposed here.
    return super.close();
  }
}