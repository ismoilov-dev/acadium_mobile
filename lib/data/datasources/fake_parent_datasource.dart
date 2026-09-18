import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/attendance_model.dart';
import '../models/child_model.dart';
import '../models/grade_model.dart';
import '../models/homework_model.dart';
import '../models/lesson_model.dart';
import '../models/notification_model.dart';
import '../models/parent_model.dart';
import '../models/payment_model.dart';
import 'mock/mock_data.dart';
import 'mock/mock_state.dart';
import 'parent_datasource.dart';

/// [ParentDatasource]ning FAKE implementatsiyasi.
///
/// Student tomonidagi bilan bir xil tamoyil: so'rov [ApiClient] orqali
/// "yuboriladi" (token + device_id header'lari yig'iladi, kechikish
/// simulyatsiya qilinadi), so'ng backend formatidagi mock JSON model'ga
/// aylantiriladi.
class FakeParentDatasource implements ParentDatasource {
  FakeParentDatasource(this._api);

  final ApiClient _api;

  MockState get _db => MockState.instance;

  @override
  Future<ParentModel> getProfile(String parentId) async {
    await _api.send(method: 'GET', path: '/parents/$parentId/');
    return ParentModel.fromJson(MockData.parent());
  }

  @override
  Future<List<ChildModel>> getChildren(String parentId) async {
    await _api.send(method: 'GET', path: '/parents/$parentId/children/');
    return MockData.children()
        .map((Map<String, dynamic> json) => ChildModel.fromJson(json))
        .toList();
  }

  /// Serverda bo'ladigan agregatsiyani takrorlaymiz: davomat, vazifa, baho
  /// va to'lov ma'lumotlaridan yagona "summary" yig'iladi.
  @override
  Future<ChildSummary> getChildSummary(String childId) async {
    await _api.send(method: 'GET', path: '/children/$childId/summary/');
    _assertChildExists(childId);

    final List<AttendanceModel> attendance = MockData.childAttendance(childId)
        .map((Map<String, dynamic> json) => AttendanceModel.fromJson(json))
        .toList();
    final List<HomeworkModel> homework = MockData.childHomework(childId)
        .map((Map<String, dynamic> json) => HomeworkModel.fromJson(json))
        .toList();
    final List<GradeModel> grades = MockData.childGrades(childId)
        .map((Map<String, dynamic> json) => GradeModel.fromJson(json))
        .toList();
    final List<LessonModel> lessons = MockData.childSchedule(childId)
        .map((Map<String, dynamic> json) => LessonModel.fromJson(json))
        .toList();

    // Bugungi dars va uning holati.
    final DateTime now = DateTime.now();
    final Iterable<LessonModel> todayLessons = lessons.where((LessonModel l) =>
        l.startsAt.year == now.year &&
        l.startsAt.month == now.month &&
        l.startsAt.day == now.day);

    String todayStatus;
    if (todayLessons.isEmpty) {
      todayStatus = TodayLessonStatus.noLesson.apiValue;
    } else if (todayLessons.every((LessonModel l) => l.startsAt.isAfter(now))) {
      todayStatus = TodayLessonStatus.pending.apiValue;
    } else {
      // Dars bo'lib o'tgan — oxirgi davomat yozuvidan holatni olamiz.
      final AttendanceModel? last =
          attendance.isEmpty ? null : attendance.first;
      todayStatus = last == null
          ? TodayLessonStatus.pending.apiValue
          : TodayLessonStatus.fromAttendance(last.status).apiValue;
    }

    // Keyingi dars.
    final List<LessonModel> upcoming = lessons
        .where((LessonModel l) => l.endsAt.isAfter(now))
        .toList()
      ..sort(
          (LessonModel a, LessonModel b) => a.startsAt.compareTo(b.startsAt));
    final LessonModel? next = upcoming.isEmpty ? null : upcoming.first;

    // To'lov holati: eng "og'ir" holatdagi to'lov ko'rsatiladi.
    final List<PaymentModel> payments = MockData.payments()
        .map((Map<String, dynamic> json) => PaymentModel.fromJson(json))
        .where((PaymentModel p) => p.childId == childId)
        .toList()
      ..sort((PaymentModel a, PaymentModel b) =>
          a.status.index.compareTo(b.status.index));
    final PaymentModel? payment = payments.isEmpty ? null : payments.last;

    final double attendanceRate = attendance.isEmpty
        ? 0
        : attendance.where((AttendanceModel a) => a.countsAsAttended).length /
            attendance.length;
    final double averageGrade = grades.isEmpty
        ? 0
        : grades.fold<double>(
                0, (double acc, GradeModel g) => acc + g.percent) /
            grades.length;

    return ChildSummary.fromJson(<String, dynamic>{
      'child_id': childId,
      'today_status': todayStatus,
      'pending_homework':
          homework.where((HomeworkModel h) => h.isPending).length,
      'average_grade': averageGrade,
      'attendance_rate': attendanceRate,
      'payment_status_label': payment?.status.label ?? "Ma'lumot yo'q",
      'payment_due_in_days': payment?.daysLeft ?? 0,
      'next_lesson_subject': next?.subject,
      'next_lesson_at': next?.startsAt.toIso8601String(),
      'next_lesson_room': next?.room,
    });
  }

  @override
  Future<List<AttendanceModel>> getChildAttendance(String childId) async {
    await _api.send(method: 'GET', path: '/children/$childId/attendance/');
    _assertChildExists(childId);

    final List<AttendanceModel> items = MockData.childAttendance(childId)
        .map((Map<String, dynamic> json) => AttendanceModel.fromJson(json))
        .toList();
    items.sort(
        (AttendanceModel a, AttendanceModel b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<List<HomeworkModel>> getChildHomework(String childId) async {
    await _api.send(method: 'GET', path: '/children/$childId/homeworks/');
    _assertChildExists(childId);

    final List<HomeworkModel> items = MockData.childHomework(childId)
        .map((Map<String, dynamic> json) => HomeworkModel.fromJson(json))
        .toList();
    items
        .sort((HomeworkModel a, HomeworkModel b) => b.dueAt.compareTo(a.dueAt));
    return items;
  }

  @override
  Future<List<GradeModel>> getChildGrades(String childId) async {
    await _api.send(method: 'GET', path: '/children/$childId/grades/');
    _assertChildExists(childId);

    final List<GradeModel> items = MockData.childGrades(childId)
        .map((Map<String, dynamic> json) => GradeModel.fromJson(json))
        .toList();
    items
        .sort((GradeModel a, GradeModel b) => b.gradedAt.compareTo(a.gradedAt));
    return items;
  }

  @override
  Future<List<LessonModel>> getChildSchedule(String childId) async {
    await _api.send(method: 'GET', path: '/children/$childId/schedule/');
    _assertChildExists(childId);

    return MockData.childSchedule(childId)
        .map((Map<String, dynamic> json) => LessonModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<PaymentModel>> getPayments(String parentId) async {
    await _api.send(method: 'GET', path: '/parents/$parentId/payments/');

    final List<PaymentModel> items = MockData.payments()
        .map((Map<String, dynamic> json) => PaymentModel.fromJson(json))
        .toList();
    // Avval to'lanmaganlari: kechikkan → muddati yaqin → to'langan.
    items.sort((PaymentModel a, PaymentModel b) {
      final int byStatus = b.status.index.compareTo(a.status.index);
      if (byStatus != 0) return byStatus;
      return a.dueDate.compareTo(b.dueDate);
    });
    return items;
  }

  @override
  Future<List<NotificationModel>> getNotifications(String parentId) async {
    await _api.send(method: 'GET', path: '/parents/$parentId/notifications/');

    final List<NotificationModel> items = _db.parentNotifications
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
    for (final Map<String, dynamic> json in _db.parentNotifications) {
      if (json['id'] == notificationId) json['is_read'] = true;
    }
  }

  @override
  Future<void> markAllNotificationsRead(String parentId) async {
    await _api.send(
      method: 'POST',
      path: '/parents/$parentId/notifications/read-all/',
    );
    for (final Map<String, dynamic> json in _db.parentNotifications) {
      json['is_read'] = true;
    }
  }

  /// Real API 404 qaytargani kabi — noma'lum farzand so'ralsa xatolik.
  void _assertChildExists(String childId) {
    final bool exists = MockData.children()
        .any((Map<String, dynamic> json) => json['id'] == childId);
    if (!exists) throw const NotFoundException('Farzand topilmadi.');
  }
}
