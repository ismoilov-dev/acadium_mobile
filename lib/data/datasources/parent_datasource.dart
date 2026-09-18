import '../models/attendance_model.dart';
import '../models/child_model.dart';
import '../models/grade_model.dart';
import '../models/homework_model.dart';
import '../models/lesson_model.dart';
import '../models/notification_model.dart';
import '../models/parent_model.dart';
import '../models/payment_model.dart';

/// Ota-ona ilovasi uchun ABSTRAKT interfeys.
///
/// Xuddi [StudentDatasource] kabi: fake va real implementatsiyalar shu
/// shartnomani bajaradi, almashtirish esa `core/service_locator.dart` da
/// bitta qatorda amalga oshiriladi.
abstract class ParentDatasource {
  /// Ota-ona profili.
  Future<ParentModel> getProfile(String parentId);

  /// Bog'langan farzandlar ro'yxati.
  Future<List<ChildModel>> getChildren(String parentId);

  /// Farzand bo'yicha "bir qarashda" ma'lumot (Home ekrani kartalari).
  Future<ChildSummary> getChildSummary(String childId);

  /// Farzandning davomati.
  Future<List<AttendanceModel>> getChildAttendance(String childId);

  /// Farzandning uy vazifalari.
  Future<List<HomeworkModel>> getChildHomework(String childId);

  /// Farzandning baholari.
  Future<List<GradeModel>> getChildGrades(String childId);

  /// Farzandning dars jadvali.
  Future<List<LessonModel>> getChildSchedule(String childId);

  /// Barcha farzandlar bo'yicha to'lovlar.
  Future<List<PaymentModel>> getPayments(String parentId);

  /// Ota-ona bildirishnomalari (farzand nomi bilan).
  Future<List<NotificationModel>> getNotifications(String parentId);

  Future<void> markNotificationRead(String notificationId);

  Future<void> markAllNotificationsRead(String parentId);
}
