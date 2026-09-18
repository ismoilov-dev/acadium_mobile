import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/arena_task_model.dart';
import '../../../data/models/xp_model.dart';
import '../../providers/arena_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/state_views.dart';

/// Arena: XP, reyting jadvali va topshiriqlar.
class ArenaScreen extends ConsumerWidget {
  const ArenaScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(totalXpProvider);
    ref.invalidate(leaderboardProvider);
    ref.invalidate(arenaTasksProvider);
    ref.invalidate(xpLogsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> xp = ref.watch(totalXpProvider);
    final AsyncValue<LeaderboardEntry?> myRank = ref.watch(myRankProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Arena')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              xp.when(
                loading: () => const AppShimmer(
                  child: ShimmerBox(height: 128, radius: AppRadius.lg),
                ),
                error: (Object e, _) => AppCard(
                  child: ErrorView(
                    error: e,
                    compact: true,
                    onRetry: () => ref.invalidate(totalXpProvider),
                  ),
                ),
                data: (int value) => XpHeroCard(
                  xp: Formatters.number(value),
                  subtitle: myRank.valueOrNull == null
                      ? 'Guruhdagi natijangiz'
                      : 'Guruhda ${myRank.valueOrNull!.rank}-o\'rindasiz',
                  rankLabel: myRank.valueOrNull == null
                      ? null
                      : '${myRank.valueOrNull!.rank}-o\'rin',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _Leaderboard(),
              const SizedBox(height: AppSpacing.xl),
              const _ArenaTasks(),
              const SizedBox(height: AppSpacing.xl),
              const _XpHistory(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Guruh reytingi. Foydalanuvchining qatori ajratib ko'rsatiladi.
class _Leaderboard extends ConsumerWidget {
  const _Leaderboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LeaderboardEntry>> leaderboard =
        ref.watch(leaderboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeader(title: 'Reyting jadvali'),
        leaderboard.when(
          loading: () => const AppShimmer(
            child: Column(
              children: <Widget>[
                ShimmerCard(height: 64),
                SizedBox(height: AppSpacing.sm),
                ShimmerCard(height: 64),
                SizedBox(height: AppSpacing.sm),
                ShimmerCard(height: 64),
              ],
            ),
          ),
          error: (Object e, _) => AppCard(
            child: ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(leaderboardProvider),
            ),
          ),
          data: (List<LeaderboardEntry> items) => items.isEmpty
              ? const AppCard(
                  child: EmptyView(
                    icon: Icons.leaderboard_outlined,
                    title: 'Reyting bo\'sh',
                    message: 'Guruhda hali XP to\'plangan emas.',
                  ),
                )
              : Column(
                  children: <Widget>[
                    for (final LeaderboardEntry e in items) ...<Widget>[
                      _LeaderboardTile(entry: e),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

/// Reytingdagi bitta qator.
class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry});

  final LeaderboardEntry entry;

  /// 1-3 o'rinlar uchun maxsus ranglar.
  Color get _rankColor {
    switch (entry.rank) {
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.textSecondary;
      case 3:
        return AppColors.accent;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = entry.isCurrentUser;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: isMe ? AppColors.primaryGradient : null,
        color: isMe ? null : AppColors.surface,
        borderRadius: AppRadius.card,
        boxShadow: isMe ? AppShadows.glow : AppShadows.soft,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 28,
            child: entry.rank <= 3
                ? Icon(
                    Icons.emoji_events_rounded,
                    size: 20,
                    color: isMe ? AppColors.onPrimary : _rankColor,
                  )
                : Text(
                    '${entry.rank}',
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 15,
                      color: isMe ? AppColors.onPrimary : AppColors.textTertiary,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.onPrimary.withValues(alpha: 0.2)
                  : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Text(
              entry.initials,
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                color: isMe ? AppColors.onPrimary : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${entry.rank}-o\'rin · ${entry.displayName}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isMe ? AppColors.onPrimary : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isMe)
                  Text(
                    'Sizning natijangiz',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            Formatters.number(entry.totalXp),
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              color: isMe ? AppColors.onPrimary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            'XP',
            style: AppTextStyles.caption.copyWith(
              color: isMe
                  ? AppColors.onPrimary.withValues(alpha: 0.85)
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// XP yig'ish topshiriqlari.
class _ArenaTasks extends ConsumerWidget {
  const _ArenaTasks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ArenaTaskModel>> tasks = ref.watch(arenaTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeader(title: 'Topshiriqlar'),
        tasks.when(
          loading: () => const AppShimmer(
            child: Column(
              children: <Widget>[
                ShimmerCard(height: 96),
                SizedBox(height: AppSpacing.md),
                ShimmerCard(height: 96),
              ],
            ),
          ),
          error: (Object e, _) => AppCard(
            child: ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(arenaTasksProvider),
            ),
          ),
          data: (List<ArenaTaskModel> items) => items.isEmpty
              ? const AppCard(
                  child: EmptyView(
                    icon: Icons.flag_outlined,
                    title: 'Topshiriq yo\'q',
                    message: 'Yangi topshiriqlar tez orada qo\'shiladi.',
                  ),
                )
              : Column(
                  children: <Widget>[
                    for (final ArenaTaskModel t in items) ...<Widget>[
                      _ArenaTaskCard(task: t),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

/// Bitta arena topshirig'i kartasi.
class _ArenaTaskCard extends StatelessWidget {
  const _ArenaTaskCard({required this.task});

  final ArenaTaskModel task;

  @override
  Widget build(BuildContext context) {
    final bool done = task.status == ArenaTaskStatus.completed;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.successLight
                      : AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.bolt_rounded,
                  color: done ? AppColors.success : AppColors.secondary,
                  size: 20,
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
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '+${task.xpReward}',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 15,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: task.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      done ? AppColors.success : AppColors.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${task.progressCurrent}/${task.progressTarget}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (task.deadline != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tugaydi: ${Formatters.dayMonthTime(task.deadline!)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// XP tarixi (oxirgi yozuvlar).
class _XpHistory extends ConsumerWidget {
  const _XpHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<XpLogModel>> logs = ref.watch(xpLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeader(title: 'XP tarixi'),
        logs.when(
          loading: () => const AppShimmer(
            child: Column(
              children: <Widget>[
                ShimmerCard(height: 62),
                SizedBox(height: AppSpacing.sm),
                ShimmerCard(height: 62),
              ],
            ),
          ),
          error: (Object e, _) => AppCard(
            child: ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(xpLogsProvider),
            ),
          ),
          data: (List<XpLogModel> items) => items.isEmpty
              ? const AppCard(
                  child: EmptyView(
                    icon: Icons.history_rounded,
                    title: 'Tarix bo\'sh',
                    message: 'XP yig\'ishni bugundan boshlang!',
                  ),
                )
              : AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < items.length; i++) ...<Widget>[
                        _XpLogRow(log: items[i]),
                        if (i != items.length - 1) const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// XP tarixidagi bitta qator.
class _XpLogRow extends StatelessWidget {
  const _XpLogRow({required this.log});

  final XpLogModel log;

  @override
  Widget build(BuildContext context) {
    final bool positive = log.amount >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: positive ? AppColors.successLight : AppColors.dangerLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 16,
              color: positive ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  log.reason,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${log.source.label} · ${Formatters.timeAgo(log.createdAt)}',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : ''}${log.amount}',
            style: AppTextStyles.h3.copyWith(
              fontSize: 15,
              color: positive ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
