import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/parent_repository.dart';
import 'selected_child_provider.dart';

/// Tanlangan farzandning davomat tarixi.
final FutureProvider<List<AttendanceModel>> childAttendanceProvider =
    FutureProvider<List<AttendanceModel>>((ref) async {
  final ParentRepository repo = ref.watch(parentRepositoryProvider);
  final String childId = requireSelectedChildId(ref);
  return repo.getChildAttendance(childId);
});

/// Tanlangan farzandning haftalik jadvali (kunlar bo'yicha).
final FutureProvider<Map<int, List<LessonModel>>> childScheduleProvider =
    FutureProvider<Map<int, List<LessonModel>>>((ref) async {
  final ParentRepository repo = ref.watch(parentRepositoryProvider);
  final String childId = requireSelectedChildId(ref);
  return repo.getChildScheduleByWeekday(childId);
});
