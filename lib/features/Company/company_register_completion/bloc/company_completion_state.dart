// ─────────────────────────────────────────────────────────────────────────────
// company_completion/bloc/company_completion_state.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

abstract class CompanyCompletionState extends Equatable {
  const CompanyCompletionState();
  @override
  List<Object?> get props => [];
}

class CompanyCompletionInitial extends CompanyCompletionState {
  const CompanyCompletionInitial();
}

class CompanyProfileSubmitting extends CompanyCompletionState {
  const CompanyProfileSubmitting();
}

class CompanyProfileCompleted extends CompanyCompletionState {
  const CompanyProfileCompleted();
}

class CompanyCompletionError extends CompanyCompletionState {
  final String message;
  const CompanyCompletionError(this.message);
  @override
  List<Object?> get props => [message];
}