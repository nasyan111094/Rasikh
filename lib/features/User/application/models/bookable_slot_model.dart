// ─────────────────────────────────────────────────────────────────────────────
// bookable_slot_model.dart
// Models for the discrete (bookable) slots API response from:
// GET /api/v1/lawyers/{lawyerId}/availability/slots
//
// Actual API response shape:
// {
//   "success": true,
//   "data": {          ← result.right.data
//     "data": [...]    ← the actual slots list
//   }
// }
// So fromJson receives the outer map and must read json['data']['data'].
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
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      periodCount: json['periodCount'] as int,
      consultationMinutes: json['consultationMinutes'] as int,
    );
  }
}

class BookableSlotsResponse {
  final List<BookableSlotModel> slots;

  const BookableSlotsResponse({required this.slots});

  /// [json] is the full response body (result.right.data).
  /// Shape: { "success": true, "data": { "data": [...slots] } }
  factory BookableSlotsResponse.fromJson(Map<String, dynamic> json) {
    // Unwrap the nested data object first, then get the list inside it.
    final dataWrapper = json['data'] as Map<String, dynamic>? ?? {};
    final rawList = (dataWrapper['data'] as List<dynamic>?) ?? [];

    return BookableSlotsResponse(
      slots: rawList
          .map((e) => BookableSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Group slots by local date string (yyyy-MM-dd)
  Map<String, List<BookableSlotModel>> groupByDate() {
    final grouped = <String, List<BookableSlotModel>>{};
    for (final slot in slots) {
      final local = slot.startTime.toLocal();
      final dateKey =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dateKey, () => []).add(slot);
    }
    return grouped;
  }
}