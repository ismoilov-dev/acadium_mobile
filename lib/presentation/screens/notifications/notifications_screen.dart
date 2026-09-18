import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/state_views.dart';

/// Bildirishnomalar ro'yxati (o'qilgan / o'qilmagan holati bilan).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<NotificationModel>> notifications =
        ref.watch(notificationsProvider);
    final int unread = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        actions: <Widget>[
          if (unread > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              child: const Text('Hammasini o\'qildi'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: notifications.when(
          loading: () => const ShimmerList(itemCount: 6, itemHeight: 88),
          error: (Object e, _) => ErrorView(
            error: e,
            onRetry: () => ref.read(notificationsProvider.notifier).load(),
          ),
          data: (List<NotificationModel> items) {
            if (items.isEmpty) {
              return const EmptyView(
                icon: Icons.notifications_off_outlined,
                title: 'Bildirishnoma yo\'q',
                message: 'Yangi xabarlar shu yerda paydo bo\'ladi.',
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  ref.read(notificationsProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, int i) => _NotificationTile(
                  notification: items[i],
                  onTap: () => ref
                      .read(notificationsProvider.notifier)
                      .markRead(items[i].id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Bitta bildirishnoma kartasi.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  /// Tur → (ikonka, rang).
  (IconData, Color) get _style {
    switch (notification.type) {
      case NotificationType.homework:
        return (Icons.assignment_outlined, AppColors.warning);
      case NotificationType.grade:
        return (Icons.grade_outlined, AppColors.success);
      case NotificationType.lesson:
        return (Icons.event_note_outlined, AppColors.info);
      case NotificationType.xp:
        return (Icons.bolt_rounded, AppColors.secondary);
      case NotificationType.system:
        return (Icons.campaign_outlined, AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = _style;
    final bool unread = !notification.isRead;

    return AppCard(
      onTap: onTap,
      borderColor: unread ? AppColors.primary.withValues(alpha: 0.35) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight:
                              unread ? FontWeight.w700 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: AppTextStyles.caption,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  Formatters.timeAgo(notification.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
