import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/student_repository.dart';
import 'auth_provider.dart';

/// Bildirishnomalar ro'yxatini boshqaradi (o'qilgan deb belgilash bilan).
class NotificationController
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationController(this._repository, this._studentId)
      : super(const AsyncValue<List<NotificationModel>>.loading()) {
    load();
  }

  final StudentRepository _repository;

  /// Sessiya yopilganda null bo'ladi (logout paytida).
  final String? _studentId;

  Future<void> load() async {
    final String? studentId = _studentId;
    if (studentId == null) {
      state = const AsyncValue<List<NotificationModel>>.data(
        <NotificationModel>[],
      );
      return;
    }

    state = const AsyncValue<List<NotificationModel>>.loading();
    try {
      final List<NotificationModel> items =
          await _repository.getNotifications(studentId);
      if (mounted) state = AsyncValue<List<NotificationModel>>.data(items);
    } catch (e, st) {
      if (mounted) state = AsyncValue<List<NotificationModel>>.error(e, st);
    }
  }

  /// Bittasini o'qilgan deb belgilash (avval UI, keyin server — optimistik).
  Future<void> markRead(String id) async {
    final List<NotificationModel>? current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue<List<NotificationModel>>.data(
      current
          .map((NotificationModel n) =>
              n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
    await _repository.markNotificationRead(id);
  }

  /// Barchasini o'qilgan deb belgilash.
  Future<void> markAllRead() async {
    final List<NotificationModel>? current = state.valueOrNull;
    final String? studentId = _studentId;
    if (current == null || studentId == null) return;

    state = AsyncValue<List<NotificationModel>>.data(
      current.map((NotificationModel n) => n.copyWith(isRead: true)).toList(),
    );
    await _repository.markAllNotificationsRead(studentId);
  }
}

final StateNotifierProvider<NotificationController,
        AsyncValue<List<NotificationModel>>> notificationsProvider =
    StateNotifierProvider<NotificationController,
        AsyncValue<List<NotificationModel>>>(
  (ref) => NotificationController(
    ref.watch(studentRepositoryProvider),
    ref.watch(currentStudentIdProvider),
  ),
);

/// O'qilmagan bildirishnomalar soni (AppBar'dagi nuqta uchun).
final Provider<int> unreadNotificationsCountProvider = Provider<int>((ref) {
  final List<NotificationModel>? items =
      ref.watch(notificationsProvider).valueOrNull;
  if (items == null) return 0;
  return items.where((NotificationModel n) => !n.isRead).length;
});
