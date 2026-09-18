import 'package:acadium_student/core/error/app_exception.dart';
import 'package:acadium_student/core/network/api_client.dart';
import 'package:acadium_student/data/datasources/fake_auth_datasource.dart';
import 'package:acadium_student/data/datasources/fake_student_datasource.dart';
import 'package:acadium_student/data/datasources/mock/mock_data.dart';
import 'package:acadium_student/data/datasources/mock/mock_state.dart';
import 'package:acadium_student/data/models/arena_task_model.dart';
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

  // Har bir test toza "baza" bilan boshlansin.
  setUp(MockState.instance.reset);

  /// Testning barcha savollariga to'g'ri javob tayyorlaydi.
  Map<String, int> correctAnswersFor(ArenaTaskModel task) => <String, int>{
        for (final ArenaQuestion q in task.questions)
          q.id: MockData.quizAnswerKey[q.id]!,
      };

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
      final List<LeaderboardEntry> board =
          MockData.leaderboard().map(LeaderboardEntry.fromJson).toList();
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

  group('Arena — topshiriq bajarish va XP yig\'ilishi', () {
    const String quizId = 'a1000001-0000-4000-8000-000000000001';
    const String mathQuizId = 'a1000001-0000-4000-8000-000000000002';
    const String essayId = 'a1000001-0000-4000-8000-000000000003';
    const String marathonId = 'a1000001-0000-4000-8000-000000000005';
    const String firstStepId = 'a1000001-0000-4000-8000-000000000007';

    test('testni to\'liq to\'g\'ri yechsa — to\'liq XP va jami XP o\'sadi',
        () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      final int before = await ds.getTotalXP('x');
      final ArenaTaskModel task = await ds.getArenaTask(quizId);

      final ArenaTaskResult result = await ds.submitArenaQuiz(
        taskId: quizId,
        answers: correctAnswersFor(task),
      );

      expect(result.correctCount, 5);
      expect(result.totalQuestions, 5);
      expect(result.earnedXp, 120);
      expect(result.totalXp, before + 120);
      expect(await ds.getTotalXP('x'), before + 120);

      // Topshiriq endi "bajarilgan" ro'yxatida.
      final ArenaTaskModel after = await ds.getArenaTask(quizId);
      expect(after.status, ArenaTaskStatus.completed);
      expect(after.earnedXp, 120);
    });

    test('yarim to\'g\'ri javobga proporsional XP beriladi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      final ArenaTaskModel task = await ds.getArenaTask(quizId);

      final Map<String, int> answers = correctAnswersFor(task);
      // 2 ta javobni ataylab buzamiz → 3/5 to'g'ri.
      answers[task.questions[0].id] = (answers[task.questions[0].id]! + 1) % 4;
      answers[task.questions[1].id] = (answers[task.questions[1].id]! + 1) % 4;

      final ArenaTaskResult result =
          await ds.submitArenaQuiz(taskId: quizId, answers: answers);

      expect(result.correctCount, 3);
      expect(result.earnedXp, (120 * 3 / 5).round());
    });

    test('javob berilmagan savol bo\'lsa qabul qilinmaydi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      expect(
        () => ds.submitArenaQuiz(
          taskId: quizId,
          answers: <String, int>{'q1-0001': 1},
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('ijodiy topshiriq yuborilsa to\'liq XP beriladi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      final ArenaTaskResult result = await ds.submitArenaWork(
        taskId: essayId,
        text: 'My future career is to become a software engineer...',
      );
      expect(result.earnedXp, 150);
      expect(result.totalXp, MockData.totalXp + 150);
    });

    test('bo\'sh javob qabul qilinmaydi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      expect(
        () => ds.submitArenaWork(taskId: essayId, text: '   '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('bajarilgan chellenj mukofoti olinadi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      final ArenaTaskResult result = await ds.claimArenaReward(firstStepId);
      expect(result.earnedXp, 50);
      expect(result.totalXp, MockData.totalXp + 50);
    });

    test('tugallanmagan chellenj mukofoti olinmaydi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      expect(
        () => ds.claimArenaReward(marathonId),
        throwsA(isA<ValidationException>()),
      );
    });

    test('bir topshiriq ikki marta bajarilmaydi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      await ds.claimArenaReward(firstStepId);
      expect(
        () => ds.claimArenaReward(firstStepId),
        throwsA(isA<ValidationException>()),
      );
    });

    test('XP yig\'ilib borib reytingda 1-o\'ringa chiqariladi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);

      // Boshida: Madina 1480 XP bilan 1-o'rin, o'quvchi 1240 bilan 2-o'rin.
      List<LeaderboardEntry> board = await ds.getLeaderboard('g');
      expect(board.first.totalXp, 1480);
      expect(board.firstWhere((LeaderboardEntry e) => e.isCurrentUser).rank, 2);

      // 120 + 100 + 150 + 50 = 420 XP → 1660 XP.
      final ArenaTaskModel quiz1 = await ds.getArenaTask(quizId);
      await ds.submitArenaQuiz(
          taskId: quizId, answers: correctAnswersFor(quiz1));
      final ArenaTaskModel quiz2 = await ds.getArenaTask(mathQuizId);
      await ds.submitArenaQuiz(
          taskId: mathQuizId, answers: correctAnswersFor(quiz2));
      // Shu topshiriqdan keyin 1610 XP bo'ladi va 1-o'ringa ko'tariladi.
      final ArenaTaskResult essayResult =
          await ds.submitArenaWork(taskId: essayId, text: 'Essay matni...');
      expect(essayResult.previousRank, 2);
      expect(essayResult.newRank, 1);
      expect(essayResult.movedUp, isTrue);

      final ArenaTaskResult last = await ds.claimArenaReward(firstStepId);
      expect(last.totalXp, MockData.totalXp + 420);
      expect(last.newRank, 1);

      board = await ds.getLeaderboard('g');
      expect(board.first.isCurrentUser, isTrue);
      expect(board.first.totalXp, MockData.totalXp + 420);

      // XP tarixi va bildirishnoma ham yangilangan.
      final List<XpLogModel> logs = await ds.getXpLogs('x');
      expect(logs.first.source, XpSource.arena);
      final List<dynamic> notifications = await ds.getNotifications('x');
      expect(notifications.first.title, '+50 XP');
    });

    test('profil ham yangilangan XP ni qaytaradi', () async {
      final FakeStudentDatasource ds = FakeStudentDatasource(api);
      await ds.claimArenaReward(firstStepId);
      final StudentModel profile = await ds.getProfile('x');
      expect(profile.totalXp, MockData.totalXp + 50);
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
      final Map<int, List<dynamic>> byDay =
          await repo.getScheduleByWeekday('x');

      expect(byDay.keys.every((int d) => d >= 1 && d <= 7), isTrue);
      expect(
        byDay.values.fold<int>(0, (int acc, List<dynamic> l) => acc + l.length),
        8,
      );
    });
  });
}
