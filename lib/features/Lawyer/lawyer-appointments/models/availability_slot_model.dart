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
      // Server now runs a fixed 15-min session + 5-min gap grid for every
      // slot. These keys are still echoed back today, but we fall back to
      // the fixed grid defaults defensively in case that ever changes.
      sessionDurationMinutes: json['sessionDurationMinutes'] as int? ?? 15,
      gapMinutes: json['gapMinutes'] as int? ?? 5,
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
  final bool repeatsWeekly;

  const SlotRequestModel({
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    this.repeatsWeekly = true,
  });

  // Matches the LAW-10 create/update contract exactly:
  // { daysOfWeek, startTime, endTime, repeatsWeekly }
  // Session duration/gap are fixed server-side (15+5 min grid) and are
  // intentionally NOT part of this payload — the API doesn't accept them.
  Map<String, dynamic> toJson() => {
    'daysOfWeek': daysOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'repeatsWeekly': repeatsWeekly,
  };
}

// ── Generic slot mutation response (create / update) ─────────────────────────

class SlotMutationResponse {
  final bool success;
  final int statusCode;
  final String message;

  /// One id per affected day. Create returns one slot object per day in
  /// `daysOfWeek` (e.g. `data: [{id: ...}]`), so this is always a list —
  /// even when only one day was selected.
  final List<String> slotIds;

  const SlotMutationResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.slotIds,
  });

  /// Convenience accessor for call sites that only need a single id.
  String? get slotId => slotIds.isEmpty ? null : slotIds.first;

  factory SlotMutationResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final ids = <String>[];

    void collectId(dynamic item) {
      if (item is Map<String, dynamic>) {
        final id = item['id'];
        if (id != null) ids.add(id.toString());
      } else if (item is String) {
        ids.add(item);
      }
    }

    // Create responds with a List (one entry per requested day).
    // Defensively also accept a bare Map, in case update ever responds
    // with a single slot object instead of a list.
    if (rawData is List) {
      for (final item in rawData) {
        collectId(item);
      }
    } else if (rawData is Map<String, dynamic>) {
      collectId(rawData);
    }

    return SlotMutationResponse(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      slotIds: ids,
    );
  }
}