// features/Lawyer/availability/data/models/availability_status_model.dart

// ── Enum ──────────────────────────────────────────────────────────────────────

enum LawyerAvailabilityStatus {
  availableNow('available_now'),
  busy('busy'),
  unavailable('unavailable');

  const LawyerAvailabilityStatus(this.value);
  final String value;

  static LawyerAvailabilityStatus fromString(String value) {
    return LawyerAvailabilityStatus.values.firstWhere(
          (e) => e.value == value,
      orElse: () => LawyerAvailabilityStatus.unavailable,
    );
  }
}

// ── Request Model ─────────────────────────────────────────────────────────────

class UpdateAvailabilityRequest {
  final LawyerAvailabilityStatus availability;

  const UpdateAvailabilityRequest({required this.availability});

  Map<String, dynamic> toJson() => {
    'availability': availability.value,
  };
}

// ── Response Model ────────────────────────────────────────────────────────────

class UpdateAvailabilityResponse {
  final bool success;
  final String message;
  final LawyerAvailabilityStatus? availability;

  const UpdateAvailabilityResponse({
    required this.success,
    required this.message,
    this.availability,
  });

  factory UpdateAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    LawyerAvailabilityStatus? status;
    if (data is Map<String, dynamic> && data['availability'] != null) {
      status = LawyerAvailabilityStatus.fromString(
          data['availability'] as String);
    }
    return UpdateAvailabilityResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      availability: status,
    );
  }
}