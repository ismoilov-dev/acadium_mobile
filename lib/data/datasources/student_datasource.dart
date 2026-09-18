import '../models/arena_task_model.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/homework_model.dart';
import '../models/lesson_model.dart';
import '../models/notification_model.dart';
import '../models/student_model.dart';
import '../models/xp_model.dart';

/// O'quvchi ma'lumotlari uchun ABSTRAKT interfeys.
///
/// Kelajakda `RealStudentDatasource` shu interfeysni implement qiladi va
/// `service_locator.dart` ichidagi bitta qator o'zgartiriladi — boshqa hech
/// qanday faylga tegilmaydi.
abstract class StudentDatasource {
  /// Profil ma'lumotlari.
  Future<StudentModel> getProfile(String studentId);

  /// Haftalik dars jadvali.
  Future<List<LessonModel>> getSchedule(String studentId);

  /// Davomat tarixi.
  Future<List<AttendanceModel>> getAttendance(String studentId);

  /// Uy vazifalari ro'yxati.
  Future<List<HomeworkModel>> getHomework(String studentId);

  /// Bitta uy vazifasi.
  Future<HomeworkModel> getHomeworkDetail(String homeworkId);

  /// Uy vazifasini topshirish.
  Future<HomeworkModel> submitHomework(HomeworkSubmission submission);

  /// Baholar.
  Future<List<GradeModel>> getGrades(String studentId);

  /// Jami XP.
  Future<int> getTotalXP(String studentId);

  /// XP tarixi.
  Future<List<XpLogModel>> getXpLogs(String studentId);

  /// Guruh reytingi.
  Future<List<LeaderboardEntry>> getLeaderboard(String groupId);

  /// Arena topshiriqlari (o'qituvchilar yuklagan).
  Future<List<ArenaTaskModel>> getArenaTasks(String studentId);

  /// Bitta arena topshirig'i (savollari bilan).
  Future<ArenaTaskModel> getArenaTask(String taskId);

  /// Test javoblarini yuborish. [answers]: savol id → tanlangan variant indeksi.
  /// To'g'ri javoblar server tomonida tekshiriladi.
  Future<ArenaTaskResult> submitArenaQuiz({
    required String taskId,
    required Map<String, int> answers,
  });

  /// Ijodiy topshiriqni (matn/fayl) yuborish.
  Future<ArenaTaskResult> submitArenaWork({
    required String taskId,
    required String text,
    List<String> fileNames,
  });

  /// Bajarilgan chellenj uchun mukofotni olish.
  Future<ArenaTaskResult> claimArenaReward(String taskId);

  /// Bildirishnomalar.
  Future<List<NotificationModel>> getNotifications(String studentId);

  /// Bildirishnomani o'qilgan deb belgilash.
  Future<void> markNotificationRead(String notificationId);

  /// Barcha bildirishnomalarni o'qilgan deb belgilash.
  Future<void> markAllNotificationsRead(String studentId);
}
