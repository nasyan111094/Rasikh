// ─────────────────────────────────────────────────────────────────────────────
// features/Lawyer/specializations/logic/cubit/specializations_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/get_it_service/get_it_service.dart';

import '../../Repo/lawyer_profile_repo.dart';
import '../../Repo/specializations_repo.dart';
import '../../models/specialization_catalog_model.dart';
import 'specializations_state.dart';

class SpecializationsCubit extends Cubit<SpecializationsState> {
  final SpecializationsRepo _specializationsRepo = getIt<SpecializationsRepo>();
  final LawyerProfileRepo _profileRepo = getIt<LawyerProfileRepo>();

  SpecializationsCubit() : super(SpecializationsInitial());

  List<SpecializationCatalogModel> _catalog = [];
  List<SpecializationCatalogModel> get catalog => _catalog;

  // ── Fetch active catalog ──────────────────────────────────────────────────

  Future<void> loadSpecializations({String? search}) async {
    emit(SpecializationsLoading());

    final result = await _specializationsRepo.getActiveSpecializations(
      page: 1,
      limit: 100,
      search: search,
    );

    result.fold(
          (error) => emit(SpecializationsError(error)),
          (response) {
        _catalog = response.data;
        emit(SpecializationsLoaded(_catalog));
      },
    );
  }

  // ── Save selected specializations ─────────────────────────────────────────
  //
  // Accepts lists so multiple main categories (each with their own subs)
  // can be sent in a single PUT /api/v1/lawyers/update/form call.
  //
  //   mainSpecializationIds  → all selected main IDs   e.g. ["id1", "id2"]
  //   subSpecializationIds   → all selected sub  IDs   e.g. ["id3","id4","id5"]

  Future<void> saveSpecializations({
    required List<String> mainSpecializationIds,
    required List<String> subSpecializationIds,
  }) async {
    emit(SaveSpecializationsLoading());

    final result = await _profileRepo.updateSpecializations(
      mainSpecializationIds: mainSpecializationIds,
      subSpecializationIds: subSpecializationIds,
    );

    result.fold(
          (error) => emit(SaveSpecializationsError(error)),
          (_) => emit(SaveSpecializationsSuccess()),
    );
  }
}