import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/arena_task_model.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/homework_model.dart';
import '../models/lesson_model.dart';
import '../models/notification_model.dart';
import '../models/student_model.dart';
import '../models/xp_model.dart';
import 'mock/mock_data.dart';
import 'mock/mock_state.dart';
import 'student_datasource.dart';

/// [StudentDatasource]ning FAKE implementatsiyasi.
///
/// Har bir metod:
///  1. [ApiClient] orqali so'rovni "yuboradi" (Authorization + X-Device-Id
///     header'lari yig'iladi va log qilinadi, tarmoq kechikishi simulyatsiya
///     qilinadi);
///  2. mock JSON'ni model'ga aylantirib qaytaradi.
///
/// O'zgaruvchan ma'lumot (topshirilgan vazifalar, yig'ilgan XP, reyting)
/// [MockState] ichida saqlanadi — u "fake server bazasi" vazifasini bajaradi.
class FakeStudentDatasource implements StudentDatasource {
  FakeStudentDatasource(this._api);

  final ApiClient _api;

  MockState get _db => MockState.instance;

  // --------------------------------------------------------------- Profil

  @override
  Future<StudentModel> getProfile(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/');

    // Jami XP o'zgarib turadi, shuning uchun uni bazadan olamiz.
    final Map<String, dynamic> json = MockData.student();
    json['total_xp'] = _db.totalXp;
    return StudentModel.fromJson(json);
  }

  // --------------------------------------------------------------- Jadval

  @override
  Future<List<LessonModel>> getSchedule(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/schedule/');
    return MockData.lessons()
        .map((Map<String, dynamic> json) => LessonModel.fromJson(json))
        .toList();
  }

  // -------------------------------------------------------------- Davomat

  @override
  Future<List<AttendanceModel>> getAttendance(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/attendance/');
    return MockData.attendance()
        .map((Map<String, dynamic> json) => AttendanceModel.fromJson(json))
        .toList();
  }

  // --------------------------------------------------------- Uy vazifalari

  @override
  Future<List<HomeworkModel>> getHomework(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/homeworks/');
    final List<HomeworkModel> items = _db.homework
        .map((Map<String, dynamic> json) => HomeworkModel.fromJson(json))
        .toList();
    // Eng yangi muddat birinchi bo'lsin.
    items
        .sort((HomeworkModel a, HomeworkModel b) => b.dueAt.compareTo(a.dueAt));
    return items;
  }

  @override
  Future<HomeworkModel> getHomeworkDetail(String homeworkId) async {
    await _api.send(method: 'GET', path: '/homeworks/$homeworkId/');
    return HomeworkModel.fromJson(_requireHomework(homeworkId));
  }

  @override
  Future<HomeworkModel> submitHomework(HomeworkSubmission submission) async {
    await _api.send(
      method: 'POST',
      path: '/homeworks/${submission.homeworkId}/submit/',
      body: submission.toJson(),
    );

    final Map<String, dynamic> json = _requireHomework(submission.homeworkId);

    if (submission.text.trim().isEmpty && submission.fileNames.isEmpty) {
      throw const ValidationException(
        'Javob matnini yozing yoki fayl biriktiring.',
      );
    }

    // Serverda bo'ladigan o'zgarishni xotirada takrorlaymiz.
    final DateTime now = DateTime.now();
    final bool isLate = DateTime.parse(json['due_at'] as String).isBefore(now);
    json['status'] = isLate ? 'late' : 'submitted';
    json['submitted_at'] = now.toIso8601String();

    return HomeworkModel.fromJson(json);
  }

  // --------------------------------------------------------------- Baholar

  @override
  Future<List<GradeModel>> getGrades(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/grades/');
    final List<GradeModel> items = MockData.grades()
        .map((Map<String, dynamic> json) => GradeModel.fromJson(json))
        .toList();
    items
        .sort((GradeModel a, GradeModel b) => b.gradedAt.compareTo(a.gradedAt));
    return items;
  }

  // -------------------------------------------------------------------- XP

  @override
  Future<int> getTotalXP(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/xp/');
    return _db.totalXp;
  }

  @override
  Future<List<XpLogModel>> getXpLogs(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/xp/logs/');
    return _db.xpLogs
        .map((Map<String, dynamic> json) => XpLogModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(String groupId) async {
    await _api.send(method: 'GET', path: '/groups/$groupId/leaderboard/');
    return _db.leaderboard
        .map((Map<String, dynamic> json) => LeaderboardEntry.fromJson(json))
        .toList();
  }

  // ----------------------------------------------------------------- Arena

  @override
  Future<List<ArenaTaskModel>> getArenaTasks(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/arena-tasks/');
    return _db.arenaTasks
        .map((Map<String, dynamic> json) => ArenaTaskModel.fromJson(json))
        .toList();
  }

  @override
  Future<ArenaTaskModel> getArenaTask(String taskId) async {
    await _api.send(method: 'GET', path: '/arena-tasks/$taskId/');
    return ArenaTaskModel.fromJson(_requireTask(taskId));
  }

  @override
  Future<ArenaTaskResult> submitArenaQuiz({
    required String taskId,
    required Map<String, int> answers,
  }) async {
    await _api.send(
      method: 'POST',
      path: '/arena-tasks/$taskId/submit/',
      body: <String, dynamic>{'answers': answers},
    );

    final Map<String, dynamic> json = _requireTask(taskId);
    _assertNotCompleted(json);

    final List<Map<String, dynamic>> questions =
        (json['questions'] as List<dynamic>).cast<Map<String, dynamic>>();

    if (questions.isEmpty) {
      throw const ValidationException('Bu topshiriqda savollar yo\'q.');
    }
    if (answers.length < questions.length) {
      throw const ValidationException('Barcha savollarga javob bering.');
    }

    // Tekshirish SERVER tomonida bo'ladi — javob kaliti mijozga yuborilmagan.
    int correct = 0;
    for (final Map<String, dynamic> question in questions) {
      final String id = question['id'] as String;
      if (MockData.quizAnswerKey[id] == answers[id]) correct++;
    }

    final int xpReward = json['xp_reward'] as int;
    final int earned = ((correct / questions.length) * xpReward).round();

    return _complete(
      json: json,
      earnedXp: earned,
      progressCurrent: correct,
      comment: '${questions.length} ta savoldan $correct tasiga '
          "to'g'ri javob berdingiz.",
      message: correct == questions.length
          ? 'Ajoyib! Barcha javoblar to\'g\'ri 🎉'
          : 'Yaxshi natija! Xatolar ustida ishlang.',
      correctCount: correct,
      totalQuestions: questions.length,
    );
  }

  @override
  Future<ArenaTaskResult> submitArenaWork({
    required String taskId,
    required String text,
    List<String> fileNames = const <String>[],
  }) async {
    await _api.send(
      method: 'POST',
      path: '/arena-tasks/$taskId/submit/',
      body: <String, dynamic>{'text': text, 'files': fileNames},
    );

    final Map<String, dynamic> json = _requireTask(taskId);
    _assertNotCompleted(json);

    if (text.trim().isEmpty && fileNames.isEmpty) {
      throw const ValidationException(
        'Javob matnini yozing yoki fayl biriktiring.',
      );
    }

    return _complete(
      json: json,
      earnedXp: json['xp_reward'] as int,
      progressCurrent: json['progress_target'] as int,
      comment: 'Topshiriq qabul qilindi. O\'qituvchi tez orada izoh qoldiradi.',
      message: 'Topshiriq yuborildi!',
    );
  }

  @override
  Future<ArenaTaskResult> claimArenaReward(String taskId) async {
    await _api.send(method: 'POST', path: '/arena-tasks/$taskId/claim/');

    final Map<String, dynamic> json = _requireTask(taskId);
    _assertNotCompleted(json);

    final int current = json['progress_current'] as int;
    final int target = json['progress_target'] as int;
    if (current < target) {
      throw const ValidationException(
        'Chellenj hali tugamagan — mukofotni olish uchun uni yakunlang.',
      );
    }

    return _complete(
      json: json,
      earnedXp: json['xp_reward'] as int,
      progressCurrent: target,
      comment: 'Chellenj bajarildi.',
      message: 'Mukofot qo\'lga kiritildi!',
    );
  }

  // ------------------------------------------------------- Bildirishnomalar

  @override
  Future<List<NotificationModel>> getNotifications(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/notifications/');
    final List<NotificationModel> items = _db.notifications
        .map((Map<String, dynamic> json) => NotificationModel.fromJson(json))
        .toList();
    items.sort((NotificationModel a, NotificationModel b) =>
        b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    await _api.send(
      method: 'PATCH',
      path: '/notifications/$notificationId/',
      body: <String, dynamic>{'is_read': true},
    );
    for (final Map<String, dynamic> json in _db.notifications) {
      if (json['id'] == notificationId) json['is_read'] = true;
    }
  }

  @override
  Future<void> markAllNotificationsRead(String studentId) async {
    await _api.send(
      method: 'POST',
      path: '/students/$studentId/notifications/read-all/',
    );
    for (final Map<String, dynamic> json in _db.notifications) {
      json['is_read'] = true;
    }
  }

  // ---------------------------------------------------------- yordamchilar

  /// Topshiriqni bajarilgan deb belgilaydi, XP qo'shadi va natijani qaytaradi.
  /// Serverda bo'ladigan barcha yon ta'sirlar shu yerda takrorlanadi.
  ArenaTaskResult _complete({
    required Map<String, dynamic> json,
    required int earnedXp,
    required int progressCurrent,
    required String comment,
    required String message,
    int? correctCount,
    int? totalQuestions,
  }) {
    final int previousRank = _db.currentRank;

    json['status'] = 'completed';
    json['earned_xp'] = earnedXp;
    json['progress_current'] = progressCurrent;
    json['result_comment'] = comment;
    json['completed_at'] = DateTime.now().toIso8601String();

    final int totalXp = _db.awardXp(
      amount: earnedXp,
      reason: 'Arena: ${json['title']}',
    );

    _db.addNotification(
      type: 'xp',
      title: '+$earnedXp XP',
      body: '"${json['title']}" topshirig\'i uchun XP qo\'shildi. '
          'Jami: $totalXp XP.',
      targetId: json['id'] as String,
    );

    return ArenaTaskResult(
      taskId: json['id'] as String,
      earnedXp: earnedXp,
      totalXp: totalXp,
      message: message,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      newRank: _db.currentRank,
      previousRank: previousRank,
    );
  }

  void _assertNotCompleted(Map<String, dynamic> json) {
    if (json['status'] == 'completed') {
      throw const ValidationException('Bu topshiriq allaqachon bajarilgan.');
    }
  }

  Map<String, dynamic> _requireTask(String id) {
    for (final Map<String, dynamic> json in _db.arenaTasks) {
      if (json['id'] == id) return json;
    }
    throw const NotFoundException('Topshiriq topilmadi.');
  }

  Map<String, dynamic> _requireHomework(String id) {
    for (final Map<String, dynamic> json in _db.homework) {
      if (json['id'] == id) return json;
    }
    throw const NotFoundException('Uy vazifasi topilmadi.');
  }
}
