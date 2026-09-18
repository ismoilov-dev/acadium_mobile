/// Arena topshirig'ining turi. O'qituvchi topshiriq yuklaganda shu turni tanlaydi.
enum ArenaTaskType {
  /// Variantli test — o'quvchi javob belgilaydi, natija avtomatik hisoblanadi.
  quiz('quiz', 'Test'),

  /// Ijodiy topshiriq — matn yoki fayl yuboriladi.
  submission('submission', 'Topshiriq'),

  /// Chellenj — natija avtomatik to'planadi (davomat, vazifalar va h.k.).
  challenge('challenge', 'Chellenj');

  const ArenaTaskType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ArenaTaskType fromApi(String value) => ArenaTaskType.values.firstWhere(
        (ArenaTaskType t) => t.apiValue == value,
        orElse: () => ArenaTaskType.challenge,
      );
}

/// Arena topshirig'ining holati.
enum ArenaTaskStatus {
  available('available', 'Boshlash mumkin'),
  inProgress('in_progress', 'Jarayonda'),
  completed('completed', 'Bajarilgan');

  const ArenaTaskStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ArenaTaskStatus fromApi(String value) =>
      ArenaTaskStatus.values.firstWhere(
        (ArenaTaskStatus s) => s.apiValue == value,
        orElse: () => ArenaTaskStatus.available,
      );
}

/// Testdagi bitta savol.
///
/// DIQQAT: to'g'ri javob bu yerda YO'Q — u serverda qoladi va javoblar
/// `submitArenaQuiz` orqali yuborilib, server tomonida tekshiriladi.
/// Fake rejimda ham xuddi shunday: javob kaliti datasource ichida.
class ArenaQuestion {
  const ArenaQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  final String id; // UUID
  final String text;
  final List<String> options;

  factory ArenaQuestion.fromJson(Map<String, dynamic> json) => ArenaQuestion(
        id: json['id'] as String,
        text: json['text'] as String,
        options: (json['options'] as List<dynamic>)
            .map((dynamic e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'text': text,
        'options': options,
      };
}

/// Arena topshirig'i (o'qituvchi tomonidan yuklanadi).
class ArenaTaskModel {
  const ArenaTaskModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.teacherName,
    required this.subject,
    required this.xpReward,
    required this.status,
    required this.progressCurrent,
    required this.progressTarget,
    required this.createdAt,
    this.deadline,
    this.questions = const <ArenaQuestion>[],
    this.attachments = const <String>[],
    this.earnedXp,
    this.resultComment,
    this.completedAt,
  });

  final String id; // UUID
  final ArenaTaskType type;
  final String title;
  final String description;

  /// Topshiriqni yuklagan o'qituvchi.
  final String teacherName;
  final String subject;
  final int xpReward;
  final ArenaTaskStatus status;
  final int progressCurrent;
  final int progressTarget;

  /// O'qituvchi yuklagan sana.
  final DateTime createdAt;
  final DateTime? deadline;

  /// Faqat `quiz` turi uchun to'ladi.
  final List<ArenaQuestion> questions;
  final List<String> attachments;

  /// Bajarilgandan keyin haqiqatda olingan XP.
  final int? earnedXp;
  final String? resultComment;
  final DateTime? completedAt;

  bool get isCompleted => status == ArenaTaskStatus.completed;

  /// Muddati o'tib ketganmi?
  bool get isExpired =>
      !isCompleted && deadline != null && DateTime.now().isAfter(deadline!);

  /// 0..1 oralig'idagi bajarilish darajasi.
  double get progress => progressTarget == 0
      ? 0
      : (progressCurrent / progressTarget).clamp(0.0, 1.0);

  /// Chellenj to'liq bajarilgan va mukofotni olish mumkinmi?
  bool get canClaim =>
      type == ArenaTaskType.challenge &&
      !isCompleted &&
      progressCurrent >= progressTarget;

  /// O'quvchi hozir bu topshiriqni bajara oladimi?
  bool get canStart {
    if (isCompleted || isExpired) return false;
    switch (type) {
      case ArenaTaskType.quiz:
        return questions.isNotEmpty;
      case ArenaTaskType.submission:
        return true;
      case ArenaTaskType.challenge:
        return canClaim;
    }
  }

  factory ArenaTaskModel.fromJson(Map<String, dynamic> json) => ArenaTaskModel(
        id: json['id'] as String,
        type: ArenaTaskType.fromApi(json['type'] as String? ?? 'challenge'),
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        teacherName: json['teacher_name'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        xpReward: json['xp_reward'] as int? ?? 0,
        status: ArenaTaskStatus.fromApi(json['status'] as String),
        progressCurrent: json['progress_current'] as int? ?? 0,
        progressTarget: json['progress_target'] as int? ?? 1,
        createdAt: DateTime.parse(json['created_at'] as String),
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String),
        questions: (json['questions'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) =>
                ArenaQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        attachments: (json['attachments'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e as String)
            .toList(),
        earnedXp: json['earned_xp'] as int?,
        resultComment: json['result_comment'] as String?,
        completedAt: json['completed_at'] == null
            ? null
            : DateTime.parse(json['completed_at'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type.apiValue,
        'title': title,
        'description': description,
        'teacher_name': teacherName,
        'subject': subject,
        'xp_reward': xpReward,
        'status': status.apiValue,
        'progress_current': progressCurrent,
        'progress_target': progressTarget,
        'created_at': createdAt.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'questions': questions.map((ArenaQuestion q) => q.toJson()).toList(),
        'attachments': attachments,
        'earned_xp': earnedXp,
        'result_comment': resultComment,
        'completed_at': completedAt?.toIso8601String(),
      };
}

/// Topshiriq bajarilgandan keyingi natija.
/// Real API: `POST /arena-tasks/{id}/submit/` javobi.
class ArenaTaskResult {
  const ArenaTaskResult({
    required this.taskId,
    required this.earnedXp,
    required this.totalXp,
    required this.message,
    this.correctCount,
    this.totalQuestions,
    this.newRank,
    this.previousRank,
  });

  final String taskId;

  /// Shu topshiriq uchun berilgan XP.
  final int earnedXp;

  /// Yangilangan jami XP.
  final int totalXp;
  final String message;

  /// Faqat test uchun.
  final int? correctCount;
  final int? totalQuestions;

  /// Reytingdagi yangi va eski o'rin (ko'tarilishni ko'rsatish uchun).
  final int? newRank;
  final int? previousRank;

  bool get movedUp =>
      newRank != null && previousRank != null && newRank! < previousRank!;

  factory ArenaTaskResult.fromJson(Map<String, dynamic> json) =>
      ArenaTaskResult(
        taskId: json['task_id'] as String,
        earnedXp: json['earned_xp'] as int,
        totalXp: json['total_xp'] as int,
        message: json['message'] as String? ?? '',
        correctCount: json['correct_count'] as int?,
        totalQuestions: json['total_questions'] as int?,
        newRank: json['new_rank'] as int?,
        previousRank: json['previous_rank'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'task_id': taskId,
        'earned_xp': earnedXp,
        'total_xp': totalXp,
        'message': message,
        'correct_count': correctCount,
        'total_questions': totalQuestions,
        'new_rank': newRank,
        'previous_rank': previousRank,
      };
}
