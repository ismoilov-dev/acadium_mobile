/// Uy vazifasi holati.
enum HomeworkStatus {
  assigned('assigned', 'Berilgan'),
  submitted('submitted', 'Topshirilgan'),
  late('late', 'Kechikkan'),
  reviewed('reviewed', 'Tekshirilgan');

  const HomeworkStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static HomeworkStatus fromApi(String value) =>
      HomeworkStatus.values.firstWhere(
        (HomeworkStatus s) => s.apiValue == value,
        orElse: () => HomeworkStatus.assigned,
      );
}

/// Uy vazifasi.
class HomeworkModel {
  const HomeworkModel({
    required this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.teacherName,
    required this.assignedAt,
    required this.dueAt,
    required this.status,
    required this.maxScore,
    required this.xpReward,
    this.score,
    this.submittedAt,
    this.teacherComment,
    this.attachments = const <String>[],
  });

  final String id; // UUID
  final String subject;
  final String title;
  final String description;
  final String teacherName;
  final DateTime assignedAt;
  final DateTime dueAt;
  final HomeworkStatus status;
  final int maxScore;
  final int xpReward;
  final int? score;
  final DateTime? submittedAt;
  final String? teacherComment;
  final List<String> attachments;

  /// Hali topshirilmagan va muddati o'tib ketganmi?
  bool get isOverdue =>
      status == HomeworkStatus.assigned && DateTime.now().isAfter(dueAt);

  /// Topshirish tugmasi ko'rinadimi?
  bool get canSubmit =>
      status == HomeworkStatus.assigned || status == HomeworkStatus.late;

  /// Ro'yxatda "kutilmoqda" deb sanaladimi?
  bool get isPending =>
      status == HomeworkStatus.assigned || status == HomeworkStatus.late;

  factory HomeworkModel.fromJson(Map<String, dynamic> json) => HomeworkModel(
        id: json['id'] as String,
        subject: json['subject'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        teacherName: json['teacher_name'] as String? ?? '',
        assignedAt: DateTime.parse(json['assigned_at'] as String),
        dueAt: DateTime.parse(json['due_at'] as String),
        status: HomeworkStatus.fromApi(json['status'] as String),
        maxScore: json['max_score'] as int? ?? 100,
        xpReward: json['xp_reward'] as int? ?? 0,
        score: json['score'] as int?,
        submittedAt: json['submitted_at'] == null
            ? null
            : DateTime.parse(json['submitted_at'] as String),
        teacherComment: json['teacher_comment'] as String?,
        attachments: (json['attachments'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'subject': subject,
        'title': title,
        'description': description,
        'teacher_name': teacherName,
        'assigned_at': assignedAt.toIso8601String(),
        'due_at': dueAt.toIso8601String(),
        'status': status.apiValue,
        'max_score': maxScore,
        'xp_reward': xpReward,
        'score': score,
        'submitted_at': submittedAt?.toIso8601String(),
        'teacher_comment': teacherComment,
        'attachments': attachments,
      };

  HomeworkModel copyWith({
    HomeworkStatus? status,
    DateTime? submittedAt,
    int? score,
    String? teacherComment,
  }) =>
      HomeworkModel(
        id: id,
        subject: subject,
        title: title,
        description: description,
        teacherName: teacherName,
        assignedAt: assignedAt,
        dueAt: dueAt,
        status: status ?? this.status,
        maxScore: maxScore,
        xpReward: xpReward,
        score: score ?? this.score,
        submittedAt: submittedAt ?? this.submittedAt,
        teacherComment: teacherComment ?? this.teacherComment,
        attachments: attachments,
      );
}

/// Uy vazifasini topshirish uchun yuboriladigan payload.
/// Real API'da `POST /homeworks/{id}/submit/` body'si shu ko'rinishda bo'ladi.
class HomeworkSubmission {
  const HomeworkSubmission({
    required this.homeworkId,
    required this.text,
    this.fileNames = const <String>[],
  });

  final String homeworkId;
  final String text;
  final List<String> fileNames;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'homework_id': homeworkId,
        'text': text,
        'files': fileNames,
      };
}
