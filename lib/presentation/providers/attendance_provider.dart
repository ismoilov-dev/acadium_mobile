import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/student_repository.dart';
import 'auth_provider.dart';

/// Davomat tarixi.
final FutureProvider<List<AttendanceModel>> attendanceProvider =
    FutureProvider<List<AttendanceModel>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  final List<AttendanceModel> items = await repo.getAttendance(studentId);
  items
      .sort((AttendanceModel a, AttendanceModel b) => b.date.compareTo(a.date));
  return items;
});

/// Davomat foizi (0..1).
final Provider<AsyncValue<double>> attendanceRateProvider =
    Provider<AsyncValue<double>>((ref) {
  return ref.watch(attendanceProvider).whenData((List<AttendanceModel> items) {
    if (items.isEmpty) return 0.0;
    final int attended =
        items.where((AttendanceModel a) => a.countsAsAttended).length;
    return attended / items.length;
  });
});
