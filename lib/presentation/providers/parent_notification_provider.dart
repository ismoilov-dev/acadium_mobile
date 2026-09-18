import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/service_locator.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/parent_repository.dart';
import 'auth_provider.dart';

/// Ota-ona bildirishnomalari (o'qilgan deb belgilash bilan).
/// Student tomonidagi kontroller bilan bir xil tamoyilda ishlaydi.
class ParentNotificationController
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  ParentNotificationController(this._repository, this._parentId)
      : super(const AsyncValue<List<NotificationModel>>.loading()) {
    load();
  }

  final ParentRepository _repository;
  final String? _parentId;

  Future<void> load() async {
    final String? parentId = _parentId;
    if (parentId == null) {
      state = const AsyncValue<List<NotificationModel>>.data(
        <NotificationModel>[],
      );
      return;
    }

    state = const AsyncValue<List<NotificationModel>>.loading();
    try {
      final List<NotificationModel> items =
          await _repository.getNotifications(parentId);
      if (mounted) state = AsyncValue<List<NotificationModel>>.data(items);
    } catch (e, st) {
      if (mounted) state = AsyncValue<List<NotificationModel>>.error(e, st);
    }
  }

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

  Future<void> markAllRead() async {
    final List<NotificationModel>? current = state.valueOrNull;
    final String? parentId = _parentId;
    if (current == null || parentId == null) return;

    state = AsyncValue<List<NotificationModel>>.data(
      current.map((NotificationModel n) => n.copyWith(isRead: true)).toList(),
    );
    await _repository.markAllNotificationsRead(parentId);
  }
}

final StateNotifierProvider<ParentNotificationController,
        AsyncValue<List<NotificationModel>>> parentNotificationsProvider =
    StateNotifierProvider<ParentNotificationController,
        AsyncValue<List<NotificationModel>>>(
  (ref) => ParentNotificationController(
    ref.watch(parentRepositoryProvider),
    ref.watch(currentUserIdProvider),
  ),
);

/// O'qilmagan bildirishnomalar soni.
final Provider<int> parentUnreadCountProvider = Provider<int>((ref) {
  final List<NotificationModel>? items =
      ref.watch(parentNotificationsProvider).valueOrNull;
  if (items == null) return 0;
  return items.where((NotificationModel n) => !n.isRead).length;
});
