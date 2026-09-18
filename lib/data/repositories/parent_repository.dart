import '../datasources/parent_datasource.dart';
import '../models/attendance_model.dart';
import '../models/child_model.dart';
import '../models/grade_model.dart';
import '../models/homework_model.dart';
import '../models/lesson_model.dart';
import '../models/notification_model.dart';
import '../models/parent_model.dart';
import '../models/payment_model.dart';

/// Ota-ona ilovasi uchun repository.
///
/// UI qatlami datasource'ni ko'rmaydi; bu yerda ma'lumot UI uchun qulay
/// ko'rinishga keltiriladi (guruhlash, saralash).
class ParentRepository {
  ParentRepository({required ParentDatasource datasource})
      : _datasource = datasource;

  final ParentDatasource _datasource;

  Future<ParentModel> getProfile(String parentId) =>
      _datasource.getProfile(parentId);

  Future<List<ChildModel>> getChildren(String parentId) =>
      _datasource.getChildren(parentId);

  Future<ChildSummary> getChildSummary(String childId) =>
      _datasource.getChildSummary(childId);

  Future<List<AttendanceModel>> getChildAttendance(String childId) =>
      _datasource.getChildAttendance(childId);

  Future<List<HomeworkModel>> getChildHomework(String childId) =>
      _datasource.getChildHomework(childId);

  Future<List<GradeModel>> getChildGrades(String childId) =>
      _datasource.getChildGrades(childId);

  Future<List<LessonModel>> getChildSchedule(String childId) =>
      _datasource.getChildSchedule(childId);

  /// Jadvalni hafta kunlari bo'yicha guruhlaydi (1 = Dushanba ... 7 = Yakshanba).
  Future<Map<int, List<LessonModel>>> getChildScheduleByWeekday(
      String childId) async {
    final List<LessonModel> lessons = await getChildSchedule(childId);
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

  Future<List<PaymentModel>> getPayments(String parentId) =>
      _datasource.getPayments(parentId);

  /// To'lovlarni farzandlar bo'yicha guruhlaydi.
  Future<Map<String, List<PaymentModel>>> getPaymentsByChild(
      String parentId) async {
    final List<PaymentModel> payments = await getPayments(parentId);
    final Map<String, List<PaymentModel>> grouped =
        <String, List<PaymentModel>>{};
    for (final PaymentModel payment in payments) {
      grouped.putIfAbsent(payment.childId, () => <PaymentModel>[]).add(payment);
    }
    return grouped;
  }

  Future<List<NotificationModel>> getNotifications(String parentId) =>
      _datasource.getNotifications(parentId);

  Future<void> markNotificationRead(String id) =>
      _datasource.markNotificationRead(id);

  Future<void> markAllNotificationsRead(String parentId) =>
      _datasource.markAllNotificationsRead(parentId);
}
