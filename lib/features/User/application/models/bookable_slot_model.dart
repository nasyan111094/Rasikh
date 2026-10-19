// ─────────────────────────────────────────────────────────────────────────────
// bookable_slot_model.dart
// Models for the discrete (bookable) slots API response from:
// GET /api/v1/lawyers/{lawyerId}/availability/slots
//
// Actual API response shape:
// {
//   "success": true,
//   "data": {
//     "data": [...]
//   }
// }
//
// All dates are converted from UTC (API) to Local Time immediately
// during parsing, so the rest of the app works with local dates/times.
// ─────────────────────────────────────────────────────────────────────────────

class BookableSlotModel {
  final DateTime startTime;
  final DateTime endTime;
  final int periodCount;
  final int consultationMinutes;

  const BookableSlotModel({
    required this.startTime,
    required this.endTime,
    required this.periodCount,
    required this.consultationMinutes,
  });

  factory BookableSlotModel.fromJson(Map<String, dynamic> json) {
    return BookableSlotModel(
      startTime: DateTime.parse(
        json['startTime'] as String,
      ).toLocal(),
      endTime: DateTime.parse(
        json['endTime'] as String,
      ).toLocal(),
      periodCount: json['periodCount'] as int? ?? 0,
      consultationMinutes: json['consultationMinutes'] as int? ?? 0,
    );
  }

  /// yyyy-MM-dd (Local Date)
  String get dateKey =>
      '${startTime.year}-'
          '${startTime.month.toString().padLeft(2, '0')}-'
          '${startTime.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'periodCount': periodCount,
      'consultationMinutes': consultationMinutes,
    };
  }

  @override
  String toString() {
    return 'BookableSlotModel('
        'startTime: $startTime, '
        'endTime: $endTime, '
        'periodCount: $periodCount, '
        'consultationMinutes: $consultationMinutes'
        ')';
  }
}

class BookableSlotsResponse {
  final List<BookableSlotModel> slots;

  const BookableSlotsResponse({
    required this.slots,
  });

  /// Expected API response:
  ///
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "data": [...]
  ///   }
  /// }
  factory BookableSlotsResponse.fromJson(Map<String, dynamic> json) {
    final dataWrapper =
        json['data'] as Map<String, dynamic>? ?? const {};

    final rawList =
        dataWrapper['data'] as List<dynamic>? ?? const [];

    return BookableSlotsResponse(
      slots: rawList
          .map(
            (e) => BookableSlotModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  /// Groups slots by local date:
  /// Example:
  /// {
  ///   "2026-06-22": [...],
  ///   "2026-06-23": [...]
  /// }
  Map<String, List<BookableSlotModel>> groupByDate() {
    final grouped = <String, List<BookableSlotModel>>{};

    for (final slot in slots) {
      grouped.putIfAbsent(
        slot.dateKey,
            () => <BookableSlotModel>[],
      ).add(slot);
    }

    return grouped;
  }

  Map<String, dynamic> toJson() {
    return {
      'slots': slots.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'BookableSlotsResponse(slots: ${slots.length})';
  }
}