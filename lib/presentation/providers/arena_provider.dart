import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/service_locator.dart';
import '../../data/models/arena_task_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/xp_model.dart';
import '../../data/repositories/student_repository.dart';
import 'auth_provider.dart';
import 'notification_provider.dart';
import 'student_provider.dart';

/// Guruh reytingi (leaderboard).
/// Guruh ID'si profil ma'lumotidan olinadi.
final FutureProvider<List<LeaderboardEntry>> leaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final StudentModel profile = await ref.watch(studentProfileProvider.future);
  return repo.getLeaderboard(profile.groupId);
});

/// Foydalanuvchining reytingdagi o'rni.
final Provider<AsyncValue<LeaderboardEntry?>> myRankProvider =
    Provider<AsyncValue<LeaderboardEntry?>>((ref) {
  return ref.watch(leaderboardProvider).whenData(
    (List<LeaderboardEntry> items) {
      for (final LeaderboardEntry e in items) {
        if (e.isCurrentUser) return e;
      }
      return null;
    },
  );
});

/// Barcha arena topshiriqlari.
final FutureProvider<List<ArenaTaskModel>> arenaTasksProvider =
    FutureProvider<List<ArenaTaskModel>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getArenaTasks(studentId);
});

/// Faol (hali bajarilmagan) topshiriqlar.
final Provider<AsyncValue<List<ArenaTaskModel>>> activeArenaTasksProvider =
    Provider<AsyncValue<List<ArenaTaskModel>>>((ref) {
  return ref.watch(arenaTasksProvider).whenData((List<ArenaTaskModel> tasks) {
    final List<ArenaTaskModel> active =
        tasks.where((ArenaTaskModel t) => !t.isCompleted).toList();
    active.sort((ArenaTaskModel a, ArenaTaskModel b) {
      // Mukofot olishga tayyor chellenjlar tepada.
      if (a.canClaim != b.canClaim) return a.canClaim ? -1 : 1;
      final DateTime x =
          a.deadline ?? DateTime.now().add(const Duration(days: 365));
      final DateTime y =
          b.deadline ?? DateTime.now().add(const Duration(days: 365));
      return x.compareTo(y);
    });
    return active;
  });
});

/// Bajarilgan topshiriqlar (yangi → eski).
final Provider<AsyncValue<List<ArenaTaskModel>>> completedArenaTasksProvider =
    Provider<AsyncValue<List<ArenaTaskModel>>>((ref) {
  return ref.watch(arenaTasksProvider).whenData((List<ArenaTaskModel> tasks) {
    final List<ArenaTaskModel> done =
        tasks.where((ArenaTaskModel t) => t.isCompleted).toList();
    done.sort((ArenaTaskModel a, ArenaTaskModel b) =>
        (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
    return done;
  });
});

/// Bitta topshiriq (savollari bilan) — detal ekrani uchun.
final FutureProviderFamily<ArenaTaskModel, String> arenaTaskProvider =
    FutureProvider.family<ArenaTaskModel, String>((ref, String taskId) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  return repo.getArenaTask(taskId);
});

/// Topshiriqni bajarish (yuborish) holati.
class ArenaSubmitState {
  const ArenaSubmitState({
    this.isSubmitting = false,
    this.errorMessage,
    this.result,
  });

  final bool isSubmitting;
  final String? errorMessage;

  /// Muvaffaqiyatli yakunlangach — natija (XP, to'g'ri javoblar, yangi o'rin).
  final ArenaTaskResult? result;
}

/// Arena topshiriqlarini yuborish/mukofot olishni boshqaradi.
///
/// Muvaffaqiyatdan keyin XP, reyting, tarix va bildirishnomalar
/// provider'lari yangilanadi — butun ilova bo'ylab XP bir zumda o'sadi.
class ArenaSubmitController extends StateNotifier<ArenaSubmitState> {
  ArenaSubmitController(this._ref) : super(const ArenaSubmitState());

  final Ref _ref;

  StudentRepository get _repo => _ref.read(studentRepositoryProvider);

  /// Test javoblarini yuborish.
  Future<bool> submitQuiz({
    required String taskId,
    required Map<String, int> answers,
  }) =>
      _run(() => _repo.submitArenaQuiz(taskId: taskId, answers: answers));

  /// Ijodiy topshiriqni yuborish.
  Future<bool> submitWork({
    required String taskId,
    required String text,
    List<String> fileNames = const <String>[],
  }) =>
      _run(() => _repo.submitArenaWork(
            taskId: taskId,
            text: text,
            fileNames: fileNames,
          ));

  /// Bajarilgan chellenj mukofotini olish.
  Future<bool> claim(String taskId) =>
      _run(() => _repo.claimArenaReward(taskId));

  void reset() => state = const ArenaSubmitState();

  Future<bool> _run(Future<ArenaTaskResult> Function() action) async {
    state = const ArenaSubmitState(isSubmitting: true);
    try {
      final ArenaTaskResult result = await action();
      state = ArenaSubmitState(result: result);
      _refreshAll();
      return true;
    } on AppException catch (e) {
      state = ArenaSubmitState(errorMessage: e.message);
      return false;
    }
  }

  /// XP o'zgargandan keyin unga bog'liq hamma narsani yangilaymiz.
  void _refreshAll() {
    _ref.invalidate(arenaTasksProvider);
    _ref.invalidate(totalXpProvider);
    _ref.invalidate(leaderboardProvider);
    _ref.invalidate(xpLogsProvider);
    _ref.invalidate(studentProfileProvider);
    _ref.invalidate(notificationsProvider);
  }
}

final StateNotifierProvider<ArenaSubmitController, ArenaSubmitState>
    arenaSubmitProvider =
    StateNotifierProvider<ArenaSubmitController, ArenaSubmitState>(
  (ref) => ArenaSubmitController(ref),
);

/// XP tarixi.
final FutureProvider<List<XpLogModel>> xpLogsProvider =
    FutureProvider<List<XpLogModel>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  final List<XpLogModel> logs = await repo.getXpLogs(studentId);
  logs.sort((XpLogModel a, XpLogModel b) => b.createdAt.compareTo(a.createdAt));
  return logs;
});
