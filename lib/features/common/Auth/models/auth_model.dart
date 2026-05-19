// ─────────────────────────────────────────────────────────────────────────────
// shared/auth/model/auth_model.dart
//
// Shared OTP-flow models used by Login AND Register features.
// Both flows (login & register) hit phone-based OTP endpoints and share
// the same response shapes, so we keep them here.
// ─────────────────────────────────────────────────────────────────────────────

// ── OTP Sent Response (shared by register & login) ────────────────────────────

class SharedOtpSentModel {
  final bool success;
  final int statusCode;
  final String message;
  final String phone;
  final bool otpSent;

  const SharedOtpSentModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.phone,
    required this.otpSent,
  });

  factory SharedOtpSentModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SharedOtpSentModel(
      success:    json['success']    as bool?   ?? false,
      statusCode: json['statusCode'] as int?    ?? 0,
      message:    json['message']    as String? ?? '',
      phone:      data['phone']      as String? ?? '',
      otpSent:    data['otpSent']    as bool?   ?? false,
    );
  }
}

// ── Verify OTP Response ───────────────────────────────────────────────────────

class SharedVerifyOtpModel {
  final bool success;
  final int statusCode;
  final String message;
  final String accessToken;
  final SharedLawyerProfileData lawyer;

  const SharedVerifyOtpModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.accessToken,
    required this.lawyer,
  });

  factory SharedVerifyOtpModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SharedVerifyOtpModel(
      success:     json['success']    as bool?   ?? false,
      statusCode:  json['statusCode'] as int?    ?? 0,
      message:     json['message']    as String? ?? '',
      accessToken: data['access_token'] as String? ??
          data['accessToken']           as String? ?? '',
      lawyer: SharedLawyerProfileData.fromJson(
        data['lawyer'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

// ── Lawyer profile snapshot embedded in OTP-verify response ──────────────────

class SharedLawyerProfileData {
  final String id;
  final String phone;
  final bool otpVerified;
  final bool profileCompleted;
  final String status;
  final String accountStatus;
  final bool underReview;
  final String fullName;
  final String email;
  final String licenseNumber;

  const SharedLawyerProfileData({
    required this.id,
    required this.phone,
    required this.otpVerified,
    required this.profileCompleted,
    required this.status,
    required this.accountStatus,
    required this.underReview,
    this.fullName = '',
    this.email = '',
    this.licenseNumber = '',
  });

  factory SharedLawyerProfileData.fromJson(Map<String, dynamic> json) {
    return SharedLawyerProfileData(
      id:               json['id']               as String? ?? '',
      phone:            json['phone']             as String? ?? '',
      otpVerified:      json['otpVerified']       as bool?   ?? false,
      profileCompleted: json['profileCompleted']  as bool?   ?? false,
      status:           json['status']            as String? ?? '',
      accountStatus:    json['accountStatus']     as String? ?? '',
      underReview:      json['underReview']       as bool?   ?? false,
      fullName:         json['fullName']          as String? ?? '',
      email:            json['email']             as String? ?? '',
      licenseNumber:    json['licenseNumber']     as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'otpVerified': otpVerified,
    'profileCompleted': profileCompleted,
    'status': status,
    'accountStatus': accountStatus,
    'underReview': underReview,
    'fullName': fullName,
    'email': email,
    'licenseNumber': licenseNumber,
  };
}

// ── Account type selected on AccountTypeScreen ────────────────────────────────

enum VendorType { user, lawyer, company }