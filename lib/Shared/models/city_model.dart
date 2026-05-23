// ── City enum (GET /api/v1/enums/cities) ──────────────────────────────────────

class CityEnumModel {
  /// Key sent to the backend (e.g. "RIYADH")
  final String key;

  /// Display value shown to the user (e.g. "الرياض")
  final String value;

  const CityEnumModel({required this.key, required this.value});

  factory CityEnumModel.fromJson(Map<String, dynamic> json) {
    return CityEnumModel(
      key:   json['key']   as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  @override
  String toString() => value;
}