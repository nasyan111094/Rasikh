class ScheduledConsultation {
  final String id;
  final String consultationNumber;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMin;

  const ScheduledConsultation({
    required this.id,
    required this.consultationNumber,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.durationMin,
  });

  factory ScheduledConsultation.fromJson(Map<String, dynamic> json) =>
      ScheduledConsultation(
        id: json['id'] as String? ?? '',
        consultationNumber: json['consultationNumber'] as String? ?? '',
        title: json['title'] as String? ?? '',
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        durationMin: json['durationMin'] as int? ?? 0,
      );
}