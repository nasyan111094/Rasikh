// ─────────────────────────────────────────────────────────────────────────────
// user_completion/bloc/user_completion_cubit.dart
//
// Cubit for the user (non-lawyer) profile-completion flow.
// Wire up your user-specific repo calls and controllers here.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/user_completion_repo.dart';
import 'user_completion_state.dart';

class UserCompletionCubit extends Cubit<UserCompletionState> {
  final UserCompletionRepo _repo;

  UserCompletionCubit(this._repo) : super(const UserCompletionInitial());

  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController    = TextEditingController();

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> completeProfile() async {
    emit(const UserProfileSubmitting());
    final result = await _repo.completeProfile(
      fullName: fullNameController.text.trim(),
      email:    emailController.text.trim(),
    );
    result.fold(
          (err) => emit(UserCompletionError(err)),
          (_)   => emit(const UserProfileCompleted()),
    );
  }

  @override
  Future<void> close() {
    // Singleton – do NOT dispose controllers.
    return super.close();
  }
}