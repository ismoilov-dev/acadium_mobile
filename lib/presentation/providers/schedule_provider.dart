import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/student_repository.dart';
import 'auth_provider.dart';

/// Haftalik jadval, kunlar bo'yicha guruhlangan (1 = Dushanba ... 7 = Yakshanba).
final FutureProvider<Map<int, List<LessonModel>>> weeklyScheduleProvider =
    FutureProvider<Map<int, List<LessonModel>>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getScheduleByWeekday(studentId);
});

/// Keyingi (eng yaqin) dars — Home ekranidagi countdown kartasi uchun.
final FutureProvider<LessonModel?> nextLessonProvider =
    FutureProvider<LessonModel?>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getNextLesson(studentId);
});
