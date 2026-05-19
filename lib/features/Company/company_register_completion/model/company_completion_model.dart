// ─────────────────────────────────────────────────────────────────────────────
// company_completion/model/company_completion_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class CompanyProfileModel {
  final bool   success;
  final String message;

  const CompanyProfileModel({required this.success, required this.message});

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      success: json['success'] as bool?   ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}