import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/arena_task_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/xp_model.dart';
import '../../data/repositories/student_repository.dart';
import 'auth_provider.dart';
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

/// Arena topshiriqlari.
final FutureProvider<List<ArenaTaskModel>> arenaTasksProvider =
    FutureProvider<List<ArenaTaskModel>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireStudentId(ref);
  return repo.getArenaTasks(studentId);
});

/// XP tarixi.
final FutureProvider<List<XpLogModel>> xpLogsProvider =
    FutureProvider<List<XpLogModel>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireStudentId(ref);
  final List<XpLogModel> logs = await repo.getXpLogs(studentId);
  logs.sort((XpLogModel a, XpLogModel b) => b.createdAt.compareTo(a.createdAt));
  return logs;
});
