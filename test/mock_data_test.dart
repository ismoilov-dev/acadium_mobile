import 'package:acadium_student/core/error/app_exception.dart';
import 'package:acadium_student/core/network/api_client.dart';
import 'package:acadium_student/data/datasources/fake_auth_datasource.dart';
import 'package:acadium_student/data/datasources/fake_student_datasource.dart';
import 'package:acadium_student/data/datasources/mock/mock_data.dart';
import 'package:acadium_student/data/models/auth_models.dart';
import 'package:acadium_student/data/models/grade_model.dart';
import 'package:acadium_student/data/models/homework_model.dart';
import 'package:acadium_student/data/models/student_model.dart';
import 'package:acadium_student/data/models/xp_model.dart';
import 'package:acadium_student/data/repositories/student_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testlar uchun soxta ApiClient — secure storage'ga tegmaydi.
class _NoopApiClient implements ApiClient {
  @override
  String get baseUrl => 'https://test.local';

  @override
  Future<Map<String, String>> buildHeaders() async => <String, String>{};

  @override
  Future<dynamic> send({
    required String method,
    required String path,
    Map<String, dynamic>? query,
    Object? body,
  }) async =>
      null;
}

void main() {
  final _NoopApiClient api = _NoopApiClient();

  group('Mock JSON → model', () {
    test('profil parse bo\'ladi', () {
      final StudentModel s = StudentModel.fromJson(MockData.student());
      expect(s.id, MockData.studentId);
      expect(s.fullName, 'Amir Tursunov');
      expect(s.totalXp, MockData.totalXp);
    });

    test('barcha ro\'yxatlar parse bo\'ladi', () {
      expect(MockData.lessons().length, 8);
      expect(MockData.attendance().length, 20);
      expect(MockData.homework().length, 6);
      expect(MockData.grades().length, 7);
      expect(MockData.leaderboard().length, 7);
      expect(MockData.notifications().length, 6);

      for (final Map<String, dynamic> json in MockData.grades()) {
        expect(GradeModel.fromJson(json).maxScore, 100);
      }
    });

    test('reytingda foydalanuvchi 2-o\'rinda', () {
      final List<LeaderboardEntry> board = MockData.leaderboard()
          .map(LeaderboardEntry.fromJson)
          .toList();
      final LeaderboardEntry me =
          board.firstWhere((LeaderboardEntry e) => e.isCurrentUser);
      expect(me.rank, 2);
      expect(me.displayName, 'Siz');
      expect(board.first.totalXp, 1480);
    });
  });

  group('FakeStudentDatasource', () {
    test('uy vazifasini topshirgach status o\'zgaradi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      final List<HomeworkModel> before = await ds.getHomework('x');
      final HomeworkModel target =
          before.firstWhere((HomeworkModel h) => h.canSubmit);

      final HomeworkModel after = await ds.submitHomework(
        HomeworkSubmission(homeworkId: target.id, text: 'Javobim'),
      );

      expect(after.status, isNot(HomeworkStatus.assigned));
      expect(after.submittedAt, isNotNull);
    });

    test('bo\'sh javob qabul qilinmaydi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      final List<HomeworkModel> items = await ds.getHomework('x');
      final HomeworkModel target =
          items.firstWhere((HomeworkModel h) => h.canSubmit);

      expect(
        () => ds.submitHomework(
          HomeworkSubmission(homeworkId: target.id, text: '   '),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('bildirishnoma o\'qilgan deb belgilanadi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      await ds.markAllNotificationsRead('x');
      final List<dynamic> items = await ds.getNotifications('x');
      expect(items.every((dynamic n) => n.isRead == true), isTrue);
    });
  });

  group('FakeAuthDatasource', () {
    test('juft raqam — yangi foydalanuvchi, toq — mavjud', () async {
      final FakeAuthDatasource auth = FakeAuthDatasource(api);
      expect((await auth.checkPhone('+998901234568')).isRegistered, isFalse);
      expect((await auth.checkPhone('+998901234567')).isRegistered, isTrue);
    });

    test('noto\'g\'ri format rad etiladi', () {
      final FakeAuthDatasource auth = FakeAuthDatasource(api);
      expect(
        () => auth.checkPhone('12345'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('faqat 1234 PIN bilan kiriladi', () async {
      final FakeAuthDatasource auth = FakeAuthDatasource(api);
      final AuthSession session = await auth.loginWithPin(
        phone: '+998901234567',
        pin: '1234',
        deviceId: 'device-1',
      );
      expect(session.accessToken, startsWith('fake.'));
      expect(session.studentId, MockData.studentId);

      expect(
        () => auth.loginWithPin(
          phone: '+998901234567',
          pin: '9999',
          deviceId: 'device-1',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('StudentRepository', () {
    test('progress 0..1 oralig\'ida hisoblanadi', () async {
      final StudentRepository repo =
          StudentRepository(datasource: FakeStudentDatasource(api));
      final ProgressSummary p = await repo.getProgress('x');

      expect(p.attendance, inInclusiveRange(0, 1));
      expect(p.homework, inInclusiveRange(0, 1));
      expect(p.tests, inInclusiveRange(0, 1));
      expect(p.overall, inInclusiveRange(0, 1));
    });

    test('jadval hafta kunlari bo\'yicha guruhlanadi', () async {
      final StudentRepository repo =
          StudentRepository(datasource: FakeStudentDatasource(api));
      final Map<int, List<dynamic>> byDay = await repo.getScheduleByWeekday('x');

      expect(byDay.keys.every((int d) => d >= 1 && d <= 7), isTrue);
      expect(
        byDay.values.fold<int>(0, (int acc, List<dynamic> l) => acc + l.length),
        8,
      );
    });
  });
}
