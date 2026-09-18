import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/service_locator.dart';
import '../../data/models/homework_model.dart';
import '../../data/repositories/student_repository.dart';
import 'auth_provider.dart';

/// Barcha uy vazifalari.
final FutureProvider<List<HomeworkModel>> homeworkListProvider =
    FutureProvider<List<HomeworkModel>>((ref) async {
  final StudentRepository repo = ref.watch(studentRepositoryProvider);
  final String studentId = requireUserId(ref);
  return repo.getHomework(studentId);
});

/// Tanlangan filtr (null — barchasi).
final StateProvider<HomeworkStatus?> homeworkFilterProvider =
    StateProvider<HomeworkStatus?>((ref) => null);

/// Filtrga mos uy vazifalari.
final Provider<AsyncValue<List<HomeworkModel>>> filteredHomeworkProvider =
    Provider<AsyncValue<List<HomeworkModel>>>((ref) {
  final HomeworkStatus? filter = ref.watch(homeworkFilterProvider);
  return ref.watch(homeworkListProvider).whenData((List<HomeworkModel> items) {
    if (filter == null) return items;
    return items.where((HomeworkModel h) => h.status == filter).toList();
  });
});

/// Har bir status bo'yicha nechtadan bor — filter chiplaridagi badge uchun.
final Provider<AsyncValue<Map<HomeworkStatus, int>>> homeworkCountsProvider =
    Provider<AsyncValue<Map<HomeworkStatus, int>>>((ref) {
  return ref.watch(homeworkListProvider).whenData((List<HomeworkModel> items) {
    final Map<HomeworkStatus, int> counts = <HomeworkStatus, int>{
      for (final HomeworkStatus s in HomeworkStatus.values) s: 0,
    };
    for (final HomeworkModel h in items) {
      counts[h.status] = (counts[h.status] ?? 0) + 1;
    }
    return counts;
  });
});

/// Kutilayotgan (topshirilmagan) vazifalar soni — Home ekrani uchun.
final Provider<AsyncValue<int>> pendingHomeworkCountProvider =
    Provider<AsyncValue<int>>((ref) {
  return ref.watch(homeworkListProvider).whenData((List<HomeworkModel> items) =>
      items.where((HomeworkModel h) => h.isPending).length);
});

/// Uy vazifasini topshirish holati.
class HomeworkSubmitState {
  const HomeworkSubmitState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;
}

/// Topshirish oqimini boshqaradi.
///
/// Fake rejimda fayl haqiqatda yuklanmaydi — faqat tanlangan fayl nomlari
/// yuboriladi, lekin UI oqimi real API bilan bir xil ishlaydi.
class HomeworkSubmitController extends StateNotifier<HomeworkSubmitState> {
  HomeworkSubmitController(this._ref) : super(const HomeworkSubmitState());

  final Ref _ref;

  Future<bool> submit({
    required String homeworkId,
    required String text,
    List<String> fileNames = const <String>[],
  }) async {
    state = const HomeworkSubmitState(isSubmitting: true);
    try {
      final StudentRepository repo = _ref.read(studentRepositoryProvider);
      await repo.submitHomework(
        HomeworkSubmission(
          homeworkId: homeworkId,
          text: text,
          fileNames: fileNames,
        ),
      );
      // Ro'yxat yangilansin.
      _ref.invalidate(homeworkListProvider);
      state = const HomeworkSubmitState(isSuccess: true);
      return true;
    } on AppException catch (e) {
      state = HomeworkSubmitState(errorMessage: e.message);
      return false;
    }
  }

  void reset() => state = const HomeworkSubmitState();
}

final StateNotifierProvider<HomeworkSubmitController, HomeworkSubmitState>
    homeworkSubmitProvider =
    StateNotifierProvider<HomeworkSubmitController, HomeworkSubmitState>(
  (ref) => HomeworkSubmitController(ref),
);
