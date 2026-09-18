/// Davomat holati.
enum AttendanceStatus {
  present('present', 'Keldi'),
  absent('absent', 'Kelmadi'),
  late('late', 'Kechikdi'),
  excused('excused', 'Sababli');

  const AttendanceStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AttendanceStatus fromApi(String value) => AttendanceStatus.values
      .firstWhere((AttendanceStatus s) => s.apiValue == value,
          orElse: () => AttendanceStatus.absent);
}

/// Bitta darsdagi davomat yozuvi.
class AttendanceModel {
  const AttendanceModel({
    required this.id,
    required this.lessonId,
    required this.subject,
    required this.date,
    required this.status,
    this.note,
  });

  final String id; // UUID
  final String lessonId; // UUID
  final String subject;
  final DateTime date;
  final AttendanceStatus status;
  final String? note;

  /// Davomat foizini hisoblashda "kelgan" deb sanaladimi?
  bool get countsAsAttended =>
      status == AttendanceStatus.present || status == AttendanceStatus.late;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
        id: json['id'] as String,
        lessonId: json['lesson_id'] as String,
        subject: json['subject'] as String,
        date: DateTime.parse(json['date'] as String),
        status: AttendanceStatus.fromApi(json['status'] as String),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'lesson_id': lessonId,
        'subject': subject,
        'date': date.toIso8601String(),
        'status': status.apiValue,
        'note': note,
      };
}
