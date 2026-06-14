// features/Lawyer/lawyer-appointments/data/models/availability_slot_model.dart

// ── Single slot returned inside a day ────────────────────────────────────────

class AvailabilitySlot {
  final String id;
  final String startTime;
  final String endTime;
  final int sessionDurationMinutes;
  final int gapMinutes;
  final bool repeatsWeekly;

  const AvailabilitySlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.sessionDurationMinutes,
    required this.gapMinutes,
    required this.repeatsWeekly,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      sessionDurationMinutes: json['sessionDurationMinutes'] as int,
      gapMinutes: json['gapMinutes'] as int,
      repeatsWeekly: json['repeatsWeekly'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime,
    'endTime': endTime,
    'sessionDurationMinutes': sessionDurationMinutes,
    'gapMinutes': gapMinutes,
    'repeatsWeekly': repeatsWeekly,
  };
}

// ── One day inside the weekly view ────────────────────────────────────────────

class AvailabilityDay {
  final int dayIndex;
  final String date;
  final List<AvailabilitySlot> slots;

  const AvailabilityDay({
    required this.dayIndex,
    required this.date,
    required this.slots,
  });

  factory AvailabilityDay.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'] as List<dynamic>? ?? [];
    return AvailabilityDay(
      dayIndex: json['dayIndex'] as int,
      date: json['date'] as String,
      slots: rawSlots
          .map((s) => AvailabilitySlot.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Full weekly availability response ────────────────────────────────────────

class WeeklyAvailabilityModel {
  final String weekStart;
  final List<AvailabilityDay> days;

  const WeeklyAvailabilityModel({
    required this.weekStart,
    required this.days,
  });

  factory WeeklyAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final rawDays = data['days'] as List<dynamic>;
    return WeeklyAvailabilityModel(
      weekStart: data['weekStart'] as String,
      days: rawDays
          .map((d) => AvailabilityDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Create / Update slot request ─────────────────────────────────────────────

class SlotRequestModel {
  final List<int> daysOfWeek;
  final String startTime;
  final String endTime;
  final int sessionDurationMinutes;
  final int gapMinutes;
  final bool repeatsWeekly;

  const SlotRequestModel({
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.sessionDurationMinutes,
    required this.gapMinutes,
    this.repeatsWeekly = true,
  });

  Map<String, dynamic> toJson() => {
    'daysOfWeek': daysOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'sessionDurationMinutes': sessionDurationMinutes,
    'gapMinutes': gapMinutes,
    'repeatsWeekly': repeatsWeekly,
  };
}

// ── Generic slot mutation response (create / update) ─────────────────────────

class SlotMutationResponse {
  final bool success;
  final int statusCode;
  final String message;
  final String slotId;

  const SlotMutationResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.slotId,
  });

  factory SlotMutationResponse.fromJson(Map<String, dynamic> json) {
    return SlotMutationResponse(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      slotId: (json['data'] as Map<String, dynamic>)['id'] as String,
    );
  }
}