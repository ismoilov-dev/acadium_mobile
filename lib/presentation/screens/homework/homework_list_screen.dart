import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/homework_model.dart';
import '../../providers/homework_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/homework_status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/state_views.dart';
import 'homework_detail_screen.dart';

/// Uy vazifalari ro'yxati (status bo'yicha filtrlanadi).
class HomeworkListScreen extends ConsumerWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<HomeworkModel>> homework =
        ref.watch(filteredHomeworkProvider);
    final HomeworkStatus? filter = ref.watch(homeworkFilterProvider);
    final Map<HomeworkStatus, int> counts =
        ref.watch(homeworkCountsProvider).valueOrNull ??
            <HomeworkStatus, int>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uy vazifalari'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(homeworkListProvider),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            _FilterChips(
              selected: filter,
              counts: counts,
              onSelect: (HomeworkStatus? status) =>
                  ref.read(homeworkFilterProvider.notifier).state = status,
            ),
            Expanded(
              child: homework.when(
                loading: () => const ShimmerList(itemCount: 5, itemHeight: 112),
                error: (Object e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(homeworkListProvider),
                ),
                data: (List<HomeworkModel> items) {
                  if (items.isEmpty) {
                    return EmptyView(
                      icon: Icons.task_alt_rounded,
                      title: 'Vazifa yo\'q',
                      message: filter == null
                          ? 'Hozircha uy vazifasi berilmagan. Dam oling!'
                          : '"${filter.label}" holatidagi vazifalar topilmadi.',
                      actionLabel: filter == null ? null : 'Filtrni tozalash',
                      onAction: () => ref
                          .read(homeworkFilterProvider.notifier)
                          .state = null,
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => ref.invalidate(homeworkListProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, int i) =>
                          HomeworkTile(homework: items[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status bo'yicha filtr chiplari (sonlari bilan).
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  final HomeworkStatus? selected;
  final Map<HomeworkStatus, int> counts;
  final ValueChanged<HomeworkStatus?> onSelect;

  @override
  Widget build(BuildContext context) {
    final int total = counts.values.fold<int>(0, (int acc, int v) => acc + v);

    return SizedBox(
      height: 58,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: <Widget>[
          _Chip(
            label: 'Barchasi',
            count: total,
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final HomeworkStatus status in HomeworkStatus.values)
            _Chip(
              label: status.label,
              count: counts[status] ?? 0,
              isSelected: selected == status,
              onTap: () => onSelect(status),
            ),
        ],
      ),
    );
  }
}

/// Bitta filtr chipi.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm, top: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : AppColors.surface,
            borderRadius: AppRadius.chip,
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
            ),
          ),
          child: Row(
            children: <Widget>[
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.onPrimary.withValues(alpha: 0.22)
                      : AppColors.background,
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 11,
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ro'yxatdagi bitta uy vazifasi kartasi.
class HomeworkTile extends StatelessWidget {
  const HomeworkTile({super.key, required this.homework});

  final HomeworkModel homework;

  @override
  Widget build(BuildContext context) {
    final bool overdue = homework.isOverdue;

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HomeworkDetailScreen(homework: homework),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SubjectAvatar(subject: homework.subject),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      homework.title,
                      style: AppTextStyles.h3.copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(homework.subject, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              HomeworkStatusBadge(status: homework.status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Icon(
                overdue ? Icons.error_outline_rounded : Icons.schedule_rounded,
                size: 14,
                color: overdue ? AppColors.danger : AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                overdue
                    ? 'Muddati o\'tgan'
                    : 'Muddat: ${Formatters.dayMonthTime(homework.dueAt)}',
                style: AppTextStyles.caption.copyWith(
                  color: overdue ? AppColors.danger : AppColors.textSecondary,
                  fontWeight: overdue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (homework.score != null)
                Text(
                  '${homework.score}/${homework.maxScore}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                )
              else
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    Text(
                      '+${homework.xpReward} XP',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
