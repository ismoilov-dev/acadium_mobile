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
import 'student_datasource.dart';

/// [StudentDatasource]ning FAKE implementatsiyasi.
///
/// Har bir metod:
///  1. [ApiClient] orqali so'rovni "yuboradi" (Authorization + X-Device-Id
///     header'lari yig'iladi va log qilinadi, tarmoq kechikishi simulyatsiya
///     qilinadi);
///  2. mock JSON'ni model'ga aylantirib qaytaradi.
///
/// Mock JSON real backend formatiga mos, shuning uchun real datasource'ga
/// o'tilganda model'larning `fromJson` kodi o'zgarmaydi.
class FakeStudentDatasource implements StudentDatasource {
  FakeStudentDatasource(this._api);

  final ApiClient _api;

  /// Sessiya davomida o'zgarishlarni saqlab turish uchun xotiradagi nusxalar
  /// (masalan uy vazifasi topshirilganda status yangilanadi).
  List<Map<String, dynamic>>? _homeworkCache;
  List<Map<String, dynamic>>? _notificationCache;

  List<Map<String, dynamic>> get _homework =>
      _homeworkCache ??= MockData.homework();

  List<Map<String, dynamic>> get _notifications =>
      _notificationCache ??= MockData.notifications();

  // --------------------------------------------------------------- Profil

  @override
  Future<StudentModel> getProfile(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/');
    return StudentModel.fromJson(MockData.student());
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
    final List<HomeworkModel> items = _homework
        .map((Map<String, dynamic> json) => HomeworkModel.fromJson(json))
        .toList();
    // Eng yangi muddat birinchi bo'lsin.
    items.sort((HomeworkModel a, HomeworkModel b) => b.dueAt.compareTo(a.dueAt));
    return items;
  }

  @override
  Future<HomeworkModel> getHomeworkDetail(String homeworkId) async {
    await _api.send(method: 'GET', path: '/homeworks/$homeworkId/');
    final Map<String, dynamic>? json = _findHomework(homeworkId);
    if (json == null) {
      throw const NotFoundException('Uy vazifasi topilmadi.');
    }
    return HomeworkModel.fromJson(json);
  }

  @override
  Future<HomeworkModel> submitHomework(HomeworkSubmission submission) async {
    await _api.send(
      method: 'POST',
      path: '/homeworks/${submission.homeworkId}/submit/',
      body: submission.toJson(),
    );

    final Map<String, dynamic>? json = _findHomework(submission.homeworkId);
    if (json == null) {
      throw const NotFoundException('Uy vazifasi topilmadi.');
    }

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
    items.sort((GradeModel a, GradeModel b) => b.gradedAt.compareTo(a.gradedAt));
    return items;
  }

  // ------------------------------------------------------------ XP / Arena

  @override
  Future<int> getTotalXP(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/xp/');
    return MockData.totalXp;
  }

  @override
  Future<List<XpLogModel>> getXpLogs(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/xp/logs/');
    return MockData.xpLogs()
        .map((Map<String, dynamic> json) => XpLogModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(String groupId) async {
    await _api.send(method: 'GET', path: '/groups/$groupId/leaderboard/');
    return MockData.leaderboard()
        .map((Map<String, dynamic> json) => LeaderboardEntry.fromJson(json))
        .toList();
  }

  @override
  Future<List<ArenaTaskModel>> getArenaTasks(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/arena-tasks/');
    return MockData.arenaTasks()
        .map((Map<String, dynamic> json) => ArenaTaskModel.fromJson(json))
        .toList();
  }

  // ------------------------------------------------------- Bildirishnomalar

  @override
  Future<List<NotificationModel>> getNotifications(String studentId) async {
    await _api.send(method: 'GET', path: '/students/$studentId/notifications/');
    final List<NotificationModel> items = _notifications
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
    for (final Map<String, dynamic> json in _notifications) {
      if (json['id'] == notificationId) json['is_read'] = true;
    }
  }

  @override
  Future<void> markAllNotificationsRead(String studentId) async {
    await _api.send(
      method: 'POST',
      path: '/students/$studentId/notifications/read-all/',
    );
    for (final Map<String, dynamic> json in _notifications) {
      json['is_read'] = true;
    }
  }

  // ---------------------------------------------------------- yordamchilar

  Map<String, dynamic>? _findHomework(String id) {
    for (final Map<String, dynamic> json in _homework) {
      if (json['id'] == id) return json;
    }
    return null;
  }
}
