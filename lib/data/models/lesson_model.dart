/// Dars o'tkazilish formati.
enum LessonFormat {
  offline('offline', 'Oflayn'),
  online('online', 'Onlayn');

  const LessonFormat(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static LessonFormat fromApi(String value) => LessonFormat.values.firstWhere(
        (LessonFormat f) => f.apiValue == value,
        orElse: () => LessonFormat.offline,
      );
}

/// Jadvaldagi bitta dars.
class LessonModel {
  const LessonModel({
    required this.id,
    required this.subject,
    required this.teacherName,
    required this.room,
    required this.format,
    required this.startsAt,
    required this.endsAt,
    required this.topic,
  });

  final String id; // UUID
  final String subject;
  final String teacherName;
  final String room;
  final LessonFormat format;
  final DateTime startsAt;
  final DateTime endsAt;
  final String topic;

  /// 1 = Dushanba ... 7 = Yakshanba
  int get weekday => startsAt.weekday;

  Duration get duration => endsAt.difference(startsAt);

  bool get isFinished => DateTime.now().isAfter(endsAt);

  bool get isOngoing {
    final DateTime now = DateTime.now();
    return now.isAfter(startsAt) && now.isBefore(endsAt);
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
        id: json['id'] as String,
        subject: json['subject'] as String,
        teacherName: json['teacher_name'] as String,
        room: json['room'] as String,
        format: LessonFormat.fromApi(json['format'] as String),
        startsAt: DateTime.parse(json['starts_at'] as String),
        endsAt: DateTime.parse(json['ends_at'] as String),
        topic: json['topic'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'subject': subject,
        'teacher_name': teacherName,
        'room': room,
        'format': format.apiValue,
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
        'topic': topic,
      };
}
