// ─────────────────────────────────────────────────────────────────────────────
// company_completion/bloc/company_completion_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/company_completion_repo.dart';
import 'company_completion_state.dart';

class CompanyCompletionCubit extends Cubit<CompanyCompletionState> {
  final CompanyCompletionRepo _repo;

  CompanyCompletionCubit(this._repo)
      : super(const CompanyCompletionInitial());

  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController companyNameController        = TextEditingController();
  final TextEditingController commercialRegController      = TextEditingController();
  final TextEditingController emailController              = TextEditingController();
  final TextEditingController representativeNameController = TextEditingController();

  Future<void> completeProfile() async {
    emit(const CompanyProfileSubmitting());
    final result = await _repo.completeProfile(
      companyName:        companyNameController.text.trim(),
      commercialRegNumber: commercialRegController.text.trim(),
      email:              emailController.text.trim(),
      representativeName: representativeNameController.text.trim(),
    );
    result.fold(
          (err) => emit(CompanyCompletionError(err)),
          (_)   => emit(const CompanyProfileCompleted()),
    );
  }

  @override
  Future<void> close() {
    // Singleton – do NOT dispose controllers.
    return super.close();
  }
}