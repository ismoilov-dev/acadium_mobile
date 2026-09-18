import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';
import 'auth_provider.dart';

/// Profil ma'lumotlari.
final FutureProvider<StudentModel> studentProfileProvider =
    FutureProvider<StudentModel>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getProfile(studentId);
});

/// Barcha baholar (yangi → eski).
final FutureProvider<List<GradeModel>> gradesProvider =
    FutureProvider<List<GradeModel>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getGrades(studentId);
});

/// Fanlar bo'yicha guruhlangan baholar.
final FutureProvider<List<SubjectGrades>> gradesBySubjectProvider =
    FutureProvider<List<SubjectGrades>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getGradesBySubject(studentId);
});

/// Umumiy progress: davomat %, uy vazifasi %, testlar %.
final FutureProvider<ProgressSummary> progressProvider =
    FutureProvider<ProgressSummary>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getProgress(studentId);
});

/// Jami XP.
final FutureProvider<int> totalXpProvider = FutureProvider<int>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getTotalXP(studentId);
});
