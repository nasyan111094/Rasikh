// ── City enum (GET /api/v1/enums?type=cities) ────────────────────────────────

class CityEnumModel {
  /// Key sent to the backend (e.g. "RIYADH")
  final String key;

  /// Display value shown to the user (e.g. "الرياض")
  ///
  /// This Arabic label is what the API accepts on create/update and what the
  /// city filter expects (`?city=الرياض`) — NOT the English [key].
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

/// Normalises a lawyer's cities coming from the API.
///
/// Prefers the full `cities` array and falls back to the legacy single `city`
/// string, so profiles created before multi-city support still render.
List<String> parseCities(Map<String, dynamic> json) {
  final raw = json['cities'];
  if (raw is List) {
    final list = raw
        .map((e) => e?.toString() ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (list.isNotEmpty) return list;
  }
  final legacy = json['city']?.toString();
  return (legacy != null && legacy.trim().isNotEmpty) ? [legacy] : const [];
}

/// Cities to display for a lawyer, mirroring the contract:
///
/// ```dart
/// if (cities.isNotEmpty) return cities;
/// final legacy = city?.trim();
/// return (legacy != null && legacy.isNotEmpty) ? [legacy] : [];
/// ```
///
/// `city` only ever holds the FIRST city, so it must never be preferred over
/// `cities` when rendering.
List<String> resolveDisplayCities(List<String> cities, String? city) {
  if (cities.isNotEmpty) return cities;
  final legacy = city?.trim();
  return (legacy != null && legacy.isNotEmpty) ? [legacy] : const [];
}