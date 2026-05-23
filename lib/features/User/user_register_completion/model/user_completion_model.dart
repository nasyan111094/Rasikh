// ─────────────────────────────────────────────────────────────────────────────
// user_completion/model/user_completion_model.dart
// ─────────────────────────────────────────────────────────────────────────────

/// Response model for the PUT /clients/complete-profile endpoint.
///
/// Success shape:
/// ```json
/// {
///   "message": "تم إكمال الملف الشخصي بنجاح",
///   "data": {
///     "userId":           "507f191e810c19729de860ea",
///     "profileCompleted": true,
///     "nextStep":         "find_lawyers"
///   }
/// }
/// ```
class UserProfileModel {
  final String message;
  final String userId;
  final bool   profileCompleted;
  final String nextStep;

  const UserProfileModel({
    required this.message,
    required this.userId,
    required this.profileCompleted,
    required this.nextStep,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return UserProfileModel(
      message:          json['message']           as String? ?? '',
      userId:           data['userId']            as String? ?? '',
      profileCompleted: data['profileCompleted']  as bool?   ?? false,
      nextStep:         data['nextStep']           as String? ?? '',
    );
  }
}