import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/arena_task_model.dart';
import 'app_card.dart';

/// Arena topshirig'ining turi bo'yicha ikonka va rang.
class ArenaTaskStyle {
  const ArenaTaskStyle._();

  static IconData iconOf(ArenaTaskType type) {
    switch (type) {
      case ArenaTaskType.quiz:
        return Icons.quiz_rounded;
      case ArenaTaskType.submission:
        return Icons.edit_note_rounded;
      case ArenaTaskType.challenge:
        return Icons.flag_rounded;
    }
  }

  static Color colorOf(ArenaTaskType type) {
    switch (type) {
      case ArenaTaskType.quiz:
        return AppColors.primary;
      case ArenaTaskType.submission:
        return AppColors.secondary;
      case ArenaTaskType.challenge:
        return AppColors.accent;
    }
  }
}

/// Arena ro'yxatidagi topshiriq kartasi.
/// O'qituvchi, tur, XP mukofoti va bajarilish holatini ko'rsatadi.
class ArenaTaskCard extends StatelessWidget {
  const ArenaTaskCard({super.key, required this.task, this.onTap});

  final ArenaTaskModel task;
  final VoidCallback? onTap;

  /// Kartaning pastki qatoridagi qo'shimcha ma'lumot.
  String get _meta {
    switch (task.type) {
      case ArenaTaskType.quiz:
        return '${task.progressTarget} ta savol';
      case ArenaTaskType.submission:
        return 'Matn yoki fayl yuboriladi';
      case ArenaTaskType.challenge:
        return '${task.progressCurrent}/${task.progressTarget} bajarildi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = ArenaTaskStyle.colorOf(task.type);
    final bool done = task.isCompleted;

    return AppCard(
      onTap: onTap,
      borderColor: task.canClaim ? AppColors.success : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.successLight
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  done ? Icons.check_rounded : ArenaTaskStyle.iconOf(task.type),
                  color: done ? AppColors.success : color,
                  size: 21,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: AppTextStyles.h3.copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.subject.isEmpty
                          ? task.teacherName
                          : '${task.teacherName} · ${task.subject}',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _XpPill(
                label: done ? '+${task.earnedXp ?? 0}' : '+${task.xpReward}',
                color: done ? AppColors.success : AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (task.type == ArenaTaskType.challenge && !done) ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: task.progress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  task.canClaim ? AppColors.success : color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: <Widget>[
              Icon(
                done ? Icons.verified_rounded : Icons.info_outline_rounded,
                size: 13,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  done
                      ? (task.resultComment ?? 'Bajarilgan')
                      : task.canClaim
                          ? 'Mukofotni olishingiz mumkin!'
                          : _meta,
                  style: AppTextStyles.caption.copyWith(
                    color: task.canClaim
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight:
                        task.canClaim ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!done && task.deadline != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: task.isExpired
                      ? AppColors.danger
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 3),
                Text(
                  task.isExpired
                      ? "Muddati o'tgan"
                      : Formatters.remaining(task.deadline!),
                  style: AppTextStyles.caption.copyWith(
                    color: task.isExpired
                        ? AppColors.danger
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// "+120" ko'rinishidagi XP belgisi.
class _XpPill extends StatelessWidget {
  const _XpPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.bolt_rounded, size: 14, color: color),
          Text(
            '$label XP',
            style: AppTextStyles.label.copyWith(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
