import '../datasources/student_datasource.dart';
import '../models/arena_task_model.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/homework_model.dart';
import '../models/lesson_model.dart';
import '../models/notification_model.dart';
import '../models/student_model.dart';
import '../models/xp_model.dart';

/// O'quvchi ma'lumotlari uchun repository.
///
/// Datasource'dan kelgan "xom" ma'lumotni UI uchun qulay ko'rinishga keltiradi
/// (saralash, guruhlash, progress hisoblash).
class StudentRepository {
  StudentRepository({required StudentDatasource datasource})
      : _datasource = datasource;

  final StudentDatasource _datasource;

  Future<StudentModel> getProfile(String studentId) =>
      _datasource.getProfile(studentId);

  Future<List<LessonModel>> getSchedule(String studentId) =>
      _datasource.getSchedule(studentId);

  /// Hozirgi vaqtdan keyingi eng yaqin dars (bo'lmasa — null).
  Future<LessonModel?> getNextLesson(String studentId) async {
    final List<LessonModel> lessons = await getSchedule(studentId);
    final DateTime now = DateTime.now();
    final List<LessonModel> upcoming = lessons
        .where((LessonModel l) => l.endsAt.isAfter(now))
        .toList()
      ..sort(
          (LessonModel a, LessonModel b) => a.startsAt.compareTo(b.startsAt));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Jadvalni hafta kunlari bo'yicha guruhlaydi (1 = Dushanba ... 7 = Yakshanba).
  Future<Map<int, List<LessonModel>>> getScheduleByWeekday(
      String studentId) async {
    final List<LessonModel> lessons = await getSchedule(studentId);
    final Map<int, List<LessonModel>> grouped = <int, List<LessonModel>>{};
    for (final LessonModel lesson in lessons) {
      grouped.putIfAbsent(lesson.weekday, () => <LessonModel>[]).add(lesson);
    }
    for (final List<LessonModel> day in grouped.values) {
      day.sort(
          (LessonModel a, LessonModel b) => a.startsAt.compareTo(b.startsAt));
    }
    return grouped;
  }

  Future<List<AttendanceModel>> getAttendance(String studentId) =>
      _datasource.getAttendance(studentId);

  Future<List<HomeworkModel>> getHomework(String studentId) =>
      _datasource.getHomework(studentId);

  Future<HomeworkModel> getHomeworkDetail(String homeworkId) =>
      _datasource.getHomeworkDetail(homeworkId);

  Future<HomeworkModel> submitHomework(HomeworkSubmission submission) =>
      _datasource.submitHomework(submission);

  Future<List<GradeModel>> getGrades(String studentId) =>
      _datasource.getGrades(studentId);

  /// Baholarni fanlar bo'yicha guruhlaydi.
  Future<List<SubjectGrades>> getGradesBySubject(String studentId) async {
    final List<GradeModel> grades = await getGrades(studentId);
    final Map<String, List<GradeModel>> grouped = <String, List<GradeModel>>{};
    for (final GradeModel grade in grades) {
      grouped.putIfAbsent(grade.subject, () => <GradeModel>[]).add(grade);
    }
    return grouped.entries
        .map((MapEntry<String, List<GradeModel>> e) =>
            SubjectGrades(subject: e.key, grades: e.value))
        .toList();
  }

  /// Umumiy progress: davomat %, uy vazifasi %, testlar %.
  Future<ProgressSummary> getProgress(String studentId) async {
    final List<AttendanceModel> attendance = await getAttendance(studentId);
    final List<HomeworkModel> homework = await getHomework(studentId);
    final List<GradeModel> grades = await getGrades(studentId);

    final double attendancePercent = attendance.isEmpty
        ? 0
        : attendance.where((AttendanceModel a) => a.countsAsAttended).length /
            attendance.length;

    final double homeworkPercent = homework.isEmpty
        ? 0
        : homework.where((HomeworkModel h) => !h.isPending).length /
            homework.length;

    final List<GradeModel> tests = grades
        .where((GradeModel g) =>
            g.type == GradeType.test || g.type == GradeType.exam)
        .toList();
    final double testPercent = tests.isEmpty
        ? 0
        : tests.fold<double>(0, (double acc, GradeModel g) => acc + g.percent) /
            tests.length /
            100;

    return ProgressSummary(
      attendance: attendancePercent,
      homework: homeworkPercent,
      tests: testPercent,
    );
  }

  Future<int> getTotalXP(String studentId) => _datasource.getTotalXP(studentId);

  Future<List<XpLogModel>> getXpLogs(String studentId) =>
      _datasource.getXpLogs(studentId);

  Future<List<LeaderboardEntry>> getLeaderboard(String groupId) =>
      _datasource.getLeaderboard(groupId);

  Future<List<ArenaTaskModel>> getArenaTasks(String studentId) =>
      _datasource.getArenaTasks(studentId);

  /// Faol (bajarilmagan) topshiriqlar — muddati yaqini birinchi.
  Future<List<ArenaTaskModel>> getActiveArenaTasks(String studentId) async {
    final List<ArenaTaskModel> tasks = await getArenaTasks(studentId);
    final List<ArenaTaskModel> active =
        tasks.where((ArenaTaskModel t) => !t.isCompleted).toList();

    active.sort((ArenaTaskModel a, ArenaTaskModel b) {
      // Mukofot olishga tayyor chellenjlar tepada tursin.
      if (a.canClaim != b.canClaim) return a.canClaim ? -1 : 1;
      final DateTime aDeadline =
          a.deadline ?? DateTime.now().add(const Duration(days: 365));
      final DateTime bDeadline =
          b.deadline ?? DateTime.now().add(const Duration(days: 365));
      return aDeadline.compareTo(bDeadline);
    });
    return active;
  }

  Future<ArenaTaskModel> getArenaTask(String taskId) =>
      _datasource.getArenaTask(taskId);

  Future<ArenaTaskResult> submitArenaQuiz({
    required String taskId,
    required Map<String, int> answers,
  }) =>
      _datasource.submitArenaQuiz(taskId: taskId, answers: answers);

  Future<ArenaTaskResult> submitArenaWork({
    required String taskId,
    required String text,
    List<String> fileNames = const <String>[],
  }) =>
      _datasource.submitArenaWork(
        taskId: taskId,
        text: text,
        fileNames: fileNames,
      );

  Future<ArenaTaskResult> claimArenaReward(String taskId) =>
      _datasource.claimArenaReward(taskId);

  Future<List<NotificationModel>> getNotifications(String studentId) =>
      _datasource.getNotifications(studentId);

  Future<void> markNotificationRead(String id) =>
      _datasource.markNotificationRead(id);

  Future<void> markAllNotificationsRead(String studentId) =>
      _datasource.markAllNotificationsRead(studentId);
}
