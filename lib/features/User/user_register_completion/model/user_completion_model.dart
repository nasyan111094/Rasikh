class UserCompletionModel {}
// ─────────────────────────────────────────────────────────────────────────────
// user_completion/model/user_completion_model.dart
//
// Add user-specific response models here.
// ─────────────────────────────────────────────────────────────────────────────

class UserProfileModel {
  final bool   success;
  final String message;

  const UserProfileModel({required this.success, required this.message});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      success: json['success'] as bool?   ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}